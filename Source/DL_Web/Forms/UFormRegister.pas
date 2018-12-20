unit UFormRegister;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFormBase, uniGUIClasses, uniPanel,
  uniGUIBaseClasses, uniButton, uniEdit, uniLabel, uniMemo, uniCheckBox,
  uniFileUpload, Data.Win.ADODB, USysConst, uniGUIForm;

type
  TfFormRegister = class(TfFormBase)
    UniLabel1: TUniLabel;
    editName: TUniEdit;
    UniLabel2: TUniLabel;
    editPsd: TUniEdit;
    UniLabel3: TUniLabel;
    editPsd2: TUniEdit;
    UniLabel4: TUniLabel;
    UniLabel5: TUniLabel;
    editLxr: TUniEdit;
    UniLabel6: TUniLabel;
    editTel: TUniEdit;
    UniLabel7: TUniLabel;
    editCompany: TUniEdit;
    UniLabel8: TUniLabel;
    Memo: TUniMemo;
    UniCheckBox1: TUniCheckBox;
    UniFileUpload1: TUniFileUpload;
    UniLabel9: TUniLabel;
    UniButton1: TUniButton;
    UniButton2: TUniButton;
    procedure BtnOKClick(Sender: TObject);
    procedure UniButton1Click(Sender: TObject);
    procedure UniFileUpload1Completed(Sender: TObject; AStream: TFileStream);
  private
    { Private declarations }
    FZZPath, FSfzPath:string;
  public
    { Public declarations }
  end;

procedure ShowRegisterForm(const nUser: string;
  const nResult: TFormModalResult);
//var
//  fFormRegister: TfFormRegister;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup, Vcl.Grids,
  Vcl.StdCtrls, ULibFun, USysBusiness, USysRemote, USysDB, ServerModule;

procedure ShowRegisterForm(const nUser: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormRegister', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormRegister do
  begin
    ShowModal;
//    ShowModal(
//      procedure(Sender: TComponent; Result:Integer)
//      begin
////        if Result = mrOk then
////          nResult(mrOk, @FParam);
//      end);
    //xxxxx
  end;
end;

procedure TfFormRegister.BtnOKClick(Sender: TObject);
var
  nStr, nID, nType: string;
  nQuery: TADOQuery;
begin
  if Trim(editName.Text) = '' then
  begin
    ShowMessage('用户名不能为空.');
    editName.SetFocus;
    Exit;
  end;

  if Trim(editPsd.Text) = '' then
  begin
    ShowMessage('请设置密码.');
    editPsd.SetFocus;
    Exit;
  end;

  if editPsd.Text <> editPsd2.Text then
  begin
    ShowMessage('两次输入的密码不一致.');
    editPsd2.SetFocus;
    Exit;
  end;

  if UniCheckBox1.Checked then
  begin
    if FZZPath = '' then
    begin
      ShowMessage('请上传营业执照照片.');
      Exit;
    end;
  end;

  nStr := 'select * from %s where G_Name=''%s''';
  nStr := Format(nStr,[sTable_Group,'Web客户组']);

  nQuery := nil;
  try
    nQuery := LockDBQuery(ctMain);
    with DBQuery(nStr, nQuery) do
    begin
      //if RecordCount < 1 then
      //begin
      //  ShowMessage('[Web客户组] 无效.');
      //  Exit;
      //end;
      nID := FieldByName('G_Id').AsString;
    end;

    if UniCheckBox1.Checked then
      nType := sFlag_Yes
    else
      nType := sFlag_No;

    try
      with TSQLBuilder do
      begin
        nStr := MakeSQLByStr([
            SF('U_Name', EditName.Text),
            SF('U_PassWord', editPsd.Text),
            SF('U_Mail', editLxr.Text),
            SF('U_Phone', editTel.Text),
            SF('U_Memo', Memo.Text),
            SF('U_Company', editCompany.Text),
            SF('U_State', '0'),
            SF('U_Identity', '1'),
            SF('U_Type', nType),
            SF('U_Status', sFlag_No),
            SF('U_ZZPath', FZZPath),
            SF('U_Group', nID)
            ], sTable_User, '', True);
        DBExecute(nStr);
      end;
      ShowMessage('注册成功,请等待管理员审核.');
    except
      ShowMessage('注册失败,请点击重试.');
      Exit;
    end;

    ModalResult := mrOk;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormRegister.UniButton1Click(Sender: TObject);
begin
  UniFileUpload1.Execute;
end;

procedure TfFormRegister.UniFileUpload1Completed(Sender: TObject;
  AStream: TFileStream);
var
  DestPath: string;
begin
  DestPath:=UniServerModule.StartPath+'UploadFolder\';
  FZZPath:=DestPath+ExtractFileName(AStream.FileName);
  CopyFile(PChar(AStream.FileName), PChar(FZZPath), False);
end;

initialization
  RegisterClass(TfFormRegister);
end.
