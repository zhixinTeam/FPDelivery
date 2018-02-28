unit UFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, ToolWin, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient,PLCController, ULEDFont, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, UMgrPoundTunnels,
  ExtCtrls, IdTCPServer, IdContext, IdGlobal, UBusinessConst, ULibFun,
  Menus, cxButtons, UMgrSendCardNo, USysLoger, cxCurrencyEdit;

type
  TFrame1 = class(TFrame)
    ToolBar1: TToolBar;
    btnStart: TToolButton;
    ToolButton2: TToolButton;
    btnPause: TToolButton;
    btnStop: TToolButton;
    ToolButton6: TToolButton;
    btnReset: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton1: TToolButton;
    ToolBar2: TToolBar;
    btnUp: TToolButton;
    ToolBar3: TToolBar;
    btnDown: TToolButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    cxLabel4: TcxLabel;
    EditBill: TcxComboBox;
    cxLabel5: TcxLabel;
    EditTruck: TcxComboBox;
    cxLabel7: TcxLabel;
    EditCusID: TcxComboBox;
    cxLabel8: TcxLabel;
    EditStockID: TcxComboBox;
    cxLabel6: TcxLabel;
    EditMaxValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    editPValue: TcxTextEdit;
    cxLabel2: TcxLabel;
    editZValue: TcxTextEdit;
    editNetValue: TLEDFontNum;
    editBiLi: TLEDFontNum;
    cxLabel3: TcxLabel;
    cxLabel9: TcxLabel;
    btnSetOpen: TButton;
    lblUpdown: TLabel;
    lblAdd: TLabel;
    lblReady: TLabel;
    lblOpenValue: TLabel;
    editOpenValue: TcxCurrencyEdit;
    shpAdd: TShape;
    shpReady: TShape;
    shpFan: TShape;
    editFD: TcxTextEdit;
    lblFan: TLabel;
    shpKw: TShape;
    lblKW: TLabel;
    Label1: TLabel;
    Button1: TButton;
    btnHandCtrl: TButton;
    tmrUp: TTimer;
    pnlAction: TPanel;
    lblAction: TLabel;
    tmrDown: TTimer;
    pnlError: TPanel;
    pnlFanErr: TPanel;
    pnlTotle: TPanel;
    pnlSignalErr: TPanel;
    pnlMoveErr: TPanel;
    pnlUpErr: TPanel;
    Button2: TButton;
    procedure btnPauseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnSetOpenClick(Sender: TObject);
    procedure btnUpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnDownMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnDownMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StopGetStatus;
    procedure Button1Click(Sender: TObject);
    procedure btnResetMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnResetMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnHandCtrlClick(Sender: TObject);
    procedure tmrUpTimer(Sender: TObject);
    procedure tmrDownTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FUserCtrl: Boolean;           //手动控制
    FCardUsed: string;            //卡片类型
    FUIData: TLadingBillItem;     //界面数据
    FPoundTunnel: PPTTunnelItem;  //磅站通道
    HasSet40, HasSet20, HasSet10, HasStop: Boolean;
    //procedure DoExecute(const nContext: TIdContext);
    //procedure OnGetCardNo(var nBase: TSendDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //接收磁卡号

    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //设置界面数据
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //读取磅重
    procedure WriteLog(const nEvent: string);
    procedure SetTunnel(const Value: PPTTunnelItem);
  public
    FrameId:Integer;              //PLC通道
    FIsBusy: Boolean;             //占用标识
    FSysLoger : TSysLoger;
    Fcontroller:TPLCController;
    FTCPSer:TIdTCPServer;
    FTimerStatus: TTimer;         //状态控制时钟
    FTimerSetTimer: TTimer;       //控制状态控制时钟的时钟
    FUpDownKeepOpen: Boolean;           //熟料或者散装，熟料时上升下降不关闭放料口
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    procedure LoadBillItems(const nCard: string);
    //读取交货单
  end;

implementation

{$R *.dfm}

uses
   USysBusiness, USysDB, USysConst, UDataModule, main;

procedure TFrame1.btnPauseClick(Sender: TObject);
var
  nmsg:string;
begin
  StopGetStatus;
  if not btnPause.Down then
  begin
    if Fcontroller.Pause(FrameId) then
    begin
      label1.Caption := '运行状态：已暂停';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end
  else begin
    if Fcontroller.UnPause(FrameId) then
    begin
      Label1.Caption := '运行状态：运行...';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end;
end;

procedure TFrame1.btnStartClick(Sender: TObject);
var
  nmsg:string;
begin
  StopGetStatus;
  if Fcontroller.Start(FrameId) then
  begin
    btnSetOpenClick(Self);
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    btnPause.Enabled := True;
    HasSet40 := False;
    Hasset20 := False;
    HasSet10 := false;
    HasStop := False;
    Label1.Caption := '运行状态：运行...';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnResetClick(Sender: TObject);
var
  nmsg:string;
begin
  {StopGetStatus;
  if btnReset.Down then
  begin
    if Fcontroller.Reset(FrameId) then
    begin
      Label1.Caption := '运行状态：复位中...';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end
  else begin
    if Fcontroller.UnPause(FrameId) then
    begin
      Label1.Caption := '运行状态：复位完毕';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end;  }
end;

procedure TFrame1.btnStopClick(Sender: TObject);
var
  nmsg:string;
begin
  StopGetStatus;
  if Fcontroller.Stop(FrameId) then
  begin
    Label1.Caption := '运行状态：已停止';
    //SetUIData(True);
    FIsBusy := False;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    btnPause.Enabled := False;
    HasSet40 := False;
    HasSet20 := false;
    HasSet10 := false;
    HasStop := true;
    ShowLedText(FPoundTunnel.FID, '  欢迎光临');
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnUpClick(Sender: TObject);
var
  nmsg:string;
begin
  {if btnUp.Down then
  begin
    if Fcontroller.up(FrameId) then
    begin
      Label1.Caption := '运行状态：上移中...';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end
  else begin
    if Fcontroller.UnUp(FrameId) then
    begin
      Label1.Caption := '运行状态：上移完毕';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end; }
end;

procedure TFrame1.btnDownClick(Sender: TObject);
var
  nmsg:string;
begin
  {if btnDown.Down then
  begin
    if Fcontroller.Down(FrameId) then
    begin
      Label1.Caption := '运行状态：下移中...';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end
  else begin
    if Fcontroller.UnDown(FrameId) then
    begin
      Label1.Caption := '运行状态：下移完毕';
    end
    else begin
      nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
      nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
      ShowMessage(nMsg);
    end;
  end;}
end;

{procedure TFrame1.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;  }

{procedure TFrame1.DoExecute(const nContext: TIdContext);
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
end;}

{procedure TFrame1.OnGetCardNo(var nBase: TSendDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
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

  //ShowMessage(Format('车道 [%s] 接收到卡号 %s', [nTunnel,nCardNo]));
  WriteLog(Format('车道 [%s] 接收到卡号 %s', [nTunnel,nCardNo]));

  if FPoundTunnel.FID <> nTunnel then Exit;
//  if FTunnel.FID <> nTunnel then Exit;

  if FIsBusy then Exit;

  EditBill.Text := nCardNo;
  LoadBillItems(EditBill.Text);
end; }

//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TFrame1.LoadBillItems(const nCard: string);
var
  nStr, nHint, nTmp: string;
  nIdx: integer;
  nBills: TLadingBillItems;
  nRet: Boolean;
begin
  FCardUsed := GetCardUsed(nCard);
  if FCardUsed=sFlag_Provide then
       nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills)
  else nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills);

  if (not nRet) or (Length(nBills) < 1) then
  begin
    nStr := '读取磁卡信息失败,请联系管理员';
    WriteLog(nStr);
    SetUIData(True);
    Exit;
  end;

  //获取最大限载值
  nBills[0].FMData.FValue := StrToFloatDef(GetLimitValue(nBills[0].FTruck),0);

  FUIData := nBills[0];

  //发送led显示内容
  nStr := FUIData.FTruck + StringOfChar(' ', 12 - Length(FUIData.FTruck));
  nTmp := GroupBox1.Caption + FloatToStr(FUIData.FValue);
  nStr := nStr + GroupBox1.Caption + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(FUIData.FValue);
  ShowLedText(FPoundTunnel.FID, nStr);

  SetUIData(False);

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '连接地磅表头失败，请联系管理员检查硬件连接';
    WriteLog(nHint);
    SetUIData(True);
    Exit;
  end; 

  FIsBusy := True;

  {if not SaveLadingBills(sFlag_TruckFH, nBills) then
  begin
    nStr := '车辆[ %s ]放灰处提货失败.';
    nStr := Format(nStr, [FUIData.FTruck]);

    WriteLog(nStr);
    Exit;
  end;}
end;

procedure TFrame1.SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
var
  nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    nItem.FFactory := gSysParam.FFactNum;

    FUIData := nItem;
    if nOnlyData then Exit;

    EditValue.Text := '0.00';
    editNetValue.Text := '0.00';
    editBiLi.Text := '0';
    EditBill.Properties.Items.Clear;

    //if not FIsBusy then
      //gPoundTunnelManager.ClosePort(FPoundTunnel.FID);

  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditStockID.Text := FStockName;
    EditCusID.Text := FCusName;

    EditMaxValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);
  end;
end;

procedure TFrame1.OnPoundDataEvent(const nValue: Double);
begin
  try
    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

procedure TFrame1.OnPoundData(const nValue: Double);
var
  nStr: string;
  nPValue, nZValue, nNetValue, nBiLi : Double;
  nFD: integer;
begin
  nPValue := StrToFloat(editPValue.Text);    //皮重
  nZValue := StrToFloat(editZValue.Text);    //票重
  nNetValue := nValue - nPValue;             //净重

  nBiLi := 0;
  if nZValue > 0 then
    nBiLi := nNetValue/nZValue *100;                //完成比例

  EditValue.Text := Format('%.2f', [nValue]);
  editNetValue.Text := Format('%.2f',[nNetValue]);
  editBiLi.Text := Format('%.2f',[nBiLi]);

  if Trim(editFD.Text) = '' then
    nfd := 0
  else
    nfd := strtoint(editFD.Text);

  if (nBiLi > 80) and (nFD > 40) and (HasSet40 = False) then
  begin
    HasSet40 := True;
    Fcontroller.SetOpening(FrameId,40);
  end;
  if (nBiLi > 90) and (nFD > 20) and (HasSet20 = False) then
  begin
    HasSet20 := True;
    Fcontroller.SetOpening(FrameId,20);
  end;
  if (nBiLi > 96) and (nFD > 10) and (HasSet10 = False) then
  begin
    HasSet10 := True;
    Fcontroller.SetOpening(FrameId,10);
  end;

  if not FUserCtrl then
  begin
    //超过限载重量停止放灰
    if (nValue+0.1 > FUIData.FMData.FValue) and (FUIData.FMData.FValue>1) and (HasStop = False) then
    begin
      btnStopClick(Self);
      ShowMsg('超过限载,自动发送停止指令.',sHint);
    end;
    //达到提货量停止放灰
    if (nNetValue+0.1 >= FUIData.FValue) and (FUIData.FValue > 0) and (HasStop = False) then
    begin
      btnStopClick(Self);
      ShowMsg('达到提货量,自动发送停止指令.',sHint);
    end;
  end;
end;

procedure TFrame1.btnSetOpenClick(Sender: TObject);
var
  nmsg:string;
begin
  StopGetStatus;
  if Fcontroller.SetOpening(FrameId,editOpenValue.EditValue) then
  begin
    //Label1.Caption := '运行状态：运行...';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnUpMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg:string;
begin
  StopGetStatus;
  if Fcontroller.up(FrameId,FUpDownKeepOpen) then
  begin
    lblAction.Caption := '↑';
    tmrUp.Enabled := true;
    lblUpdown.Caption := '上移中';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnUpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg:string;  
begin
  StopGetStatus;
  if Fcontroller.UnUp(FrameId,FUpDownKeepOpen) then
  begin
    lblUpdown.Caption := '上移完毕';
    tmrUp.Enabled := False;
    lblAction.Caption := ' =';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnDownMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg: string;
begin
  StopGetStatus;
  if Fcontroller.Down(FrameId,FUpDownKeepOpen) then
  begin
    lblAction.Caption := '↓';
    lblUpdown.Caption := '下移中';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnDownMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg: string;
begin
  StopGetStatus;
  if Fcontroller.UnDown(FrameId, FUpDownKeepOpen) then
  begin
    lblUpdown.Caption := '下移完毕';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  FSysLoger.AddLog(TFrame, '定置装车主单元', nEvent);
end;

procedure TFrame1.StopGetStatus;
begin
  FTimerStatus.Enabled := False;
  FTimerSetTimer.Enabled := True;
end;

procedure TFrame1.Button1Click(Sender: TObject);
var
  nhint:string;
begin
  //SetUIData(False);

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundDataEvent, True) then
  begin
    nHint := '连接地磅表头失败，请联系管理员检查硬件连接';
    WriteLog(nHint);
    SetUIData(True);
    Exit;
  end;
end;

procedure TFrame1.btnResetMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg:string;
begin
  StopGetStatus;
  if Fcontroller.Reset(FrameId) then
  begin
    Label1.Caption := '运行状态：复位中...';
  end
  else
  begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.btnResetMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nMsg:string;
begin
  StopGetStatus;
  if Fcontroller.UnPause(FrameId) then
  begin
    Label1.Caption := '运行状态：复位完毕';
  end
  else begin
    nMsg := 'ErrorCode:[%d],ErrorMsg:[%s]';
    nMsg := Format(nMsg,[Fcontroller.ErrCode,Fcontroller.ErrMsg]);
    ShowMessage(nMsg);
  end;
end;

procedure TFrame1.SetTunnel(const Value: PPTTunnelItem);
begin
  FPoundTunnel := Value;
  SetUIData(true);
  FUserCtrl := false;
end;

procedure TFrame1.btnHandCtrlClick(Sender: TObject);
begin
  FUserCtrl := not FUserCtrl;
  if FUserCtrl then
    btnHandCtrl.Caption := '切换自动'
  else
    btnHandCtrl.Caption := '切换手动';
end;

procedure TFrame1.tmrUpTimer(Sender: TObject);
begin
  lblAction.Caption := '↑';
  lblAction.Top := lblAction.Top -2;
  if lblAction.Top = - lblAction.Height then
    lblAction.Top := 0;
end;

procedure TFrame1.tmrDownTimer(Sender: TObject);
begin
  lblAction.Caption := '↓';
  lblAction.Top := lblAction.Top +2;
  if lblAction.Top = lblAction.Height then
    lblAction.Top := 0;
end;

procedure TFrame1.Button2Click(Sender: TObject);
begin
  SetUIData(true);
end;

end.
