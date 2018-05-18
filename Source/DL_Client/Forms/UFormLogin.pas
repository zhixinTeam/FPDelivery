{*******************************************************************************
  作者: dmzn@163.com 2008-8-8
  描述: 用户登录窗口
*******************************************************************************}
unit UFormLogin;

{$I link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfFormLogin = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    Edit_Pwd: TLabeledEdit;
    LabelCopy: TLabel;
    BtnExit: TSpeedButton;
    BtnSet: TSpeedButton;
    BtnLogin: TButton;
    Edit_User: TComboBox;
    Label1: TLabel;
    procedure BtnSetClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnLoginClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure UserList(const nWrite: Boolean);
    //用户列表
  public
    { Public declarations }
  end;

function ShowLoginForm: Boolean;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, USysConst, USysDB, USysPopedom, USysMenu, UMgrPopedom,
  USysLoger, UFormWait, UFormConn, UDataModule, USysMAC, USysBusiness;
  
ResourceString
  sUserLogin = '用户[ %s ]尝试登陆系统';
  sUserLoginOK = '登陆系统成功,用户:[ %s ]';
  sConnDBError = '连接数据库失败,配置错误或远程无响应';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormLogin, '用户登陆', nEvent);
end;

//Desc: 用户登录
function ShowLoginForm: Boolean;
var nStr: string;
begin
  with TfFormLogin.Create(Application) do
  begin
    Caption := '登录';
    Edit_User.Text := gSysParam.FUserName;

    nStr := gPath + 'Logo.bmp';
    if FileExists(nStr) then
      Image1.Picture.LoadFromFile(nStr);
    //xxxxx

    if gSysParam.FCopyRight <> '' then
      LabelCopy.Caption := gSysParam.FCopyRight;
    //xxxxx

    Result := ShowModal = mrOk;
    Free
  end;
end;

procedure TfFormLogin.UserList(const nWrite: Boolean);
var nStr: string;
    nIdx: Integer;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    if nWrite then
    begin
      if Edit_User.ItemIndex >= 0 then Exit;
      nStr := 'User_' + IntToStr(Edit_User.Items.Count);
      nIni.WriteString(Name, nStr, Edit_User.Text);
      Exit;
    end;

    Edit_User.Items.Clear;
    nIdx := 0;

    while True do
    begin
      nStr := 'User_' + IntToStr(nIdx);
      nStr := nIni.ReadString(Name, nStr, '');
      if nStr = '' then Exit;

      if Edit_User.Items.IndexOf(nStr)<0 then
        Edit_User.Items.Add(nStr);
      Inc(nIdx);
    end;
  finally
    nIni.Free;
  end;
end;

procedure TfFormLogin.FormCreate(Sender: TObject);
begin
  UserList(False);
end;

procedure TfFormLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOK then
    UserList(True);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: 设置
procedure TfFormLogin.BtnSetClick(Sender: TObject);
begin
  ShowConnectDBSetupForm(ConnCallBack);
end;

//Desc: 退出
procedure TfFormLogin.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: 处理快捷键
procedure TfFormLogin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DOWN:
      begin
        Key := 0; SwitchFocusCtrl(Self, True);
      end;
    VK_UP:
      begin
        Key := 0; SwitchFocusCtrl(Self, False);
      end;
  end;
end;

procedure TfFormLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
  begin
    Key := #0; SwitchFocusCtrl(Self, True);
  end;
end;

//Desc: 登录
procedure TfFormLogin.BtnLoginClick(Sender: TObject);
var nStr: string;
    nMsg, nLastMac: string;
    nList: TStrings;
begin
  Edit_User.Text := Trim(Edit_User.Text);
  Edit_Pwd.Text := Trim(Edit_Pwd.Text);

  if (Edit_User.Text = '') or (Edit_Pwd.Text = '') then
  begin
    ShowMsg('请输入用户名和密码', sHint); Exit;
  end;

  nStr := BuildConnectDBStr;

  while nStr = '' do
  begin
    ShowMsg('请输入正确的"数据库"配置参数', sHint);
    if ShowConnectDBSetupForm(ConnCallBack) then
         nStr := BuildConnectDBStr
    else Exit;
  end;

  nMsg := '';
  ShowWaitForm(Self, '连接数据库');
  try
    WriteLog(Format(sUserLogin, [Edit_User.Text]));
    //write log

    nList := nil;
    try
      FDM.ADOConn.Connected := False;
      FDM.ADOConn.ConnectionString := nStr;
      FDM.ADOConn.Connected := True;

      nList := TStringList.Create;
      LoadConnecteDBConfig(nList);

      nStr := nList.Values[sConn_Key_DBType];
      if IsNumber(nStr, False) then
        gSysDBType := TSysDatabaseType(StrToInt(nStr));
      nList.Free;
    except
      if Assigned(nList) then nList.Free;
      WriteLog(sConnDBError);
      ShowDlg(sConnDBError, sWarn, Handle); Exit;
    end;

    nStr := 'Select U_NAME,U_Password,U_Mac from $a Where U_NAME=''$b'' and U_PASSWORD=''$c'' ' +
            'and U_State=$d';
    nStr := MacroValue(nStr, [MI('$a',sTable_User),
                              MI('$b',Edit_User.Text),
                              MI('$c',Edit_Pwd.Text),
                              MI('$d', IntToStr(cPopedomUser_Normal))]);
    //xxxxx
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount <> 1 then
      begin
        Edit_User.SetFocus;
        nMsg := '错误的用户名或密码,请重新输入'; Exit;
      end;
      if FieldByName('U_Password').AsString <> Edit_Pwd.Text then
      begin
        Edit_Pwd.SetFocus;
        nMsg := '错误的密码,请重新输入'; Exit;
      end;
    end;

    with gSysParam do
    begin
      FUserID := Edit_User.Text;
      FUserName := FDM.SqlQuery.Fields[0].AsString;
      FUserPwd := Edit_Pwd.Text;
      FLocalMAC   := MakeActionID_MAC;
      GetLocalIPConfig(FLocalName, FLocalIP);
      nLastMac := FDM.SqlQuery.FieldByName('U_Mac').AsString;
    end;

    if (gSysParam.FLocalMAC <> nLastMac) and (nLastMac <> '') then
    begin
      AddManualEventRecord(gSysParam.FUserID + gSysParam.FLocalMAC,gSysParam.FUserID,'DoubleLogin',
              nLastMac,sFlag_Solution_YNP,'DealDoubleLogin',True,'');

      nStr := 'update %s set U_Mac=''%s'' where U_Name=''%s''';
      nStr := Format(nStr,[sTable_User,gSysParam.FLocalMAC,gSysParam.FUserID]);
      FDM.ExecuteSQL(nStr);
    end;

    if nLastMac ='' then
    begin
      nStr := 'update %s set U_Mac=''%s'' where U_Name=''%s''';
      nStr := Format(nStr,[sTable_User,gSysParam.FLocalMAC,gSysParam.FUserID]);
      FDM.ExecuteSQL(nStr);
    end;

    ShowWaitForm(nil, '载入数据');
    {$IFDEF EnableBackupDB}
    gSysParam.FUsesBackDB := FDM.IsEnableBackupDB;
    if gSysParam.FUsesBackDB then
    begin
      nStr := BuildFixedConnStr(sDBConfig_bk, True); 
      FDM.Conn_Bak.Connected := False;
      FDM.Conn_Bak.ConnectionString := nStr;
    end;
    {$ENDIF}

    if not gMenuManager.IsValidProgID then
    begin
      WriteLog('验证程序标识失败');
      nMsg := '程序标识无效,无法载入所需数据'; Exit;
    end;

    ShowWaitForm(nil, '初始化菜单');
    if not gMenuManager.LoadMenuFromDB(gSysParam.FProgID) then
    begin
      WriteLog('载入菜单数据失败');
      nMsg := '无法载入程序所需数据,网络或数据库故障'; Exit;
    end;

    ShowWaitForm(nil, '读取用户权限');
    if not gPopedomManager.LoadGroupFromDB(gSysParam.FProgID) then
    begin
      WriteLog('读取用户权限失败');
      nMsg := '无法载入用户权限数据,网络或数据库故障'; Exit;
    end;

    FDM.AdjustAllSystemTables;
    gPopedomManager.GetUserIdentity(gSysParam.FUserName);
    
    nStr := Format(sUserLoginOK, [Edit_User.Text]);
    WriteLog(nStr);
    ModalResult := mrOk;
  finally
    CloseWaitForm;
    if nMsg <> '' then ShowDlg(nMsg, sHint);
  end;
end;

end.
