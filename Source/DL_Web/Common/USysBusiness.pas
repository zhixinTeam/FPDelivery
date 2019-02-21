{*******************************************************************************
  ����: dmzn@163.com 2018-04-23
  ����: ҵ���嵥Ԫ
*******************************************************************************}
unit USysBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, ComCtrls, Controls, Messages, Forms, SysUtils, IniFiles,
  Data.DB, Data.Win.ADODB, Datasnap.Provider, Datasnap.DBClient,
  System.SyncObjs, Vcl.Grids, Vcl.DBGrids, Vcl.Graphics,
  //----------------------------------------------------------------------------
  uniGUIAbstractClasses, uniGUITypes, uniGUIClasses, uniGUIBaseClasses,
  uniGUISessionManager, uniGUIApplication, uniTreeView, uniGUIForm,
  uniDBGrid, uniStringGrid, uniComboBox,
  //----------------------------------------------------------------------------
  UBaseObject, UManagerGroup, ULibFun, USysDB, USysConst, USysFun, USysRemote;

procedure GlobalSyncLock;
procedure GlobalSyncRelease;
//ȫ��ͬ������
procedure RegObjectPoolTypes;
//ע�Ỻ��ض���

function FactoryIndexByID(const nID: string): Integer;
//��ȡָ����������
function LockDBConn(const nType: TAdoConnectionType = ctMain;
  const nFactory: string = ''): TADOConnection;
procedure ReleaseDBconn(const nConn: TADOConnection);
function LockDBQuery(const nType: TAdoConnectionType = ctMain;
  const nFactory: string = ''): TADOQuery;
procedure ReleaseDBQuery(const nQuery: TADOQuery;
  const nResetConn: Boolean = False);
//���ݿ���·
function DBQuery(const nStr: string; const nQuery: TADOQuery;
  const nClientDS: TClientDataSet = nil): TDataSet;
function DBExecute(const nStr: string; const nCmd: TADOQuery = nil;
  const nType: TAdoConnectionType = ctMain;
  const nFactory: string = ''): Integer; overload;
function DBExecute(const nList: TStrings; const nCmd: TADOQuery = nil;
  const nType: TAdoConnectionType = ctMain;
  const nFactory: string = ''): Integer; overload;
//���ݿ����
procedure DSClientDS(const nDS: TDataSet; const nClientDS: TClientDataSet);
//���ݼ�ת��

function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function SystemGetForm(const nClass: string;
  const nException: Boolean = False): TUniForm;
//���������ƻ�ȡ�������
function UserFlagByID: string;
function UserConfigFile: TIniFile;
//�û��Զ��������ļ�
function GetUserFixParameter(const nParam: string): string;
//��ȡ�û����ݵ�method����
function IfNeedLogin: Boolean;
//�Ƿ���Ҫ��¼
function WriteSysLog(const nGroup,nItem,nEvent: string;
  const nType: TAdoConnectionType = ctMain; const nQuery: TADOQuery = nil;
  const nHint: Boolean = True; const nExec: Boolean = True;
  const nKeyID: string = ''; const nMan: string = ''): string;
 //��¼ϵͳ��־
procedure LoadFormConfig(const nForm: TUniForm; const nIni: TIniFile = nil);
procedure SaveFormConfig(const nForm: TUniForm; const nIni: TIniFile = nil);
//��д����������Ϣ
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
//��ʽ���ſ����
procedure LoadSystemMemoryStatus(const nList: TStrings; const nFriend: Boolean);
//����ϵͳ�ڴ�״̬
procedure ReloadSystemMemory(const nResetAllSession: Boolean);
//���¼���ϵͳ��������

function GetIDFromBox(const nBox: TUniComboBox): string;
function GetNameFromBox(const nBox: TUniComboBox): string;
//��nBox�ж�ȡID,Name��

procedure LoadMenuItems(const nForce: Boolean);
//����˵�����
procedure BuidMenuTree(const nTree: TUniTreeView; nEntity: string = '');
//�����˵���
function GetMenuItemID(const nIdx: Integer): string;
//��ȡָ���˵���ʶ
function GetMenuByModule(const nModule: string): string;
function GetModuleByMenu(const nMenu: string): string;
//�˵���ģ�黥��

procedure LoadFactoryList(const nForce: Boolean);
//���빤���б�
procedure GetFactoryList(const nList: TStrings);
function GetFactory(const nIdx: Integer; var nFactory: TFactoryItem): Boolean;
//���������б�

procedure LoadPopedomList(const nForce: Boolean);
//����Ȩ���б�
function GetPopedom(const nMenu: string): string;
function HasPopedom(const nMenu,nPopedom: string): Boolean;
function HasPopedom2(const nPopedom,nAll: string): Boolean;
//�Ƿ���ָ��Ȩ��

procedure LoadEntityList(const nForce: Boolean);
//���������ֵ��б�
procedure BuildDBGridColumn(const nEntity: string; const nGrid: TUniDBGrid;
  const nFilter: string = '');
//���������
procedure BuidDataSetSortIndex(const nClientDS: TClientDataSet);
//����nClientDS��������
procedure SetGridColumnFormat(const nEntity: string;
  const nClientDS: TClientDataSet; const nOnData: TFieldGetTextEvent);
//����nGrid�����ݺ���ʵӳ��
procedure UserDefineGrid(const nForm: string; const nGrid: TUniDBGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
procedure UserDefineStringGrid(const nForm: string; const nGrid: TUniStringGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
procedure DoStringGridColumnResize(const nGrid: TObject;
  const nParam: TUniStrings);
//�û��Զ�����

implementation

uses
  MainModule, ServerModule;

var
  gSyncLock: TCriticalSection;
  //ȫ����ͬ������

//------------------------------------------------------------------------------
//Date: 2018-04-23
//Desc: ȫ��ͬ������
procedure GlobalSyncLock;
begin
  gSyncLock.Enter;
end;

//Date: 2018-04-23
//Desc: ȫ��ͬ�������Ӵ�
procedure GlobalSyncRelease;
begin
  gSyncLock.Leave;
end;

//Date: 2018-04-20
//Desc: ע������
procedure RegObjectPoolTypes;
var nCD: PAdoConnectionData;
begin
  with gMG.FObjectPool do
  begin
    NewClass(TADOConnection,
      function(var nData: Pointer):TObject
      begin
        Result := TADOConnection.Create(nil);
        New(nCD);
        nData := nCD;

        nCD.FConnUser := '';
        nCD.FConnStr := '';
      end,

      procedure(const nObj: TObject; const nData: Pointer)
      begin
        nObj.Free;
        Dispose(PAdoConnectionData(nData));
      end);
    //ado conn

    NewClass(TADOQuery,
      function(var nData: Pointer):TObject
      begin
        Result := TADOQuery.Create(nil);
      end);
    //ado query

    NewClass(TDataSetProvider,
      function(var nData: Pointer):TObject
      begin
        Result := TDataSetProvider.Create(nil);
      end,

      procedure(const nObj: TObject; const nData: Pointer)
      begin
        TDataSetProvider(nObj).Free;
      end);
    //data provider
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-06-15
//Parm: ������ʶ
//Desc: ��ȡnID������
function FactoryIndexByID(const nID: string): Integer;
var nIdx: Integer;
begin
  GlobalSyncLock;
  try
    Result := -1;
    //default

    for nIdx := Low(gAllFactorys) to High(gAllFactorys) do
    if CompareText(nID, gAllFactorys[nIdx].FFactoryID) = 0 then
    begin
      Result := nIdx;
      Break;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-20
//Parm: ��������;������ʶ
//Desc: ��ȡ���ݿ���·
function LockDBConn(const nType: TAdoConnectionType;
  const nFactory: string): TADOConnection;
var nStr: string;
    nIdx: Integer;
    nCD: PAdoConnectionData;
begin
  GlobalSyncLock;
  try
    if nType = ctMain then
    begin
      nStr := gServerParam.FDBMain;
      //main db config
    end else
    begin
      if nFactory <> '' then
      begin
        nIdx := FactoryIndexByID(nFactory);
        if nIdx < 0 then
        begin
          nStr := Format('����[ %s ]������,��������.', [nFactory]);
          raise Exception.Create(nStr);
        end;
      end else nIdx := UniMainModule.FUserConfig.FFactory; //user selecte db

      nStr := gAllFactorys[nIdx].FDBWorkOn;
    end;
  finally
    GlobalSyncRelease;
  end;

  Result := gMG.FObjectPool.Lock(TADOConnection, nil, @nCD,
    function(const nObj: TObject; const nData: Pointer): Boolean
    begin
      Result := (not Assigned(nData)) or (
        (PAdoConnectionData(nData).FConnUser = nStr) or //��ͬ����
        (not TADOConnection(nObj).Connected) or         //��������
        (GetTickCount - PAdoConnectionData(nData).FConneLast > 60 * 1000));
    end) as TADOConnection;
  //��ͬ��������

  with Result do
  begin
    nCD.FConneLast := GetTickCount;
    nCD.FConnected := Connected;
    //conn status

    if nCD.FConnUser <> nStr then
    begin
      nCD.FConnUser := nStr;
      //user data

      Connected := False;
      ConnectionString := nStr;
      LoginPrompt := False;
    end;
  end;
end;

//Date: 2018-04-20
//Parm: ���Ӷ���
//Desc: �ͷ���·
procedure ReleaseDBconn(const nConn: TADOConnection);
begin
  if Assigned(nConn) then
  begin
    gMG.FObjectPool.Release(nConn);
  end;
end;

//Date: 2018-04-20
//Parm: ��������;������ʶ
//Desc: ��ȡ��ѯ����
function LockDBQuery(const nType: TAdoConnectionType;
  const nFactory: string): TADOQuery;
begin
  Result := gMG.FObjectPool.Lock(TADOQuery) as TADOQuery;
  with Result do
  begin
    Close;
    ParamCheck := False;
    Connection := LockDBConn(nType, nFactory);
  end;
end;

//Date: 2018-04-20
//Parm: ��ѯ����;��������
//Desc: �ͷŲ�ѯ����
procedure ReleaseDBQuery(const nQuery: TADOQuery; const nResetConn: Boolean);
var nCD: PAdoConnectionData;
begin
  if Assigned(nQuery) then
  begin
    try
      if nQuery.Active then
        nQuery.Close;
      //xxxxx

      if nResetConn then
      begin
        nCD := gMG.FObjectPool.GetData(TADOConnection, nQuery.Connection);
        if not nCD.FConnected then
          nQuery.Connection.Connected := False;
        //restore old status
      end;
    except
      //ignor any error
    end;

    gMG.FObjectPool.Release(nQuery.Connection);
    gMG.FObjectPool.Release(nQuery);
  end;
end;

//Date: 2018-04-20
//Parm: SQL;��ѯ����
//Desc: ��nQuery��ִ�в�ѯ
function DBQuery(const nStr: string; const nQuery: TADOQuery;
  const nClientDS: TClientDataSet): TDataSet;
begin
  try
    if not nQuery.Connection.Connected then
      nQuery.Connection.Connected := True;
    //xxxxx
    
    nQuery.Close;
    nQuery.SQL.Text := nStr;
    nQuery.Open;

    Result := nQuery;
    //result

    if Assigned(nClientDS) then
      DSClientDS(Result, nClientDS);
    //xxxxx
  except
    nQuery.Connection.Connected := False;
    raise;
  end;
end;

//Date: 2018-04-28
//Parm: �������ݼ�;Զ�����ݼ�
//Desc: ��nDSת��ΪnClientDS
procedure DSClientDS(const nDS: TDataSet; const nClientDS: TClientDataSet);
var nProvider: TDataSetProvider;
begin
  nProvider := nil;
  try
    nProvider := gMG.FObjectPool.Lock(TDataSetProvider) as TDataSetProvider;
    nProvider.DataSet := nDS;

    if nClientDS.Active then
      nClientDS.EmptyDataSet;
    nClientDS.Data := nProvider.Data;

    nClientDS.LogChanges := False;
    nProvider.DataSet := nil;
    //xxxxx
  finally
    gMG.FObjectPool.Release(nProvider);
  end;
end;

//Date: 2018-04-20
//Parm: SQL;��������;��������
//Desc: ��nCmd��ִ��д�����
function DBExecute(const nStr: string; const nCmd: TADOQuery;
  const nType: TAdoConnectionType; const nFactory: string): Integer;
var nC: TADOQuery;
begin
  nC := nil;
  try
    if Assigned(nCmd) then
         nC := nCmd
    else nC := LockDBQuery(nType, nFactory);

    if not nC.Connection.Connected then
      nC.Connection.Connected := True;
    //xxxxx

    with nC do
    try
      Close;
      SQL.Text := nStr;
      Result := ExecSQL;
    except
      nC.Connection.Connected := False;
      raise;
    end;
  finally
    if not Assigned(nCmd) then
      ReleaseDBQuery(nC);
    //xxxxx
  end;
end;

function DBExecute(const nList: TStrings; const nCmd: TADOQuery;
  const nType: TAdoConnectionType; const nFactory: string): Integer;
var nIdx: Integer;
    nC: TADOQuery;
begin
  nC := nil;
  try
    if Assigned(nCmd) then
         nC := nCmd
    else nC := LockDBQuery(nType, nFactory);

    if not nC.Connection.Connected then
      nC.Connection.Connected := True;
    //xxxxx

    Result := 0;
    try
      nC.Connection.BeginTrans;
      //trans start

      for nIdx := 0 to nList.Count-1 do
      with nC do
      begin
        Close;
        SQL.Text := nList[nIdx];
        Result := Result + ExecSQL;
      end;

      nC.Connection.CommitTrans;
      //commit
    except
      on nErr: Exception do
      begin
        nC.Connection.RollbackTrans;
        nC.Connection.Connected := False;
        raise;
      end;
    end;
  finally
    if not Assigned(nCmd) then
      ReleaseDBQuery(nC);
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-22
//Parm: 16λ��������
//Desc: ��ʽ��nCardΪ��׼����
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
var nInt: Int64;
    nIdx: Integer;
begin
  if nHex then
  begin
    Result := '';
    for nIdx:=1 to Length(nCard) do
      Result := Result + IntToHex(Ord(nCard[nIdx]), 2);
    //xxxxx
  end else Result := nCard;

  nInt := StrToInt64('$' + Result);
  Result := IntToStr(nInt);
  Result := StringOfChar('0', 12 - Length(Result)) + Result;
end;

//Date: 2018-04-24
//Parm: �б�;�Ѻø�ʽ
//Desc: ���ڴ�״̬���ݼ��ص��б���
procedure LoadSystemMemoryStatus(const nList: TStrings; const nFriend: Boolean);
var nIdx,nLen: Integer;
begin
  GlobalSyncLock;
  try
    nList.BeginUpdate;
    nList.Clear;

    with TObjectStatusHelper do
    begin
      AddTitle(nList, 'System Buffer');
      nList.Add(FixData('All Users:', gAllUsers.Count));
      nList.Add(FixData('All Menus:', Length(gAllMenus)));
      nList.Add(FixData('All Popedoms:', Length(gAllPopedoms)));
      nList.Add(FixData('All Entitys:', Length(gAllEntitys)));
      nList.Add(FixData('All Factorys:', Length(gAllFactorys)));
    end;

    gMG.FObjectPool.GetStatus(nList, nFriend);
    gMG.FObjectManager.GetStatus(nList, nFriend);
    gMG.FObjectManager.GetStatus(nList, nFriend);
    gMG.FChannelManager.GetStatus(nList, nFriend);

    with TObjectStatusHelper do
    begin
      AddTitle(nList, 'Online Users');
      //online
      nLen := gAllUsers.Count - 1;

      for nIdx := 0 to nLen do
       with PSysParam(gAllUsers[nIdx])^ do
        nList.Add(FixData(Format('%2d.Name: %s', [nIdx+1, FUserID]), Format(
         'IP:%s SYS:%s DESC:%s', [FLocalIP, FOSUser, FUserAgent])));
      //xxxxx
    end;
  finally
    GlobalSyncRelease;
    nList.EndUpdate;
  end;
end;

//Date: 2018-04-24
//Parm: �Ͽ�ȫ���Ự
//Desc: ���ػ���,�Ͽ�ȫ������
procedure ReloadSystemMemory(const nResetAllSession: Boolean);
var nStr: string;
    nIdx: Integer;
    nList: TUniGUISessions;
begin
  if nResetAllSession then
  begin
    nList := UniServerModule.SessionManager.Sessions;
    try
      nList.Lock;
      for nIdx := nList.SessionList.Count-1 downto 0 do
      begin
        nStr := '����Ա����ϵͳ,�����µ�¼';
        TUniGUISession(nList.SessionList[nIdx]).Terminate(nStr);
      end;
    finally
      nList.Unlock;
    end;
  end;

  GlobalSyncLock;
  try
    LoadFactoryList(True);
    //���빤���б�
    LoadPopedomList(True);
    //����Ȩ���б�
    LoadMenuItems(True);
    //����˵���
    LoadEntityList(True);
    //���������ֵ�
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-05-16
//Parm: ��ʾ����
//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nList.Text := nHint;

    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

//Date: 2018-04-24
//Parm: ��������
//Desc: ��ȡnClass��Ķ���
function SystemGetForm(const nClass: string;const nException:Boolean): TUniForm;
var nCls: TClass;
begin
  nCls := GetClass(nClass);
  if Assigned(nCls) then
       Result := TUniForm(UniMainModule.GetFormInstance(nCls))
  else Result := nil;

  if (not Assigned(Result)) and nException then
    UniMainModule.FMainForm.ShowMessage(Format('������[ %s ]��Ч.', [nClass]));
  //xxxxx
end;

//Date: 2018-05-22
//Desc: �����û���ʶ
function UserFlagByID: string;
var nStr: string;
    nIdx: Integer;
begin
  with TEncodeHelper,UniMainModule do
    nStr := EncodeBase64(FUserConfig.FUserID);
  Result := '';

  for nIdx := 1 to Length(nStr) do
   if CharInSet(nStr[nIdx], ['a'..'z', 'A'..'Z','0'..'9']) then
    Result := Result + nStr[nIdx];
  //number & charactor
end;

//Date: 2018-04-26
//Desc: �û��Զ�������
function UserConfigFile: TIniFile;
var nStr: string;
begin
  nStr := gPath + 'users\';
  if not DirectoryExists(nStr) then
    ForceDirectories(nStr);
  //new folder

  nStr := nStr + UserFlagByID + '.ini';
  Result := TIniFile.Create(nStr);

  if not FileExists(nStr) then
  begin
    Result.WriteString('Config', 'User', UniMainModule.FUserConfig.FUserID);
  end;
end;

//Date: 2018-06-13
//Parm: ������
//Desc: ��ȡ�û�ʹ��url��������nParam������ֵ
function GetUserFixParameter(const nParam: string): string;
begin
  Result := Trim(UniApplication.Parameters.Values[nParam]);
end;

//Date: 2018-06-13
//Desc: ��֤�Ƿ���Ҫ��¼
function IfNeedLogin: Boolean;
var nStr: string;
begin
  Result := True;
  nStr := GetUserFixParameter('method');

  if CompareText(nStr, sMethod_FactoryStatus) = 0 then
    Result := False;
  //��ѯ��������״̬
end;
//Date: 2009-6-8
//Parm: ��Ϣ����;��ʶ;�¼�;��������;������ʾ;ִ��;������ʶ;������
//Desc: ��ϵͳ��־��д��һ����־��¼
function WriteSysLog(const nGroup,nItem,nEvent: string;
 const nType: TAdoConnectionType; const nQuery: TADOQuery;
 const nHint,nExec: Boolean; const nKeyID,nMan: string): string;
var nStr,nSQL: string;
begin
  with TStringHelper,UniMainModule do
  begin
    nSQL := 'Insert Into $T(L_Date,L_Man,L_Group,L_ItemID,L_KeyID,L_Event) ' +
            'Values($D,''$M'',''$G'',''$I'',''$K'',''$E'')';
    nSQL := MacroValue(nSQL, [MI('$T', sTable_SysLog),
            MI('$D', sField_SQLServer_Now), MI('$G', nGroup), MI('$I', nItem),
            MI('$E', nEvent), MI('$K', nKeyID)]);
    //xxxxx

    if nMan = '' then
         nStr := FUserConfig.FUserName
    else nStr := nMan;

    nSQL := MacroValue(nSQL, [MI('$M', nStr)]);
    Result := nSQL;

    if nExec then
    try
      DBExecute(nSQL, nQuery, nType);
    except
      if nHint then
        FMainForm.ShowMessage('ϵͳ��־д�����');
      Result := '';
    end;
  end;
end;

//Desc: ��ȡ��������
procedure LoadFormConfig(const nForm: TUniForm; const nIni: TIniFile);
var nC: TIniFile;
begin
  nC := nil;
  try
    if Assigned(nIni) then
         nC := nIni
    else nC := UserConfigFile();

    nForm.Width := nC.ReadInteger(nForm.ClassName, 'Width', nForm.Width);
    nForm.Height := nC.ReadInteger(nForm.ClassName, 'Height', nForm.Height);
  finally
    if not Assigned(nIni) then
      nC.Free;
    //xxxxx
  end;
end;

//Desc: ���洰������
procedure SaveFormConfig(const nForm: TUniForm; const nIni: TIniFile);
var nC: TIniFile;
begin
  nC := nil;
  try
    if Assigned(nIni) then
         nC := nIni
    else nC := UserConfigFile();

    nC.WriteInteger(nForm.ClassName, 'Width', nForm.Width);
    nC.WriteInteger(nForm.ClassName, 'Height', nForm.Height);
  finally
    if not Assigned(nIni) then
      nC.Free;
    //xxxxx
  end;
end;

//Date: 2018-05-08
//Parm: ������,���ݸ�ʽ: ID.Name
//Desc: ��ȡnBox��ǰѡ�еļ�¼ID��
function GetIDFromBox(const nBox: TUniComboBox): string;
begin
  Result := nBox.Text;
  Result := Copy(Result, 1, Pos('.', Result) - 1);
end;

//Date: 2018-05-13
//Parm: ������,���ݸ�ʽ: ID.Name
//Desc: ��ȡnBox��ǰѡ�еļ�¼Name��
function GetNameFromBox(const nBox: TUniComboBox): string;
begin
  Result := nBox.Text;
  System.Delete(Result, 1, Pos('.', Result));
end;


//------------------------------------------------------------------------------
//Date: 2018-04-23
//Parm: ǿ�Ƽ���
//Desc: ��ȡ���ݿ�˵���
procedure LoadMenuItems(const nForce: Boolean);
const
  cItemSize = SizeOf(TMenuItemData);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllMenus);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s ' +
         'Where M_ProgID=''%s'' And M_NewOrder>=0 And M_Title<>''-'' ' +
         'Order By M_NewOrder ASC';
    nStr := Format(nStr, [sTable_Menu, gSysParam.FProgID]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllMenus, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllMenus[nIdx] do
        begin
          FillChar(gAllMenus[nIdx], cItemSize, #0);
          FEntity    := FieldByName('M_Entity').AsString;
          FMenuID    := FieldByName('M_MenuID').AsString;
          FPMenu     := FieldByName('M_PMenu').AsString;
          FTitle     := FieldByName('M_Title').AsString;
          FImgIndex  := FieldByName('M_ImgIndex').AsInteger;
          FFlag      := FieldByName('M_Flag').AsString;
          FAction    := FieldByName('M_Action').AsString;
          FFilter    := FieldByName('M_Filter').AsString;
          FNewOrder  := FieldByName('M_NewOrder').AsFloat;
          FLangID    := 'cn';
        end;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-23
//Parm: �б���;ʵ������
//Desc: �����˵��б�nTree
procedure BuidMenuTree(const nTree: TUniTreeView; nEntity: string);
var nIdx,nInt: Integer;
    nGroup: Integer;
    nItem: TuniTreeNode;

  //Desc: �����nItem�Ƿ��пɶ�Ȩ��
  function HasPopedom(const nMItem: string): Boolean;
  var i: Integer;
  begin
    Result := UniMainModule.FUserConfig.FIsAdmin;
    if Result then Exit;
    
    with gAllPopedoms[nGroup] do
    begin
      for i := Low(FPopedom) to High(FPopedom) do
      if CompareText(nMItem, FPopedom[i].FItem) = 0 then
      begin 
        Result := Pos(sPopedom_Read, FPopedom[i].FPopedom) > 0;
        Exit;
      end;
    end;
  end;

  //Desc: �����ӽڵ�
  procedure MakeChileMenu(const nParent: TuniTreeNode);
  var i,nTag: Integer;
      nSub: TuniTreeNode;
  begin
    for i := 0 to nInt do
    with gAllMenus[i] do
    begin
      if CompareText(FEntity, nEntity) <> 0 then Continue;
      //not match entity

      nTag := Integer(nParent.Data);
      if CompareText(FPMenu, gAllMenus[nTag].FMenuID) <> 0 then Continue;
      //not sub item

      if not HasPopedom(MakeMenuID(FEntity, FMenuID)) then Continue;
      //no popedom

      nSub := nTree.Items.AddChild(nParent, FTitle);
      nSub.Data := Pointer(i);
      MakeChileMenu(nSub);
    end;
  end;
begin
  if nEntity='' then
    nEntity := 'MAIN';
  //main menu

  GlobalSyncLock;
  try
    nTree.Items.BeginUpdate;
    nTree.Items.Clear;
    nGroup := -1;

    for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
    if gAllPopedoms[nIdx].FID = UniMainModule.FUserConfig.FGroupID then
    begin
      nGroup := nIdx;
      Break;
    end;

    if nGroup < 0 then
    begin
      nTree.Items.AddChild(nil, 'Ȩ�޲���');
      Exit;
    end;

    nInt := Length(gAllMenus)-1;
    for nIdx := 0 to nInt do
    with gAllMenus[nIdx] do
    begin
      if CompareText(FEntity, nEntity) <> 0 then Continue;
      //not match entity
      if (FMenuID = '') or (FPMenu <> '') then Continue;
      //not root item
      if not HasPopedom(MakeMenuID(FEntity, FMenuID)) then Continue;
      //no popedom

      nItem := nTree.Items.AddChild(nil, FTitle);
      nItem.Data := Pointer(nIdx);
    end;

    nItem := nTree.Items.GetFirstNode;
    while Assigned(nItem) do
    begin
      MakeChileMenu(nItem);
      nItem := nItem.GetNextSibling;
    end;
  finally
    GlobalSyncRelease;
    nTree.Items.EndUpdate;
  end;

  {$IFDEF DEBUG}
  nTree.FullExpand;
  {$ENDIF}
end;

//Date: 2018-04-24
//Parm: �˵�������
//Desc: ��ȡnIdx�Ĳ˵���ʶ
function GetMenuItemID(const nIdx: Integer): string;
begin
  GlobalSyncLock;
  try
    Result := '';
    if (nIdx >= Low(gAllMenus)) and (nIdx <= High(gAllMenus)) then
     with gAllMenus[nIdx] do
      Result := MakeMenuID(FEntity, FMenuID);
    //xxxxx
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-26
//Parm: ģ������
//Desc: ����ģ��ΪnModule�Ĳ˵���
function GetMenuByModule(const nModule: string): string;
var nIdx: Integer;
begin
  with UniMainModule do
  begin
    Result := '';
    //init

    for nIdx := Low(FMenuModule) to High(FMenuModule) do
    with FMenuModule[nIdx] do
    begin
      if CompareText(nModule, FModule) = 0 then
      begin
        Result := FMenuID;
        Exit;
      end;
    end;
  end;
end;

//Date: 2018-04-26
//Parm: �˵���
//Desc: �����˵���ΪnMenu��ģ��
function GetModuleByMenu(const nMenu: string): string;
var nIdx: Integer;
begin
  with UniMainModule do
  begin
    Result := '';
    //init

    for nIdx := Low(FMenuModule) to High(FMenuModule) do
    with FMenuModule[nIdx] do
    begin
      if CompareText(nMenu, FModule) = 0 then
      begin
        Result := FModule;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-24
//Parm: ǿ�Ƹ���
//Desc: ���ع����б��ڴ�
procedure LoadFactoryList(const nForce: Boolean);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllFactorys);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s Where F_Valid=''%s'' Order By F_Index ASC';
    nStr := Format(nStr, [sTable_Factorys, sFlag_Yes]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllFactorys, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllFactorys[nIdx] do
        begin
          FFactoryID  := FieldByName('F_ID').AsString;
          FFactoryName:= FieldByName('F_Name').AsString;
          FMITServURL := FieldByName('F_MITUrl').AsString;
          FHardMonURL := FieldByName('F_HardUrl').AsString;
          FWechatURL  := FieldByName('F_WechatUrl').AsString;
          FDBWorkOn   := FieldByName('F_DBConn').AsString;
        end;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-24
//Parm: �б�
//Desc: ���ع����б�nList��
procedure GetFactoryList(const nList: TStrings);
var nIdx: Integer;
begin
  GlobalSyncLock;
  try
    nList.BeginUpdate;
    nList.Clear;

    for nIdx := Low(gAllFactorys) to High(gAllFactorys) do
     with gAllFactorys[nIdx] do
      nList.AddObject(FFactoryID + '.' + FFactoryName, Pointer(nIdx));
    //xxxxx
  finally
    GlobalSyncRelease;
    nList.EndUpdate;
  end;
end;

//Date: 2018-04-24
//Parm: ����;��������
//Desc: ��ȡnIdx�����ݵ�nFactory
function GetFactory(const nIdx: Integer; var nFactory: TFactoryItem): Boolean;
begin
  GlobalSyncLock;
  try
    Result := (nIdx >= Low(gAllFactorys)) and (nIdx <= High(gAllFactorys));
    if Result then
      nFactory := gAllFactorys[nIdx];
    //xxxxx
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-24
//Parm: ǿ�Ƽ���
//Desc: ����Ȩ�޵��ڴ�
procedure LoadPopedomList(const nForce: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllPopedoms);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query
    nStr := 'Select * From ' + sTable_Group;

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllPopedoms, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllPopedoms[nIdx] do
        begin
          FID       := FieldByName('G_ID').AsString;
          FName     := FieldByName('G_NAME').AsString;
          FDesc     := FieldByName('G_DESC').AsString;
          SetLength(FPopedom, 0);
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From ' + sTable_Popedom;
    //Ȩ�ޱ�

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
      with gAllPopedoms[nIdx] do
      begin
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
            Inc(nInt);
          Next;
        end;

        SetLength(FPopedom, nInt);
        nInt := 0;
        First;

        while not Eof do
        begin
          if FieldByName('P_Group').AsString = FID then
          begin
            with FPopedom[nInt] do
            begin
              FItem := FieldByName('P_Item').AsString;
              FPopedom := FieldByName('P_Popedom').AsString;
            end;

            Inc(nInt);
          end;

          Next;
        end;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-04-26
//Parm: �˵���
//Desc: ��ȡ��ǰ�û���nMenu��ӵ�е�Ȩ��
function GetPopedom(const nMenu: string): string;
var nIdx,nGroup: Integer;
begin
  with UniMainModule do
  try
    GlobalSyncLock;
    Result := '';
    nGroup := -1;

    for nIdx := Low(gAllPopedoms) to High(gAllPopedoms) do
    if gAllPopedoms[nIdx].FID = FUserConfig.FGroupID then
    begin
      nGroup := nIdx;
      Break;
    end;

    if nGroup < 0 then Exit;
    //no group match

    with gAllPopedoms[nGroup] do
    begin
      for nIdx := Low(FPopedom) to High(FPopedom) do
      if CompareText(nMenu, FPopedom[nIdx].FItem) = 0 then
      begin
        Result := FPopedom[nIdx].FPopedom;
        Exit;
      end;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-26
//Parm: �˵���;Ȩ����
//Desc: �жϵ�ǰ�û���nMenu�Ƿ���nPopedomȨ��
function HasPopedom(const nMenu,nPopedom: string): Boolean;
begin
  with UniMainModule do
  begin
    Result := FUserConfig.FIsAdmin or (Pos(nPopedom, GetPopedom(nMenu)) > 0);
  end;
end;

//Date: 2018-04-26
//Parm: Ȩ����;Ȩ����
//Desc: ���nAll���Ƿ���nPopedomȨ����
function HasPopedom2(const nPopedom,nAll: string): Boolean;
begin
  with UniMainModule do
  begin
    Result := FUserConfig.FIsAdmin or (Pos(nPopedom, nAll) > 0);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-04-26
//Parm: ǿ��ˢ��
//Desc: ���������ֵ�
procedure LoadEntityList(const nForce: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nIdx := Length(gAllEntitys);
    if (nIdx > 0) and (not nForce) then Exit;

    nQuery := LockDBQuery(ctMain);
    //get query

    nStr := 'Select * From %s Where E_ProgID=''%s''';
    nStr := Format(nStr, [sTable_Entity, gSysParam.FProgID]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gAllEntitys, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gAllEntitys[nIdx] do
        begin
          FEntity := FieldByName('E_Entity').AsString;
          FTitle  := FieldByName('E_Title').AsString;
          SetLength(FDictItem, 0);
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From %s Order By D_Index ASC';
    nStr := Format(nStr, ['Sys_DataDict']);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      for nIdx := Low(gAllEntitys) to High(gAllEntitys) do
      with gAllEntitys[nIdx] do
      begin
        nStr := gSysParam.FProgID + '_' + FEntity;
        nInt := 0;
        First;

        while not Eof do
        begin
          if CompareText(nStr, FieldByName('D_Entity').AsString) = 0 then
            Inc(nInt);
          Next;
        end;

        if nInt < 1 then Continue;
        //no entity detail

        SetLength(FDictItem, nInt);
        nInt := 0;
        First;

        while not Eof  do
        begin
          if CompareText(nStr, FieldByName('D_Entity').AsString) = 0 then
          with FDictItem[nInt] do
          begin
            FItemID  := FieldByName('D_ItemID').AsInteger;
            FTitle   := FieldByName('D_Title').AsString;
            FAlign   := TAlignment(FieldByName('D_Align').AsInteger);
            FWidth   := FieldByName('D_Width').AsInteger;
            FIndex   := FieldByName('D_Index').AsInteger;
            FVisible := StrToBool(FieldByName('D_Visible').AsString);
            FLangID  := FieldByName('D_LangID').AsString;

            with FDBItem do
            begin
              FTable := FieldByName('D_DBTable').AsString;
              FField := FieldByName('D_DBField').AsString;
              FIsKey := StrToBool(FieldByName('D_DBIsKey').AsString);

              FType  := TFieldType(FieldByName('D_DBType').AsInteger);
              FWidth := FieldByName('D_DBWidth').AsInteger;
              FDecimal:= FieldByName('D_DBDecimal').AsInteger;
            end;

            with FFormat do
            begin
              FStyle  := TDictFormatStyle(FieldByName('D_FmtStyle').AsInteger);
              FData   := FieldByName('D_FmtData').AsString;
              FFormat := FieldByName('D_FmtFormat').AsString;
              FExtMemo:= FieldByName('D_FmtExtMemo').AsString;
            end;

            with FFooter do
            begin
              FDisplay := FieldByName('D_FteDisplay').AsString;
              FFormat := FieldByName('D_FteFormat').AsString;
              FKind := TDictFooterKind(FieldByName('D_FteKind').AsInteger);
              FPosition := TDictFooterPosition(FieldByName('D_FtePositon').AsInteger);
            end;

            Inc(nInt);
          end;

          Next;
        end;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-05-11
//Parm: ���ݼ�
//Desc: ����nClientDS��������
procedure BuidDataSetSortIndex(const nClientDS: TClientDataSet);
var nStr: string;
    nIdx: Integer;
begin
  with nClientDS do
  begin
    for nIdx := FieldCount-1 downto 0 do
    begin
      nStr := Fields[nIdx].FieldName + '_asc';
      if IndexDefs.IndexOf(nStr) < 0 then
        IndexDefs.Add(nStr, Fields[nIdx].FieldName, []);
      //xxxxx

      nStr := Fields[nIdx].FieldName + '_des';
      if IndexDefs.IndexOf(nStr) < 0 then
        IndexDefs.Add(nStr, Fields[nIdx].FieldName, [ixDescending]);
      //xxxxx
    end;
  end;
end;

//Date: 2018-04-26
//Parm: ʵ������;�б�;�ų��ֶ�
//Desc: ʹ�������ֵ�nEntity����nGrid�ı�ͷ
procedure BuildDBGridColumn(const nEntity: string; const nGrid: TUniDBGrid;
 const nFilter: string);
var i,nIdx: Integer;
    nList: TStrings;
    nColumn: TUniBaseDBGridColumn;
begin
  with nGrid do
  begin
    BorderStyle := ubsDefault;
    LoadMask.Message := '��������';
    Options := [dgTitles, dgIndicator, dgColLines, dgRowLines, dgRowSelect];

    if UniMainModule.FGridColumnAdjust then
      Options := Options + [dgColumnResize, dgColumnMove];
    //ѡ�����

    if Pos('beforeinit', ClientEvents.UniEvents.Text.ToLower) < 1 then
    begin
      ClientEvents.UniEvents.Add('beforeInit=function beforeInit(sender,' +
        'config){config.viewConfig.enableTextSelection = true;}');
      //��Ԫ���ѡ
    end;

    ReadOnly := True;
    WebOptions.Paged := True;
    WebOptions.PageSize := 1000;

    if not Assigned(OnColumnSort) then
      OnColumnSort := UniMainModule.DoColumnSort;
    if not Assigned(OnColumnSummary) then
      OnColumnSummary := UniMainModule.DoColumnSummary;
    if not Assigned(OnColumnSummaryResult) then
      OnColumnSummaryResult := UniMainModule.DoColumnSummaryResult;
    //xxxxx
  end;

  if nEntity = '' then Exit;
  //manual column

  nList := nil;
  try
    GlobalSyncLock;
    nGrid.Columns.BeginUpdate;
    nIdx := -1;
    //init

    for i := Low(gAllEntitys) to High(gAllEntitys) do
    if CompareText(nEntity, gAllEntitys[i].FEntity) = 0 then
    begin
      nIdx := i;
      Break;
    end;

    if nIdx < 0 then Exit;
    //no entity match

    if nFilter <> '' then
    begin
      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      TStringHelper.Split(nFilter, nList, 0, ';');
    end;

    with gAllEntitys[nIdx],nGrid do
    begin
      with Summary do
      begin
        Enabled := False;
        GrandTotal := False;
      end;

      Tag := nIdx;
      Columns.Clear;
      //clear first

      for i := Low(FDictItem) to High(FDictItem) do
      with FDictItem[i] do
      begin
        if not FVisible then Continue;

        if Assigned(nList) and (nList.IndexOf(FDBItem.FField) >= 0) then
          Continue;
        //�ֶα�����,������ʾ

        nColumn := Columns.Add;
        with nColumn do
        begin
          Tag := i;
          Sortable := True;
          Alignment := FAlign;
          FieldName := FDBItem.FField;

          Title.Alignment := FAlign;
          Title.Caption := FTitle;
          Width := FWidth;

          if (FFooter.FKind = fkSum) or (FFooter.FKind = fkCount) then
          begin
            nColumn.ShowSummary := True;
            Summary.Enabled := True;
          end;
        end;
      end;
    end;
  finally
    GlobalSyncRelease;
    gMG.FObjectPool.Release(nList);
    nGrid.Columns.EndUpdate;
  end;
end;

//Date: 2018-05-10
//Parm: ʵ��;���ݼ�;�����¼�
//Desc: ����nClientDS���ݸ�ʽ��
procedure SetGridColumnFormat(const nEntity: string;
  const nClientDS: TClientDataSet; const nOnData: TFieldGetTextEvent);
var nIdx,nEn,nL,nH: Integer;
    nField: TField;
begin
  try
    GlobalSyncLock;
    nEn := -1;
    //init

    for nIdx := Low(gAllEntitys) to High(gAllEntitys) do
    if CompareText(nEntity, gAllEntitys[nIdx].FEntity) = 0 then
    begin
      nEn := nIdx;
      Break;
    end;

    if nEn < 0 then Exit;
    //no entity match
    nClientDS.Tag := nEn;

    nL := Low(gAllEntitys[nEn].FDictItem);
    nH := High(gAllEntitys[nEn].FDictItem);

    for nIdx := nL to nH do
    with gAllEntitys[nEn].FDictItem[nIdx] do
    begin
      if FFormat.FStyle <> fsFixed then Continue;
      if Trim(FFormat.FData) = '' then Continue;

      nField := nClientDS.FindField(FDBItem.FField);
      if Assigned(nField) then
      begin
        nField.Tag := nIdx;
        nField.OnGetText := nOnData;
      end;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Date: 2018-04-27
//Parm: ������;���;��ȡ
//Desc: ��дnForm.nGrid���û�����
procedure UserDefineGrid(const nForm: string; const nGrid: TUniDBGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
var nStr: string;
    i,j,nCount: Integer;
    nTmp: TIniFile;
    nList: TStrings;
begin
  nTmp := nil;
  nList := nil;

  with TStringHelper do
  try
    if Assigned(nIni) then
         nTmp := nIni
    else nTmp := UserConfigFile;

    nCount := nGrid.Columns.Count - 1;
    //column num

    if nLoad then
    begin
      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      nStr := nTmp.ReadString(nForm, 'GridIndex_' + nGrid.Name, '');
      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for i := 0 to nCount do
        begin
          if not IsNumber(nList[i], False) then Continue;
          //not valid

          for j := 0 to nCount do
          if nGrid.Columns[j].Tag = StrToInt(nList[i]) then
          begin
            nGrid.Columns[j].Index := i;
            Break;
          end;
        end;
      end;

      nStr := nTmp.ReadString(nForm, 'GridWidth_' + nGrid.Name, '');
      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for i := 0 to nCount do
         if IsNumber(nList[i], False) then
          nGrid.Columns[i].Width := StrToInt(nList[i]);
        //apply width
      end;

      if not UniMainModule.FGridColumnAdjust then //����ʱȫ����ʾ
      begin
        nStr := nTmp.ReadString(nForm, 'GridVisible_' + nGrid.Name, '');
        if Split(nStr, nList, nGrid.Columns.Count) then
        begin
          for i := 0 to nCount do
            nGrid.Columns[i].Visible := nList[i] = '1';
          //apply visible
        end;
      end;
    end else
    begin
      if UniMainModule.FGridColumnAdjust then //save manual adjust grid
      begin
        nStr := '';
        for i := 0 to nCount do
        begin
          nStr := nStr + IntToStr(nGrid.Columns[i].Tag);
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridIndex_' + nGrid.Name, nStr);

        nStr := '';
        for i := 0 to nCount do
        begin
          nStr := nStr + IntToStr(nGrid.Columns[i].Width);
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridWidth_' + nGrid.Name, nStr);
      end else
      begin
        nStr := '';
        for i := 0 to nCount do
        begin
          if nGrid.Columns[i].Visible then
               nStr := nStr + '1'
          else nStr := nStr + '0';
          if i <> nCount then nStr := nStr + ';';
        end;
        nTmp.WriteString(nForm, 'GridVisible_' + nGrid.Name, nStr);
      end;
    end;
  finally
    gMG.FObjectPool.Release(nList);
    if not Assigned(nIni) then
      nTmp.Free;
    //xxxxx
  end;
end;

//Date: 2018-05-24
//Parm: ������;���;��ȡ
//Desc: ��дnForm.nGrid���û�����
procedure UserDefineStringGrid(const nForm: string; const nGrid: TUniStringGrid;
  const nLoad: Boolean; const nIni: TIniFile = nil);
var nStr: string;
    nIdx,nCount: Integer;
    nTmp: TIniFile;
    nList: TStrings;
begin
  nTmp := nil;
  nList := nil;

  with TStringHelper do
  try
    if Assigned(nIni) then
         nTmp := nIni
    else nTmp := UserConfigFile;

    nCount := nGrid.Columns.Count - 1;
    //column num

    if nLoad then
    begin
      nStr := 'columnresize=function columnresize(ct,column,width,eOpts){'+
        'ajaxRequest($O, ''$E'', [''idx=''+column.dataIndex,''w=''+width])}';
      //add resize event

      nStr := MacroValue(nStr, [MI('$O', nForm + '.' + nGrid.Name),
        MI('$E', sEvent_StrGridColumnResize)]);
      //xxxx

      nIdx := nGrid.ClientEvents.ExtEvents.IndexOf(nStr);
      if UniMainModule.FGridColumnAdjust and (nIdx < 0) then
      begin
        nGrid.Options := nGrid.Options + [goColSizing];
        //��ӿɵ��п�

        nGrid.ClientEvents.ExtEvents.Add(nStr);
        //����¼�����

        if not Assigned(nGrid.OnAjaxEvent) then
          nGrid.OnAjaxEvent := UniMainModule.DoDefaultAdjustEvent;
        //����¼�����
      end else
      begin
        nGrid.Options := nGrid.Options - [goColSizing];
        //ɾ���ɵ��п�

        if nIdx >= 0 then
          nGrid.ClientEvents.ExtEvents.Delete(nIdx);
        //xxxxx
      end;

      nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
      nStr := nTmp.ReadString(nForm, 'GridWidth_' + nGrid.Name, '');

      if Split(nStr, nList, nGrid.Columns.Count) then
      begin
        for nIdx := 0 to nCount do
         if (nGrid.Columns[nIdx].Width>0) and IsNumber(nList[nIdx], False) then
          nGrid.Columns[nIdx].Width := StrToInt(nList[nIdx]);
        //apply width
      end;
    end else

    if UniMainModule.FGridColumnAdjust then    
    begin
      nStr := '';
      for nIdx := 0 to nCount do
      begin
        nStr := nStr + IntToStr(nGrid.Columns[nIdx].Width);
        if nIdx <> nCount then nStr := nStr + ';';
      end;
      nTmp.WriteString(nForm, 'GridWidth_' + nGrid.Name, nStr);
    end;
  finally
    gMG.FObjectPool.Release(nList);
    if not Assigned(nIni) then
      nTmp.Free;
    //xxxxx
  end;
end;

//Date: 2018-05-24
//Parm: ���;����
//Desc: �û������п�ʱ����,���û������Ľ��Ӧ�õ�nGrid.
procedure DoStringGridColumnResize(const nGrid: TObject;
  const nParam: TUniStrings);
var nStr: string;
    nIdx,nW: Integer;
begin
  with TStringHelper,TUniStringGrid(nGrid) do
  begin
    nStr := nParam.Values['idx'];
    if IsNumber(nStr, False) then
         nIdx := StrToInt(nStr)
    else nIdx := -1;

    if (nIdx < 0) or (nIdx >= Columns.Count) then Exit;
    //out of range

    nStr := nParam.Values['w'];
    if IsNumber(nStr, False) then
         nW := StrToInt(nStr)
    else nW := -1;

    if nW < 0 then Exit;
    if nW > 320 then
      nW := 320;
    Columns[nIdx].Width := nW;
  end;
end;

//Date: 2018-05-04
//Parm: �б���;���
//Desc: ʹ��nWideths����nGrid��ͷ���
procedure LoadGridColumn(const nWidths: string; const nGrid: TUniStringGrid);
var nList: TStrings;
    i,nCount: integer;
begin
  with nGrid do
  begin
    FixedCols := 0;
    FixedRows := 0;
    BorderStyle := ubsDefault;
    Options := [goVertLine,goHorzLine,goColSizing,goRowSelect];
    //style
  end;

  if (nWidths <> '') and (nGrid.Columns.Count > 0) then
  begin
    nList := TStringList.Create;
    try
      if TStringHelper.Split(nWidths, nList, nGrid.Columns.Count, ';') then
      begin
        nCount := nList.Count - 1;
        for i:=0 to nCount do
         if TStringHelper.IsNumber(nList[i], False) then
          nGrid.Columns[i].Width := StrToInt(nList[i]);
      end;
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2018-05-04
//Parm: ���
//Desc: ����nGrid��ͷ����ַ���
function MakeGridColumnInfo(const nGrid: TUniStringGrid): string;
var i,nCount: integer;
begin
  Result := '';
  nCount := nGrid.Columns.Count - 1;

  for i:=0 to nCount do
  if i = nCount then
       Result := Result + IntToStr(nGrid.Columns[i].Width)
  else Result := Result + IntToStr(nGrid.Columns[i].Width) + ';';
end;

initialization
  gSyncLock := TCriticalSection.Create;
finalization
  FreeAndNil(gSyncLock);
end.


