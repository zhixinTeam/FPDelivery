unit UFrameFP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, system.inifiles,
  uniGUIBaseClasses, Data.Win.ADODB, uniGUIForm;

type
  TfFrameFP = class(TfFrameBase)
    procedure BtnAddClick(Sender: TObject);
  private
    { Private declarations }
    FWSQ, FIsCus: Boolean;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
  end;

var
  fFrameFP: TfFrameFP;

implementation

{$R *.dfm}

{ TfFrameFP }
uses
  USysDB, ULibFun, MainModule, USysBusiness, USysConst, UFormBase;

procedure TfFrameFP.BtnAddClick(Sender: TObject);
var
  nForm: TUniForm;
  nParam: TFormCommandParam;
begin
  if not FIsCus then
  begin
    ShowMessage('无申请开票权限.');
    Exit;
  end;
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要开票的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormFP', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
  nParam.FParamA := ClientDS.FieldByName('R_Id').AsString;
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

function TfFrameFP.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'select req.*,(R_ReqValue-R_KValue) as R_Need,W_Name From Sys_InvoiceRequst req  '+
            'Left Join Sys_InvoiceWeek On W_NO=req.R_Week Where R_CusID in('+
            'select C_ID from S_Customer where C_Admin=''$User'')';
  with TStringHelper do
    Result := MacroValue(Result, [MI('$User', UniMainModule.FUserConfig.FUserID)]);
end;

procedure TfFrameFP.OnCreateFrame(const nIni: TIniFile);
var
  nStr: string;
  nQuery: TADOQuery;
begin
  inherited;
  FIsCus :=  UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;

  nStr := 'select C_ID from S_Customer where C_Admin=''%s''';
  nStr := Format(nStr,[UniMainModule.FUserConfig.FUserID]);
  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
      if RecordCount <1 then
      begin
        FWSQ := True;
        ShowMessage('尚未授权.');
      end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFrameFP);
end.
