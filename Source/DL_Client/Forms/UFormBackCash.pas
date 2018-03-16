unit UFormBackCash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxMemo;

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
    FLastInterval: Cardinal;  //上次执行
    procedure InitFormData;
    procedure ShowNowWeek;
    procedure ShowHintText(const nText: string);
    function GetBackRule(nZhiKa,nStockNo:string;nTotal:Double):Double;
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
    Caption := '返现(全部客户)';
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
       EditWeek.Text := '请选择结算周期'
  else EditWeek.Text := Format('%s 年份:[ %s ]', [FWeekName, FNowYear]);

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
var
  nStr, nSql:string;
  nDBegin,nDEnd: string;  //结算周期开始结束日期
  nTotal, nRule, nValue, nOldValue:Double;  //提货总量,返现单价
  nZhika,nStockNo,nCusId: string;
  RId:string;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('请选择有效的周期', sHint);
    Exit;
  end;

  ShowHintText('开始计算返现,此过程较慢,请耐心等待...');

  nStr := 'select W_Begin,W_End from %s where W_NO=''%s''';
  nStr := Format(nStr,[sTable_InvoiceWeek,FNowWeek]);
  with FDM.QueryTemp(nStr) do
  begin
    nDBegin := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_Begin').AsDateTime);
    nDEnd := FormatDateTime('yyyy-mm-dd HH:MM:SS',FieldByName('W_End').AsDateTime +1) ;
  end;

  FDM.ADOConn.BeginTrans ;
  try
    nStr := 'select L_CusID,L_ZhiKa,L_StockNo,SUM(L_Value)as L_Value from %s '+
            'where L_OutFact>=''%s'' and L_OutFact<''%s'' group by L_CusID,L_ZhiKa,L_StockNo';
    nStr := Format(nStr, [sTable_Bill,nDBegin,nDEnd]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount = 0 then
      begin
        ShowHintText('结算周期内没有符合条件的记录');
        Exit;
      end;
      First;
      while not Eof do
      begin
        nZhika := FieldByName('L_ZhiKa').asstring;
        nStockNo := FieldByName('L_StockNo').asstring;
        nTotal := FieldByName('L_Value').AsFloat;
        nCusId := FieldByName('L_CusID').AsString;

        nRule := GetBackRule(nZhika,nStockNo,nTotal); //获取返现规则
        nvalue := nRule * nTotal;

        nSql := 'select * from %s where R_CusId=''%s'' and R_ZhiKa=''%s'' and '+
                'R_StockNo=''%s'' and R_Valid<>''%s'' and R_WeekNo=''%s''';
        nSql := Format(nSql,[sTable_BackRecord,nCusId,nZhika,nStockNo,sFlag_Yes,FNowWeek]);
        //查询上次本周期返现情况
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
        end;

        Next;
      end;
    end;
    FDM.ADOConn.CommitTrans;
    ShowHintText('结算完成.');
  except
    fdm.ADOConn.RollbackTrans;
    ShowHintText('结算失败.');
    exit;
  end;
end;

procedure TfFormBackCash.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
  Application.ProcessMessages;

  if GetTickCount - FLastInterval < 500 then
    Sleep(375);
  FLastInterval := GetTickCount;
end;

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

initialization
  gControlManager.RegCtrl(TfFormBackCash, TfFormBackCash.FormID);

end.
