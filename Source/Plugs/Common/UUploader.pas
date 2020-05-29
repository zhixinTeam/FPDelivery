unit UUploader;

interface

uses
  Windows, Classes, SysUtils, UBusinessWorker, UBusinessPacker, UBusinessConst,
  UMgrDBConn, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger, DB;

type
  TUploader = class;
  TUploadThread = class(TThread)
  private
    FOwner: TUploader;
    //ӵ����
    FDB: string;
    FDBConn: PDBWorker;
    FErpDBConn: PDBWorker;
    //���ݶ���
    FListA,FListB: TStrings;
    //�б����
    FNumAutoPostBill: Integer;
    //��ʱ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
  protected
    FErrNum: integer;
    procedure SyncBill;
    procedure SyncOrder;
    procedure SyncOrderDtl;
    procedure SyncPoundLog;
    procedure SyncInOutMoney;
    procedure SyncCustomer;
    procedure SyncSaleMan;
    procedure SyncCusAcc;
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TUploader);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TUploader = class(TObject)
  private
    FDB: string;
    //���ݱ�ʶ
    FThread: TUploadThread;
    //ɨ���߳�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start(const nDB: string = '');
    procedure Stop;
    //��ͣ�ϴ�
  end;

var
  gUploader: TUploader = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TUploader, '����ͬ��', nMsg);
end;

constructor TUploader.Create;
begin
  FThread := nil;
end;

destructor TUploader.Destroy;
begin
  Stop;
  inherited;
end;

procedure TUploader.Start(const nDB: string);
begin
  if nDB = '' then
  begin
    if Assigned(FThread) then
      FThread.Wakeup;
    //start upload
  end else

  if not Assigned(FThread) then
  begin
    FDB := nDB;
    FThread := TUploadThread.Create(Self);
  end;
end;

procedure TUploader.Stop;
begin
  if Assigned(FThread) then
  begin
    FThread.StopMe;
    FThread := nil;
  end;
end;

//------------------------------------------------------------------------------
constructor TUploadThread.Create(AOwner: TUploader);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FDB := FOwner.FDB;
  
  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 6 * 1000;
  //6 second

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_Upload_Sync');
  //process sync
end;

destructor TUploadThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TUploadThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TUploadThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TUploadThread.Execute;
var nStr: string;
    nErr: Integer;
    nInit: Int64;
begin
  FNumAutoPostBill := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumAutoPostBill);
    //inc counter

    if FNumAutoPostBill >= 10 then
      FNumAutoPostBill := 0;
    //�Զ�����: 1����/1��

    if (FNumAutoPostBill <> 0) then
      Continue;
    //��ҵ�����

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��

    FDBConn := nil;
    FErpDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(FDB, nErr);
      if not Assigned(FDBConn) then
      begin
        WriteLog('�������ݿ�ʧ��(DBConn Is Null).');
        Continue;
      end;

      FErpDBConn := gDBConnManager.GetConnection(sFlag_DB_ZB, nErr);
      if not Assigned(FErpDBConn) then
      begin
        WriteLog('�������ݿ�ʧ��(ErpDBConn Is Null).');
        Continue;
      end;
      if not FErpDBConn.FConn.Connected then
      FErpDBConn.FConn.Connected := True;
    //conn db

      if FNumAutoPostBill = 0 then
      try
        WriteLog('��ʼͬ���������ܲ�...');
              
        nInit := GetTickCount;
        SyncBill;
        SyncOrder;
        SyncOrderDtl;
        SyncPoundLog;
        SyncInOutMoney;
        SyncCustomer;
        SyncSaleMan;
        SyncCusAcc;
        nStr := 'ͬ���������,��ʱ: %d ����.';
        WriteLog(Format(nStr, [GetTickCount - nInit]));
      finally
      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
      gDBConnManager.ReleaseConnection(FErpDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//ͬ��S_Bill��
procedure TUploadThread.SyncBill;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
  nErpWorker:PDBWorker;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as L_FacID,* from DL_SyncToZB left join '+
          'S_Bill on S_Record=L_ID where S_Table=''S_bill'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if (Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'L_Value') or
            (Fields[nIdx].FieldName = 'L_Price') or
            (Fields[nIdx].FieldName = 'L_PValue') or
            (Fields[nIdx].FieldName = 'L_MValue') or
            (Fields[nIdx].FieldName = 'L_DaiTotal') or
            (Fields[nIdx].FieldName = 'L_DaiNormal') or
            (Fields[nIdx].FieldName = 'L_DaiBuCha') or
            (Fields[nIdx].FieldName = 'L_KZValue') or
            (Fields[nIdx].FieldName = 'L_Freight')  then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into S_bill('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'L_Value') or
            (Fields[nIdx].FieldName = 'L_Price') or
            (Fields[nIdx].FieldName = 'L_PValue') or
            (Fields[nIdx].FieldName = 'L_MValue') or
            (Fields[nIdx].FieldName = 'L_DaiTotal') or
            (Fields[nIdx].FieldName = 'L_DaiNormal') or
            (Fields[nIdx].FieldName = 'L_DaiBuCha') or
            (Fields[nIdx].FieldName = 'L_KZValue') or
            (Fields[nIdx].FieldName = 'L_Freight')  then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where L_ID=''%s''';
        nSQL := Format(nSQL,[sTable_Bill,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where L_id=''%s''';
        nSQL := Format(nSQL,[sTable_Bill,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;
      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;

  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��S_Bill���ݵ�ERPϵͳʧ��.');
  end;
end;

//ͬ��P_order��
procedure TUploadThread.SyncOrder;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as O_FacID,* from DL_SyncToZB left join '+
          'P_Order on S_Record=O_ID where S_Table=''P_Order'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if (Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if Fields[nIdx].FieldName = 'O_Value' then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into P_Order('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if Fields[nIdx].FieldName = 'O_Value' then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where O_ID=''%s''';
        nSQL := Format(nSQL,[sTable_Order,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where O_Id=''%s''';
        nSQL := Format(nSQL,[sTable_Order,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��P_Order���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncOrderDtl;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as L_FacID,* from DL_SyncToZB left join '+
          'P_OrderDtl on S_Record=D_ID where S_Table=''P_OrderDtl'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'D_PValue') or
             (Fields[nIdx].FieldName = 'D_MValue') or
             (Fields[nIdx].FieldName = 'D_Value') or
             (Fields[nIdx].FieldName = 'D_KZValue') or
             (Fields[nIdx].FieldName = 'D_AKValue') or
             (Fields[nIdx].FieldName = 'D_TestJG1') or
             (Fields[nIdx].FieldName = 'D_TestJG2') or
             (Fields[nIdx].FieldName = 'D_SFKZ')  then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into P_OrderDtl('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'D_PValue') or
             (Fields[nIdx].FieldName = 'D_MValue') or
             (Fields[nIdx].FieldName = 'D_Value') or
             (Fields[nIdx].FieldName = 'D_KZValue') or
             (Fields[nIdx].FieldName = 'D_AKValue') or
             (Fields[nIdx].FieldName = 'D_TestJG1') or
             (Fields[nIdx].FieldName = 'D_TestJG2') or
             (Fields[nIdx].FieldName = 'D_SFKZ') then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where D_ID=''%s''';
        nSQL := Format(nSQL,[sTable_OrderDtl,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where D_Id=''%s''';
        nSQL := Format(nSQL,[sTable_OrderDtl,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��P_Orderdtl���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncPoundLog;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as L_FacID,* from DL_SyncToZB left join '+
          'Sys_Poundlog on S_Record=P_ID where S_Table=''Sys_Poundlog'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'P_PValue') or
             (Fields[nIdx].FieldName = 'P_MValue') or
             (Fields[nIdx].FieldName = 'P_LimValue') or
             (Fields[nIdx].FieldName = 'P_KZValue')  then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into Sys_PoundLog('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'P_PValue') or
             (Fields[nIdx].FieldName = 'P_MValue') or
             (Fields[nIdx].FieldName = 'P_LimValue') or
             (Fields[nIdx].FieldName = 'P_KZValue')  then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where P_ID=''%s''';
        nSQL := Format(nSQL,[sTable_PoundLog,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where P_Id=''%s''';
        nSQL := Format(nSQL,[sTable_OrderDtl,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��Sys_PoundLog���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncInOutMoney;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as L_FacID,* from DL_SyncToZB left join '+
          'Sys_CustomerInOutMoney on S_Record=R_ID where S_Table=''Sys_InOutMoney'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'M_Money') then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into Sys_CustomerInOutMoney('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end;
      {else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'M_Money') then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where R_ID=''%s''';
        nSQL := Format(nSQL,[sTable_PoundLog,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where P_Id=''%s''';
        nSQL := Format(nSQL,[sTable_OrderDtl,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;}

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��Sys_PoundLog���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncCustomer;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as O_FacID,* from DL_SyncToZB left join '+
          'S_Customer on S_Record=C_ID where S_Table=''S_Customer'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if (Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into S_Customer('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where C_ID=''%s''';
        nSQL := Format(nSQL,[sTable_Customer,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where C_Id=''%s''';
        nSQL := Format(nSQL,[sTable_Customer,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��S_Customer���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncSaleMan;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as O_FacID,* from DL_SyncToZB left join '+
          'S_Salesman on S_Record=C_ID where S_Table=''S_Salesman'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if (Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into S_Salesman('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where S_ID=''%s''';
        nSQL := Format(nSQL,[sTable_Salesman,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where S_Id=''%s''';
        nSQL := Format(nSQL,[sTable_Salesman,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��S_Salesman���ݵ�ERPϵͳʧ��.');
  end;
end;

procedure TUploadThread.SyncCusAcc;
var
  nStr, nField, nFValue, nSQL, nIDs: string;
  nIdx: Integer;
begin
  FListA.Clear;
  
  nStr := 'select '+gsysparam.FFacID+'as O_FacID,* from DL_SyncToZB left join '+
          'Sys_CustomerAccount on S_Record=A_CID where S_Table=''Sys_CustomerAccount'' order by S_Time';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then Exit;

    First;
    while not Eof do
    begin
      if FieldByName('S_Action').AsString = 'A' then
      begin 
        nField := '';
        nFValue := '';
        for nIdx:=0 to FieldCount - 1 do
        if (Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'A_InMoney') or
            (Fields[nIdx].FieldName = 'A_OutMoney') or
            (Fields[nIdx].FieldName = 'A_DebtMoney') or
            (Fields[nIdx].FieldName = 'A_InitMoney') or
            (Fields[nIdx].FieldName = 'A_Compensation') or
            (Fields[nIdx].FieldName = 'A_FreezeMoney') or
            (Fields[nIdx].FieldName = 'A_CreditLimit') then
            nFValue := nFValue+ FloatToStr(Fields[nIdx].asfloat)+','
          else
            nFValue := nFValue+ ''''+Fields[nIdx].AsString+''''+',';
          nField := nField + Fields[nIdx].FieldName + ',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nFValue := Copy(nFValue,1,Length(nFValue)-1);
        nSQL := 'Insert into Sys_CustomerAccount('+nField+') values ('+nFValue+')';
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'E' then
      begin
        nField := '';
        for nIdx:=0 to FieldCount - 1 do
        if(Fields[nIdx].DataType <> ftAutoInc) and
          (Fields[nIdx].FieldName<>'R_ID') and
          (Fields[nIdx].FieldName<>'S_Table') and
          (Fields[nIdx].FieldName<>'S_Action') and
          (Fields[nIdx].FieldName<>'S_Record') and
          (Fields[nIdx].FieldName<>'S_Param1') and
          (Fields[nIdx].FieldName<>'S_Param2') and
          (Fields[nIdx].FieldName<>'S_Time') then
        begin
          if (Fields[nIdx].FieldName = 'A_InMoney') or
            (Fields[nIdx].FieldName = 'A_OutMoney') or
            (Fields[nIdx].FieldName = 'A_DebtMoney') or
            (Fields[nIdx].FieldName = 'A_InitMoney') or
            (Fields[nIdx].FieldName = 'A_Compensation') or
            (Fields[nIdx].FieldName = 'A_FreezeMoney') or
            (Fields[nIdx].FieldName = 'A_CreditLimit') then

            nField := nField + Fields[nIdx].FieldName + '='+
                    FloatToStr(Fields[nIdx].asfloat)+','
          else
            nField := nField + Fields[nIdx].FieldName + '='+
                    ''''+Fields[nIdx].AsString+''''+',';
        end;
        nField := Copy(nField,1,Length(nField)-1);
        nSQL := 'Update %s set '+nField + ' Where A_CID=''%s''';
        nSQL := Format(nSQL,[sTable_CusAccount,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end
      else
      if FieldByName('S_Action').AsString = 'D' then
      begin
        nSQL := 'Delete from %s where A_CId=''%s''';
        nSQL := Format(nSQL,[sTable_CusAccount,FieldByName('S_Record').AsString]);
        FListA.Add(nSQL);
      end;

      nIDs := nIDs + FieldByName('R_ID').AsString+',';
      Next;
    end;
  end;
  
  FErpDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FErpDBConn, FListA[nIdx]);
      WriteLog(FListA[nIdx]);
    end;
    //xxxxx
    FErpDBConn.FConn.CommitTrans;

    nIDs := Copy(nIDs,1,Length(nIDs)-1);
    nSQL := 'Delete from DL_SyncToZB where R_ID in ('+nIDs+')';
    WriteLog(nSQL);
    gDBConnManager.WorkerExec(FDBConn, nSQL);
  except
    FErpDBConn.FConn.RollbackTrans;
    WriteLog('ͬ��S_CusAcc���ݵ�ERPϵͳʧ��.');
  end;
end;

initialization
  gUploader := TUploader.Create;
finalization
  FreeAndNil(gUploader);
end.
