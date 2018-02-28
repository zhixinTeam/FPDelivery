unit main;
{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient,PLCController, ExtCtrls, IdContext, IdCustomTCPServer,
  IdTCPServer, IniFiles, IdGlobal, UMgrSendCardNo;

type
  TFormMain = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Panel1: TPanel;
    IdTCPServer1: TIdTCPServer;
    tmrGetStatus: TTimer;
    tmrStartGetStatus: TTimer;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrGetStatusTimer(Sender: TObject);
    procedure tmrStartGetStatusTimer(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    function IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
  private
    { Private declarations }
    Fcontroller:TPLCController;
    procedure LoadPoundItems;
    procedure RunSysObject;
  public
    { Public declarations }
    procedure DoExecute(const nContext: TIdContext);
    procedure OnGetCardNo(var nBase: TSendDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //接收磁卡号
  end;

var
  FormMain: TFormMain;
  AppPath: string;
  gPlcOpenValue: Integer;
  gMitUrl:string;
  gUpDownKeepOpen:Boolean;

implementation

uses
  UFrame, UMgrPoundTunnels, USysLoger, UClientWorker, UMemDataPool, UFormConn,
  UMgrChannel, UChannelChooser, UMITPacker, ULibFun, UDataModule;

{$R *.dfm}

procedure TFormMain.FormShow(Sender: TObject);
var
  nFrame:TFrame1;
begin
  if not Assigned(gPoundTunnelManager) then
  begin
    gPoundTunnelManager := TPoundTunnelManager.Create;
    gPoundTunnelManager.LoadConfig('Tunnels.xml');
  end;
  LoadPoundItems;
end;

procedure TFormMain.LoadPoundItems;
var nIdx: Integer;
    nT: PPTTunnelItem;
begin
  with gPoundTunnelManager do
  begin
    for nIdx:=Tunnels.Count-1 downto 0 do
    begin
      nT := Tunnels[nIdx];
      //tunnel

      with TFrame1.Create(Self) do
      begin
        Name := 'fFramePlcCtrl' + IntToStr(nIdx);
        Parent := Panel1;
        FrameId := nIdx+1;
        FUpDownKeepOpen := gUpDownKeepOpen;
        Fcontroller := self.Fcontroller;

        Align := alLeft;
        GroupBox1.Caption := nT.FName;
        PoundTunnel := nT;
        FTCPSer := IdTCPServer1;
        IdTCPServer1.Active := True;

        FTimerStatus :=tmrGetStatus ;
        FTimerSetTimer := tmrStartGetStatus ;

        FSysLoger:= gSysLoger;
      end;
    end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  MyFile : TIniFile;
  nPlcHost: string;
  nPlcPort: Integer;
  LocalPort: Integer;
begin
  AppPath := ExtractFilePath(Application.ExeName);

  MyFile := TIniFile.Create(AppPath + 'sysconfig.ini');
  nPlcHost := MyFile.ReadString('PlcInfo','PlcHost','');
  nPlcPort := MyFile.ReadInteger('PlcInfo','PlcPort',5050);
  gPlcOpenValue := MyFile.ReadInteger('PlcInfo','PlcOpenValue',80);

  LocalPort := MyFile.ReadInteger('FixLoading','localPort',5050);
  gUpDownKeepOpen := MyFile.ReadBool('FixLoading','UpDownKeepOpen',False);

  gMitUrl := MyFile.ReadString('Mit','MitUrl','');
  MyFile.Free;

  //InitGlobalVariant(AppPath, AppPath+'Config.Ini', AppPath+'FormInfo.ini', AppPath+'DBConn.ini');
  
  RunSysObject;

  IdTCPServer1.DefaultPort := LocalPort;

  IdTCPClient1.Host := nPlcHost;
  IdTCPClient1.Port := nPlcPort;
  try
    if not IdTCPClient1.Connected then
    begin
      IdTCPClient1.Connect;
    end;
  except
    on E:Exception do
    begin
      ShowMessage('PLC连接失败：'+e.Message);
    end;
  end;
  Fcontroller := TPLCController.Create(IdTCPClient1);
  {$IFNDEF DEBUG}
  tmrGetStatus.Enabled := true;
  {$ENDIF}
end;



procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IdTCPServer1.Active := False;
end;

procedure TFormMain.tmrGetStatusTimer(Sender: TObject);
var
  nMsg: string;
  i: integer;
  nBackOrd: TIdBytes;
  nbyte1, nbyte2, nbyte2_2, nbyte3: Byte;
begin
  try
  if  Fcontroller.GetStatus(1,1) then
  begin
    FormMain.Caption := '定置装车控制系统';
    nBackOrd := Fcontroller.StatusOrd;
    //Memo1.Lines.add(IdBytesToAnsiString(nBackOrd));
    for i :=  0 to gPoundTunnelManager.Tunnels.Count-1 do//20  (Length(nBackOrd) div 2)-2  do
    begin
      nbyte1 := nbackord[12*i+4];
      nbyte2 := nbackord[12*i+6];
      nbyte2_2 := nbackord[12*i+5];
      nbyte3 := nbackord[12*i+10];

      if (nbyte1 and Control_UP)=Control_UP then TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).lblUpdown.Caption := '上升';
      //有上升状态
      if (nbyte1 and Control_DOWN)=Control_DOWN then TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).lblUpdown.Caption := '下降';
      //有下降状态
      if (nbyte1 and Control_Add)=Control_Add then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpAdd.Brush.Color := clGreen
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpAdd.Brush.Color := clRed;
      //有加料状态
      if (nbyte1 and Control_Pause)=Control_Pause then TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpAdd.Brush.Color :=clBlue;
      //有暂停加料状态
      if (nbyte1 and Control_Reset)=Control_Reset then TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).Label1.Caption := '复位';
      //有复位状态
      if nbyte1 = 0 then TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).Label1.Caption := '';

      if (nbyte2 and Feedback_ready) = Feedback_ready then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpReady.Brush.Color := clGreen
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpReady.Brush.Color := clRed;
      //备妥
      if (nbyte2 and Feedback_switch) = Feedback_switch then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpKw.Brush.Color := clGreen
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpKw.Brush.Color := clRed;
      //料位
      if (nbyte2 and Feedback_FanStatus) = Feedback_FanStatus then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpFan.Brush.Color := clGreen
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).shpFan.Brush.Color := clRed;
      //提升机故障
      if (nbyte2 and Feedback_ErrUp) = Feedback_ErrUp then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlUpErr.Visible := True
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlUpErr.Visible := False;
      //移动机故障
      if (nbyte2 and Feedback_ErrMove) = Feedback_ErrMove then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlMoveErr.Visible := True
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlMoveErr.Visible := False;
      //通信故障
      if (nbyte2 and Feedback_ErrSignal) = Feedback_ErrSignal then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlSignalErr.Visible := True
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlSignalErr.Visible := False;
      //系统总故障
      if (nbyte2 and Feedback_ErrTotle) = Feedback_ErrTotle then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlTotle.Visible := True
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlTotle.Visible := False;
      //风机未备妥
      if (nbyte2_2 and Feedback_ErrFan) = Feedback_ErrFan then
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlFanErr.Visible := True
      else
        TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).pnlFanErr.Visible := False;

      TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))).editFD.Text := IntToStr(word(nbyte3));
      //阀度
    end;
  end
  except
    Memo1.Lines.Add('读取状态失败！');
    Exit;
  end;
end;

procedure TFormMain.RunSysObject;
begin
  gSysLoger := TSysLoger.Create(AppPath + 'Logs\');
  //Sysloger
  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //mem pool

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
  gChannelChoolser.AddChannelURL(gMitUrl);
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TFormMain.tmrStartGetStatusTimer(Sender: TObject);
begin
  tmrGetStatus.Enabled := True;
end;

procedure TFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      //Frame1.WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TSendDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeSendBase, False);
    BytesToRaw(nBuf, nBase, cSizeSendBase);

    case nBase.FCommand of
     cCmd_SendCard :
      begin
        OnGetCardNo(nBase,nBuf,nContext);
      end;
    end;
  end;
end;

procedure TFormMain.OnGetCardNo(var nBase: TSendDataBase;
  var nBuf: TIdBytes; nCtx: TIdContext);
var
  nTunnel, nCardNo, nStr: string;
  i: Integer;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));
  i := Pos('@',nStr);
  if i < 0 then Exit;
  
  nTunnel:= Copy(nStr,0,i-1);
  nCardNo := Copy(nStr,i+1,Length(nStr));

  for i := 0 to 2 do
  begin
    with  TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))) do
    begin
      if FIsBusy then Continue;
      if PoundTunnel.FID = nTunnel then
      begin
        //FIsBusy := True;
        EditBill.Text := nCardNo;
        LoadBillItems(EditBill.Text);
      end;
    end;
  end;
end;

function TFormMain.IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
var  
  i: Integer;  
  S: AnsiString;  
begin  
  S := '';  
  for i := 0 to Length(ParamBytes) - 1 do
  begin    
    S := S + AnsiChar(ParamBytes[i]);
  end;
  //ShowMessage(s);
  Result := S;
end;

end.
