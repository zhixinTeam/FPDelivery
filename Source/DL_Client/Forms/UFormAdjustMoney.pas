unit UFormAdjustMoney;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxGroupBox, cxTextEdit, cxLabel, cxMaskEdit,
  cxDropDownEdit, cxCurrencyEdit;

type
  TfFormAdjustMoney = class(TfFormNormal)
    cxGroupBox1: TcxGroupBox;
    dxLayout1Item3: TdxLayoutItem;
    cxGroupBox2: TcxGroupBox;
    dxLayout1Item4: TdxLayoutItem;
    cxGroupBox3: TcxGroupBox;
    dxLayout1Item5: TdxLayoutItem;
    eEditOutNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxlabel2: TcxLabel;
    eEditOutName: TcxComboBox;
    eEditInName: TcxComboBox;
    eEditInNo: TcxTextEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EditMoney: TcxCurrencyEdit;
    cxLabel5: TcxLabel;
    editMemo: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure eEditOutNamePropertiesChange(Sender: TObject);
    procedure eEditInNamePropertiesChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure LoadFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
          const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormAdjustMoney: TfFormAdjustMoney;
  FListA, FListIn : TStringList;

implementation

{$R *.dfm}

uses
  USysConst, UDataModule, UMgrControl, USysDB, ULibFun, UFormCtrl, USysBusiness;

{ TfFormAdjustMoney }

class function TfFormAdjustMoney.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormAdjustMoney.Create(Application) do
  begin
    FListA := TStringList.Create;
    FListIn := TStringList.Create;
    LoadFormData;
    //ActiveControl := EditCard;
    ShowModal;
    Free;
  end;
end;

class function TfFormAdjustMoney.FormID: integer;
begin
  Result := cFI_FormAdjustMoney;
end;

procedure TfFormAdjustMoney.LoadFormData;
var
  nStr:string;
begin
  nStr := 'Select C_Id,C_Name from S_Customer';
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      FListA.Add(fieldbyname('C_Id').asstring);
      eEditOutName.Properties.Items.Add(FieldByName('C_Name').AsString);
      //eEditInName.Properties.Items.Add(FieldByName('C_Name').AsString);
      Next;
    end;
  end;
end;

procedure TfFormAdjustMoney.eEditOutNamePropertiesChange(Sender: TObject);
var
  nStr: string;
begin
  inherited;
  if eEditOutName.ItemIndex = -1 then
  begin
    eEditOutNo.Text := '';
    exit;
  end;

  eEditOutNo.Text := FListA.Strings[eEditOutName.ItemIndex];

  eEditInNo.Text := '';
  eEditInName.Properties.Items.Clear;
  eEditInName.ItemIndex := -1;
  nStr := 'Select C_Id,C_Name from %s where c_parent=''%s''';
  nStr := Format(nStr, [sTable_Customer,eEditOutNo.Text]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      FListIn.Add(fieldbyname('C_Id').asstring);
      eEditInName.Properties.Items.Add(FieldByName('C_Name').AsString);
      Next;
    end;
  end;
end;

procedure TfFormAdjustMoney.eEditInNamePropertiesChange(Sender: TObject);
begin
  inherited;
  if eEditInName.ItemIndex = -1 then
  begin
    eEditInNo.Text := '';
    exit;
  end;
  eEditInNo.Text := FListIn.Strings[eEditInName.ItemIndex];
end;

procedure TfFormAdjustMoney.BtnOKClick(Sender: TObject);
var
  nStr: string;
  nMoney: Double;
begin
  if eEditOutNo.Text = '' then
  begin
    ShowMessage('请选择调出账户');
    eEditOutName.SetFocus;
    exit;
  end;
  if eEditInNo.Text = '' then
  begin
    ShowMessage('请选择调出账户');
    eEditInName.SetFocus;
    exit;
  end;
  if EditMoney.Value = 0 then
  begin
    ShowMessage('请填写调拨金额');
    EditMoney.SetFocus;
    exit;
  end;

  //调拨金额不允许大于可用金额
  nMoney := GetCustomerValidMoney(eEditOutNo.Text, False);
  if nMoney < EditMoney.Value then
  begin
    ShowMessage('调拨金额不允许大于客户可用金额.');
    EditMoney.SetFocus;
    exit;
  end;

  try
    FDM.ADOConn.BeginTrans;

    //调出账户出金增加
    nStr := 'update %s set A_OutMoney = A_OutMoney + %s where A_CId = ''%s''';
    nStr := Format(nStr,[sTable_CusAccount, FloatToStr(EditMoney.Value), eEditOutNo.Text]);
    FDM.ExecuteSQL(nStr);

    //在调入账户增加
    nStr := 'update %s set A_InMoney = A_InMoney + %s where A_CId = ''%s''';
    nStr := Format(nStr,[sTable_CusAccount, FloatToStr(EditMoney.Value), eEditInNo.Text]);
    FDM.ExecuteSQL(nStr);

    //插入调拨表
    nStr := MakeSQLByStr([
                SF('A_OutCusId',    eEditOutNo.Text),
                SF('A_OutCusName',  eEditOutName.Text),
                SF('A_InCusId',     eEditInNo.Text),
                SF('A_InCusName',   eEditInName.Text),
                SF('A_Value',       EditMoney.Value, sfVal),
                SF('A_User',        gSysParam.FUserID),
                SF('A_Date',        now),
                SF('A_Memo',        editMemo.Text)
                ], sTable_AdjustMoney, '', True);
    FDM.ExecuteSQL(nStr);

    //写入日志
    nStr := '从账户 [ %s ] 调拨金额到账户 [ %s ], 金额：[ %s ]元';
    nStr := Format(nStr,[(eEditOutNo.Text+eEditOutName.Text),(eEditInNo.Text+eEditInName.Text), EditMoney.Text]);
    FDM.WriteSysLog(sFlag_CustomerItem,(eEditOutNo.text+'=>'+eEditInNo.Text),nStr);

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOk;
  except
    FDM.ADOConn.RollbackTrans;
    showmsg('调拨金额失败！',sHint);
    Exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAdjustMoney, TfFormAdjustMoney.FormID);

end.
