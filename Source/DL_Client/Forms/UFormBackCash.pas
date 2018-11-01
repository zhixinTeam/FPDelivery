unit UFormBackCash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMemo,
  dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormBackCash = class(TfFormNormal)
    EditWeek: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Item4: TdxLayoutItem;
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FNowYear,FNowWeek,FWeekName: string;
    FLastInterval: Cardinal;  //�ϴ�ִ��
    procedure InitFormData;
    procedure ShowNowWeek;
    procedure ShowHintText(const nText: string);
    function GetBackRule(nZhiKa,nStockNo:string;nTotal:Double):Double;
    procedure BackCash;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormBackCash: TfFormBackCash;

implementation

{$R *.dfm}

uses
  USysConst, UFormBase, USysDB, UMgrControl, ULibFun, UDataModule, UFormCtrl;

{ TfFormBackCash }

class function TfFormBackCash.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  with TfFormBackCash.Create(Application) do
  try
    Caption := '����(ȫ���ͻ�)';
    InitFormData;
    ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBackCash.FormID: integer;
begin
  Result := cFI_FormBackCash;
end;

procedure TfFormBackCash.InitFormData;
var nP: TFormCommandParam;
begin
  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  nP.FCommand := cCmd_GetData;
  
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  nP.FParamE := sFlag_Yes;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if nP.FCommand = cCmd_ModalResult then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;

  ShowNowWeek;
end;

procedure TfFormBackCash.ShowNowWeek;
begin
  if FNowWeek = '' then
       EditWeek.Text := '��ѡ���������'
  else EditWeek.Text := Format('%s ���:[ %s ]', [FWeekName, FNowYear]);

  EditWeek.SelStart := 0;
  EditWeek.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TfFormBackCash.EditWeekPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_GetData;
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;

  ShowNowWeek;
end;

procedure TfFormBackCash.BtnOKClick(Sender: TObject);
//begin
//  BackCash;
//end;
var
  nStr, nSql:string;
  nDBegin,nDEnd: string;  //�������ڿ�ʼ��������
  nTotal, nRule, nValue, nOldValue:Double;  //�������,���ֵ���
  nZhika,nStockNo,nCusId: string;
  RId:string;
  FList: TStrings;
  i: Integer;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('��ѡ����Ч������', sHint);
    Exit;
  end;

  ShowHintText('��ʼ���㷵��,�˹��̽���,�����ĵȴ�...');

  FList := TStringList.Create;
  FList.Clear;

  nStr := 'select W_Begin,W_End,W_Chk from %s where W_NO=''%s''';
  nStr := Format(nStr,[sTable_InvoiceWeek,FNowWeek]);
  with FDM.QueryTemp(nStr) do
  begin
    if FieldByName('W_Chk').AsString = sFlag_Yes then
    begin
      ShowMsg('�������Ѿ��������,�����ظ�����.',sHint);
      Exit;
    end;
    nDBegin := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_Begin').AsDateTime);
    nDEnd := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_End').AsDateTime +1) ;
  end;

  nStr := 'select L_CusID,L_ZhiKa,L_StockNo,SUM(L_Value)as L_Value from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s'' group by L_CusID,L_ZhiKa,L_StockNo';
  nStr := Format(nStr, [sTable_Bill,nDBegin,nDEnd]);
  //���ͻ���ֽ����Ʒ�ֲ�ѯ�������ܷ�����

  with FDM.QuerySQL(nStr) do
  begin
    if RecordCount = 0 then
    begin
      ShowHintText('����������û�з��������ļ�¼');
      Exit;
    end;

    ShowHintText('��ʼ���ɽ�������');

    First;
    while not Eof do
    begin
      nZhika := FieldByName('L_ZhiKa').asstring;
      nStockNo := FieldByName('L_StockNo').asstring;
      nTotal := FieldByName('L_Value').AsFloat;
      nCusId := FieldByName('L_CusID').AsString;

      nRule := GetBackRule(nZhika,nStockNo,nTotal); //��ȡ���ֹ��� --  ���ֵ���
      nvalue := nRule * nTotal;

      if nRule = 0 then
      begin
        Next;
        Continue;
      end;

      nSql := MakeSQLByStr([
          SF('R_CusId', nCusId),
          SF('R_WeekNo', FNowWeek),
          SF('R_WeekName', FWeekName),
          SF('R_ZhiKa', nZhika),
          SF('R_StockNo', nStockNo),
          SF('R_Rule', nRule, sfVal),
          SF('R_Total', nTotal, sfVal),
          SF('R_Value', StrToFloat(Format('%.2f', [nValue])), sfVal),
          SF('R_Date', Now),
          SF('R_Valid', sFlag_No),
          SF('R_User', gSysParam.FUserID)
          ], sTable_BackRecord, '', True);
      //FDM.ExecuteSQL(nSql);
      FList.Add(nSql);

      nSql := 'Update %s set A_Compensation=A_Compensation-%s where A_CId=''%s''';
      nSql := Format(nSql,[sTable_CusAccount,Format('%.2f',[nvalue]),nCusId]);
      //FDM.ExecuteSQL(nSql);
      FList.Add(nSql);

      nSql := 'select L_id from %s where  L_OutFact>=''%s'' and L_OutFact<''%s'''+
              ' and L_Cusid=''%s'' and L_ZhiKa=''%s''';
      nSql := Format(nSql,[sTable_Bill, nDBegin, nDEnd, nCusId, nZhika]);
      with FDM.QueryTemp(nSql) do
      begin
        //�������뷵�ּ�¼��bill��
        if recordcount >0  then
        begin
          first;
          while not Eof do
          begin
            nSql := 'insert into S_Bill(L_ID,L_ZhiKa,L_Project,L_CusID,L_CusName,L_CusPY, '+
                    'L_SaleID,L_SaleMan,L_Type,L_StockNo,L_StockName,L_Truck,L_Status, '+
                    'L_InTime,L_OutFact,L_PValue,L_MValue,L_Value,L_Price,l_BillType,'+
                    'L_Date,L_ZKMoney,L_PDate,L_PMan,L_MDate,L_MMan,L_LadeLine,L_LineName,L_OutMan,L_Lading,L_IsVIP,L_Man)'+
                    'select L_ID,L_ZhiKa,L_Project,L_CusID,L_CusName,L_CusPY,'+
                    'L_SaleID,L_SaleMan,L_Type,L_StockNo,L_StockName,L_Truck,L_Status,'+
                    'L_InTime,L_OutFact,L_PValue,L_MValue,0 as L_Value,%s as L_Price,''%s'','+
                    'L_Date,L_ZKMoney,L_PDate,L_PMan,L_MDate,L_MMan,L_LadeLine,L_LineName,L_OutMan,L_Lading,L_IsVIP,L_Man '+
                    'from S_Bill where L_ID=''%s''';
            nSql := Format(nSql,['-'+floattostr(nRule),sFlag_Yes,FieldByName('L_ID').AsString]);
            FList.Add(nSql);

            Next;
          end;
        end;
      end;

      Next;
    end;
    nSql := 'update %s set W_Chk=''%s'' where W_NO=''%s''';
    nSql := Format(nSql,[sTable_InvoiceWeek,sFlag_Yes,FNowWeek]);
    FList.Add(nSql);
  end;

  ShowHintText('��ʼִ�н���...');
  FDM.ADOConn.BeginTrans ;
  try
    for i := 0 to FList.Count- 1 do
      fdm.ExecuteSQL(FList[i]);

    FDM.ADOConn.CommitTrans;
    FList.Free;
    ShowHintText('�������.');
  except
    fdm.ADOConn.RollbackTrans;
    ShowHintText('����ʧ��.');
    exit;
  end; 
end;

{nSql := 'select * from %s where R_CusId=''%s'' and R_ZhiKa=''%s'' and '+
                'R_StockNo=''%s'' and R_Valid<>''%s'' and R_WeekNo=''%s''';
        nSql := Format(nSql,[sTable_BackRecord,nCusId,nZhika,nStockNo,sFlag_Yes,FNowWeek]);
        //��ѯ�ϴα����ڷ������
        with FDM.QueryTemp(nSql) do
        begin
          if RecordCount = 0 then
          begin
            nSql := MakeSQLByStr([
                SF('R_CusId', nCusId),
                SF('R_WeekNo', FNowWeek),
                SF('R_WeekName', FWeekName),
                SF('R_ZhiKa', nZhika),
                SF('R_StockNo', nStockNo),
                SF('R_Rule', nRule, sfVal),
                SF('R_Total', nTotal, sfVal),
                SF('R_Value', StrToFloat(Format('%.2f', [nValue])), sfVal),
                SF('R_Date', Now),
                SF('R_Valid', sFlag_No),
                SF('R_User', gSysParam.FUserID)
                ], sTable_BackRecord, '', True);
            FDM.ExecuteSQL(nSql);

            nSql := 'Update %s set A_Compensation=A_Compensation-%s where A_CId=''%s''';
            nSql := Format(nSql,[sTable_CusAccount,Format('%.2f',[nvalue]),nCusId]);
            FDM.ExecuteSQL(nSql);
          end
          else
          begin
            RId := FieldByName('R_Id').asstring;
            nOldValue :=FieldByName('R_Value').AsFloat;

            //�޸��ϴη��ּ�¼Ϊ��Ч
            nSql := 'update %s set R_Valid=''%s'' where R_id=%s';
            nSql := Format(nSql,[sTable_BackRecord,sFlag_Yes,RId]);
            FDM.ExecuteSQL(nSql);

            nSql := MakeSQLByStr([
                SF('R_CusId', nCusId),
                SF('R_WeekNo', FNowWeek),
                SF('R_WeekName', FWeekName),
                SF('R_ZhiKa', nZhika),
                SF('R_StockNo', nStockNo),
                SF('R_Rule', nRule, sfVal),
                SF('R_Total', nTotal, sfVal),
                SF('R_Value', StrToFloat(Format('%.2f', [nValue])), sfVal),
                SF('R_Date', Now),
                SF('R_Valid', sFlag_No),
                SF('R_User', gSysParam.FUserID)
                ], sTable_BackRecord, '', True);
            FDM.ExecuteSQL(nSql);

            nValue := nValue - nOldValue;

            nSql := 'Update %s set A_Compensation=A_Compensation-%s where A_CId=''%s''';
            nSql := Format(nSql,[sTable_CusAccount,Format('%.2f',[nvalue]),nCusId]);
            FDM.ExecuteSQL(nSql);
          end;
        end;}

procedure TfFormBackCash.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
  Application.ProcessMessages;

  if GetTickCount - FLastInterval < 500 then
    Sleep(375);
  FLastInterval := GetTickCount;
end;

//��ȡ���ֹ���
function TfFormBackCash.GetBackRule(nZhiKa, nStockNo: string;
  nTotal: Double): Double;
var
  nSql:string;
begin
  nSql := 'select * from %s where B_ZhiKa=''%s'' and B_StockNo=''%s'' and '+
          'B_LeaveL<= %.2f and B_LeaveH > %.2f';
  nSql := Format(nSql,[sTable_BackCashRule, nZhika, nStockNo, nTotal, nTotal]);
  with FDM.QueryTemp(nSql) do
  begin
    if RecordCount = 0 then
      Result := 0
    else
      Result := FieldByName('B_Value').AsFloat;
  end;
end;

procedure TfFormBackCash.BackCash;
var
  nStr, nSql:string;
  nDBegin,nDEnd: string;  //�������ڿ�ʼ��������
  nTotal, nRule, nValue, nOldValue:Double;  //�������,���ֵ���
  nZhika,nStockNo,nCusId: string;
  RId:string;
  nVal,nVal2: Double;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('��ѡ����Ч������', sHint);
    Exit;
  end;

  ShowHintText('��ʼ���㷵��,�˹��̽���,�����ĵȴ�...');

  nStr := 'select W_Begin,W_End,W_ZZInfo from %s where W_NO=''%s''';
  nStr := Format(nStr,[sTable_InvoiceWeek,FNowWeek]);
  with FDM.QueryTemp(nStr) do
  begin
    if FieldByName('W_ZZInfo').AsString = 'Y' then
    begin
      ShowMsg('�������Ѿ����֣������ظ�����.',sHint);
      Exit;
    end;
    nDBegin := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_Begin').AsDateTime);
    nDEnd := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_End').AsDateTime +1) ;
  end;

  FDM.ADOConn.BeginTrans ;
  try
    nStr := 'select L_CusID,L_ZhiKa,L_StockNo,SUM(L_Value)as L_Value from %s '+
            'where L_OutFact>=''%s'' and L_OutFact<''%s'' group by L_CusID,L_ZhiKa,L_StockNo';
    nStr := Format(nStr, [sTable_Bill,nDBegin,nDEnd]);
    //���ͻ���ֽ����Ʒ�ֲ�ѯ�������ܷ�����

    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount = 0 then
      begin
        ShowHintText('����������û�з��������ļ�¼');
        Exit;
      end;
      First;
      while not Eof do
      begin
        nZhika := FieldByName('L_ZhiKa').asstring;
        nStockNo := FieldByName('L_StockNo').asstring;
        nTotal := FieldByName('L_Value').AsFloat;
        nCusId := FieldByName('L_CusID').AsString;

        nRule := GetBackRule(nZhika,nStockNo,nTotal); //��ȡ���ֹ��� --  ���ֵ���

        if nRule = 0 then Continue;

        //�޸ĳ������ۣ�Ȼ�����¼���������
        nSql := 'update %s set L_Price=L_Price-%s where L_ZhiKa=''%s'' and '+
                ' L_CusID=''%s'' and L_StockNo=''%s'' and  L_OutFact>=''%s'' and L_OutFact<''%s''';
        nSql := Format(nSql,[sTable_Bill, nZhika, nCusId, nStockNo, nDBegin, nDEnd]);
        FDM.ExecuteSQL(nSql);

        //���¼���������
        nSql := 'Select Sum(L_Price*L_Value) From $Bill ' +
                'Where L_CusID=''$Cus'' And L_OutFact Is Not Null ' +
                'Union All ' +
                'Select Sum(L_Price*L_Value) From $Bill ' +
                'Where L_CusID=''$Cus'' And L_OutFact Is Null '+
                'Union All '+
                'Select Sum(A_value) from $JstM '+
                'Where A_OutCusId=''$Cus''';
        nSql := MacroValue(nSql, [MI('$Bill', sTable_Bill), MI('$Cus', nCusId), MI('$JstM', sTable_AdjustMoney)]);
        with FDM.QueryTemp(nStr) do
        begin
          First;
          nVal := Fields[0].AsFloat;

          Next;
          nVal2 := Fields[0].AsFloat;

          Next;
          nVal := nVal + Fields[0].AsFloat;

          nStr := 'Update %s Set A_OutMoney=%.2f,A_FreezeMoney=%.2f ' +
                  'Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nVal, nVal2, nCusId]);
          
          FDM.ExecuteSQL(nStr);
          //���³���Ͷ����
        end;

        Next;
      end;
    end;
    //�޸����ڷ��ֱ��
    nSql := 'Update %s set W_ZZInfo=''%s'' where W_NO=''%s''';
    nSql := Format(nSql,[sTable_InvoiceWeek,sFlag_Yes, FNowWeek]);
    FDM.ExecuteSQL(nSql);

    FDM.ADOConn.CommitTrans;
    ShowHintText('�������.');
  except
    fdm.ADOConn.RollbackTrans;
    ShowHintText('����ʧ��.');
    exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormBackCash, TfFormBackCash.FormID);

end.
