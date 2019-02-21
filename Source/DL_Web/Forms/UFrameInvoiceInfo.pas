unit UFrameInvoiceInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, System.inifiles,
  uniGUIBaseClasses, Data.Win.ADODB;

type
  TfFrameInvoiceInfo = class(TfFrameBase)
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    FIsCus: Boolean;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
  end;

var
  fFrameInvoiceInfo: TfFrameInvoiceInfo;

implementation

{$R *.dfm}

uses
  UFormDateFilter, USysDB, USysBusiness, uniGUIForm, USysConst, MainModule,
  ULibFun, UFormBase;

procedure TfFrameInvoiceInfo.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if not FIsCus then
  begin
    ShowMessage('无权限.');
    exit;
  end;

  nForm := SystemGetForm('TfFormInvoiceInfo', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameInvoiceInfo.BtnDelClick(Sender: TObject);
var
  nStr, nId:string;
  nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nId := ClientDS.FieldByName('R_Id').AsString;
  try
    nQuery := nil;

    nStr := 'delete from %s where R_Id=''%s''';
    nStr := Format(nStr,[sTable_invoiceinfo, nId]);
    DBExecute(nStr, nQuery);
  finally
    ReleaseDBQuery(nQuery);
  end;

  InitFormData(FWhere);
end;

procedure TfFrameInvoiceInfo.BtnEditClick(Sender: TObject);
var
  //nIsCus:Boolean;
  nStr:string;
  nForm: TUniForm;
  nParam: TFormCommandParam;
begin
  //nIsCus := UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
  if not FIsCus then
  begin
    ShowMessage('无权限.');
    exit;
  end;

  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormInvoiceInfo', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

function TfFrameInvoiceInfo.InitFormDataSQL(const nWhere: string): string;
var
  nStr: string;
begin
  //所属用户组
  if FIsCus then
    nStr := 'select * from $Bill where I_User=''$User'''
  else
    nStr := 'select * from $Bill';
  with TStringHelper,TDateTimeHelper do
  Result := MacroValue(nStr, [MI('$Bill', sTable_InvoiceInfo),
            MI('$User', UniMainModule.FUserConfig.FUserID)]);
end;

procedure TfFrameInvoiceInfo.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  FIsCus :=  UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
end;

initialization
  RegisterClass(TfFrameInvoiceInfo);

end.
