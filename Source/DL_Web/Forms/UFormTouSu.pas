unit UFormTouSu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFormBase, uniGUIClasses, uniPanel,
  uniGUIBaseClasses, uniButton, USysConst, uniGUIForm, uniMemo, uniEdit,
  uniLabel;

type
  TfFormTouSu = class(TfFormBase)
    UniLabel1: TUniLabel;
    EditTitle: TUniEdit;
    UniLabel2: TUniLabel;
    editText: TUniMemo;
    lblSH: TUniLabel;
    editSH: TUniEdit;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

procedure ShowTouSuForm(const nTouSu: string;
  const nResult: TFormModalResult);
//入口函数

var
  fFormTouSu: TfFormTouSu;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, USysDB, USysBusiness, ULibFun, MainModule;

procedure ShowTouSuForm(const nTouSu: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormPopedomUser', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormTouSu do
  begin
    if nTouSu = '' then
         FParam.FCommand := cCmd_AddData
    else FParam.FCommand := cCmd_EditData;
    FParam.FParamA := nTouSu;

    //BtnOK.Enabled := nTouSu = '';
    //InitFormData(nUser);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
      end);
    //xxxxx
  end;
end;

procedure TfFormTouSu.BtnOKClick(Sender: TObject);
var
  nStr, nID: string;
  nQuery: TADOQuery;
  nBool: Boolean;
begin
  nStr := Trim(EditTitle.Text);
  if nStr = '' then
  begin
    EditTitle.SetFocus;
    ShowMessage('请输入投诉标题');
    Exit;
  end;

  nStr := Trim(editText.Text);
  if nStr = '' then
  begin
    EditTitle.SetFocus;
    ShowMessage('请输入内容');
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
          SF('T_Title', EditTitle.Text),
          SF('T_Status', sFlag_TSN),
          SF('T_TSMan', UniMainModule.FUserConfig.FUserID),
          SF('T_TSTime', sField_SQLServer_Now, sfVal),
          SF('T_TSMemo', edittext.Text)
          ], sTable_TouSu, '', nBool);
        //xxxxx
    end
    else if FParam.FCommand = cCmd_EditData then
    begin
      nID := FParam.FParamA;
      with TSQLBuilder do
        nStr := MakeSQLByStr([
          SF('T_Title', EditTitle.Text),
          SF('T_TSMemo', edittext.Text)
          ], sTable_TouSu, SF('R_id', nID), nBool);
        //xxxxx
    end
    else if FParam.FCommand = cCmd_ShenHe then
    begin
      nID := FParam.FParamA;
      with TSQLBuilder do
        nStr := MakeSQLByStr([
          SF('T_Status', sFlag_TSS),
          SF('T_DealMan', UniMainModule.FUserConfig.FUserID),
          SF('T_DealTime', sField_SQLServer_Now, sfVal),
          SF('T_DealResult', editSH.Text)
          ], sTable_TouSu, SF('R_id', nID), nBool);
        //xxxxx
    end;

    DBExecute(nStr, nQuery);
    ModalResult := mrOk;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormTouSu.InitFormData(const nID: string);
var
  nQuery:TADOQuery;
  nStr: string;
begin
  nQuery := nil;
  if nID <> '' then
  try
    nStr := 'select * from %s where R_Id=''%s''';
    nStr := Format(nStr,[stable_tousu,nid]);
    nQuery := LockDBQuery(FDBType);

    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        ShowMessage('记录不存在或经删除.');
        Exit;
      end;
      EditTitle.Text := FieldByName('T_Title').AsString;
      editText.Text := FieldByName('T_TSMemo').AsString;
      editSH.Text := FieldByName('T_DealResult').AsString;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

function TfFormTouSu.SetParam(const nParam: TFormCommandParam): Boolean;
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
    cCmd_ShenHe:
    begin
      InitFormData(FParam.FParamA);
      editSH.Visible := true;
      lblSH.Visible := True;
    end;
    cCmd_ViewData:
    begin
      InitFormData(FParam.FParamA);
      BtnOK.Enabled := False;
      editSH.Visible := true;
      lblSH.Visible := True;
    end;
  end;
end;

initialization
  RegisterClass(TfFormTouSu);
end.
