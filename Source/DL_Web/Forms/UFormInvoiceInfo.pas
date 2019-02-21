unit UFormInvoiceInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFormBase, uniGUIClasses, uniPanel,
  uniGUIBaseClasses, uniButton, uniEdit, uniLabel, USysConst, uniGUIForm;

type
  TfFormInvoiceInfo = class(TfFormBase)
    UniLabel5: TUniLabel;
    editcompName: TUniEdit;
    editType: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    editTaxNo: TUniEdit;
    UniLabel3: TUniLabel;
    editBank: TUniEdit;
    editBankNo: TUniEdit;
    UniLabel4: TUniLabel;
    UniLabel6: TUniLabel;
    editAddr: TUniEdit;
    editTel: TUniEdit;
    UniLabel7: TUniLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

procedure ShowTouSuForm(const nID: string;
  const nResult: TFormModalResult);
//入口函数

var
  fFormInvoiceInfo: TfFormInvoiceInfo;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, USysDB, USysBusiness, ULibFun, MainModule;

{ TfFormInvoiceInfo }

procedure ShowTouSuForm(const nID: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormInvoiceInfo', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInvoiceInfo do
  begin
    if nID = '' then
         FParam.FCommand := cCmd_AddData
    else FParam.FCommand := cCmd_EditData;
    FParam.FParamA := nID;

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
      end);
    //xxxxx
  end;
end;

procedure TfFormInvoiceInfo.BtnOKClick(Sender: TObject);
var
  nStr, nID: string;
  nQuery: TADOQuery;
  nBool: Boolean;
begin
  nStr := Trim(editcompName.Text);
  if nStr = '' then
  begin
    editcompName.SetFocus;
    ShowMessage('请输入开票单位名称.');
    Exit;
  end;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    nBool := FParam.FCommand = cCmd_addData;

    if FParam.FCommand = cCmd_AddData then
    begin
      with TSQLBuilder do
        nStr := MakeSQLByStr([
          SF('I_CompName', editcompName.Text),
          SF('I_TaxNo', editTaxNo.Text),
          SF('I_Addr', editAddr.Text),
          SF('I_Tel', editTel.Text),
          SF('I_TaxType', editType.Text),
          SF('I_Bank', editBank.Text),
          SF('I_BankNo', editBankNo.Text),
          SF('I_User', UniMainModule.FUserConfig.FUserID),
          SF('I_Date', sField_SQLServer_Now, sfVal)
          ], sTable_InvoiceInfo, '', nBool);
        //xxxxx
    end
    else if FParam.FCommand = cCmd_EditData then
    begin
      nID := FParam.FParamA;
      with TSQLBuilder do
        nStr := MakeSQLByStr([
          SF('I_CompName', editcompName.Text),
          SF('I_TaxNo', editTaxNo.Text),
          SF('I_Addr', editAddr.Text),
          SF('I_Tel', editTel.Text),
          SF('I_TaxType', editType.Text),
          SF('I_Bank', editBank.Text),
          SF('I_BankNo', editBankNo.Text),
          SF('I_User', UniMainModule.FUserConfig.FUserID),
          SF('I_Date', sField_SQLServer_Now, sfVal)
          ], sTable_InvoiceInfo, SF('R_id', nID), nBool);
        //xxxxx
    end;

    DBExecute(nStr, nQuery);
    ModalResult := mrOk;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceInfo.InitFormData(const nID: string);
var
  nQuery:TADOQuery;
  nStr: string;
begin
  nQuery := nil;
  if nID <> '' then
  try
    nStr := 'select * from %s where R_Id=''%s''';
    nStr := Format(nStr,[stable_InvoiceInfo,nid]);
    nQuery := LockDBQuery(FDBType);

    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        ShowMessage('记录不存在或经删除.');
        Exit;
      end;
      editcompName.Text := FieldByName('I_CompName').AsString;
      editType.Text := FieldByName('I_TaxType').AsString;
      editTaxNo.Text := FieldByName('I_TaxNo').AsString;
      editBank.Text := FieldByName('I_Bank').AsString;
      editBankNo.Text := FieldByName('I_BankNo').AsString;
      editAddr.Text := FieldByName('I_addr').AsString;
      editTel.Text := FieldByName('I_tel').AsString;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

function TfFormInvoiceInfo.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  Result := inherited SetParam(nParam);
  case nParam.FCommand of
   cCmd_AddData:
    begin
      FParam.FParamA := '';
      //InitFormData('');
    end;
   cCmd_EditData:
    begin
      //BtnOK.Enabled := False;
      InitFormData(FParam.FParamA);
    end;
    cCmd_ViewData:
    begin
      InitFormData(FParam.FParamA);
      BtnOK.Enabled := False;
    end;
  end;
end;

initialization
  RegisterClass(TfFormInvoiceInfo);

end.
