{*******************************************************************************
  作者: dmzn@163.com 2013-11-23
  描述: 模块工作对象,用于响应框架事件
*******************************************************************************}
unit UEventHardware;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UMITConst, UPlugConst;

type
  THardwareWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    procedure InitSystemObject; override;
    //主程序启动时初始化
    procedure BeforeStartServer; override;
    //服务启动之前调用
    procedure AfterStopServer; override;
    //服务关闭之后调用
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //运行参数

implementation

uses
  SysUtils, USysLoger, UHardBusiness, UMgrTruckProbe, UMgrParam,
  UMgrQueue, UMgrLEDCard, UMgrHardHelper, UMgrRemotePrint, U02NReader, UMgrRemoteSnap,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrERelay, UMgrRemoteVoice, UMgrCodePrinter, UMgrLEDDisp, UMgrBasisWeight,
  UMgrRFID102, UMgrVoiceNet, UBlueReader, UMgrTTCEM100, UMgrSendCardNo;

class function THardwareWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleHD;
    FModuleName := '硬件守护';
    FModuleVersion := '2014-09-30';
    FModuleDesc := '提供水泥一卡通发货的硬件处理对象';
    FModuleBuildTime:= Str2DateTime('2014-09-30 15:01:01');
  end;
end;

procedure THardwareWorker.RunSystemObject(const nParam: PPlugRunParameter);
var nStr,nCfg: string;
begin
  gPlugRunParam := nParam^;
  nCfg := gPlugRunParam.FAppPath + 'Hardware\';

  try
    nStr := 'LED';
    gCardManager.TempDir := nCfg + 'Temp\';
    gCardManager.FileName := nCfg + 'LED.xml';

    nStr := '远距读头';
    gHardwareHelper.LoadConfig(nCfg + '900MK.xml');

    nStr := '蓝卡读卡器';
    gBlueReader.LoadConfig(nCfg + 'BlueCardReader.XML');

    nStr := '近距读头';
    g02NReader.LoadConfig(nCfg + 'Readers.xml');

    nStr := '计数器';
    gMultiJSManager.LoadFile(nCfg + 'JSQ.xml');

    nStr := '继电器';
    gERelayManager.LoadConfig(nCfg + 'ERelay.xml');

    nStr := '远程打印';
    gRemotePrinter.LoadConfig(nCfg + 'Printer.xml');

    nStr := '语音服务';
    gVoiceHelper.LoadConfig(nCfg + 'Voice.xml');

    nStr := '网络语音服务';
    if FileExists(nCfg + 'NetVoice.xml') then
    begin
      if not Assigned(gNetVoiceHelper) then
        gNetVoiceHelper := TNetVoiceManager.Create;
      gNetVoiceHelper.LoadConfig(nCfg + 'NetVoice.xml');
    end;     

    nStr := '喷码机';
    gCodePrinterManager.LoadConfig(nCfg + 'CodePrinter.xml');

    nStr := '小屏显示';
    gDisplayManager.LoadConfig(nCfg + 'LEDDisp.xml');

    {$IFDEF HYRFID201}
    nStr := '华益RFID102';
    if not Assigned(gHYReaderManager) then
    begin
      gHYReaderManager := THYReaderManager.Create;
      gHYReaderManager.LoadConfig(nCfg + 'RFID102.xml');
    end;
    {$ENDIF}

    {$IFDEF M100Reader}
    nStr := '三合一读卡器';
    if not Assigned(gM100ReaderManager) then
    begin
      gM100ReaderManager := TM100ReaderManager.Create;
      gM100ReaderManager.LoadConfig(nCfg + cTTCE_M100_Config);
    end;
    {$ENDIF}

    nStr := '车辆检测器';    
    if FileExists(nCfg + 'TruckProber.xml') then
    begin
      gProberManager := TProberManager.Create;
      gProberManager.LoadConfig(nCfg + 'TruckProber.xml');
    end;

    {$IFDEF FixLoad}
    nStr := '定置装车';
    gSendCardNo.LoadConfig(nCfg + 'PLCController.xml');
    {$ENDIF}

    {$IFDEF BasisWeight}
    nStr := '定量装车业务(称皮毛重、装车)';
    gBasisWeightManager := TBasisWeightManager.Create;
    gBasisWeightManager.LoadConfig(nCfg + 'Tunnels.xml');
    {$ENDIF}

  except
    on E:Exception do
    begin
      nStr := Format('加载[ %s ]配置文件失败: %s', [nStr, E.Message]);
      gSysLoger.AddLog(nStr);
    end;
  end;
end;

{$IFDEF DEBUG}
procedure THardwareWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_2';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := '硬件测试';
  nItem.FFormID := cFI_FormTest2;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure THardwareWorker.InitSystemObject;
begin
  gHardwareHelper := THardwareHelper.Create;
  //远距读头

  if not Assigned(g02NReader) then
    g02NReader := T02NReader.Create;
  //近距读头

  if not Assigned(gMultiJSManager) then
    gMultiJSManager := TMultiJSManager.Create;
  //计数器

  gHardShareData := WhenBusinessMITSharedDataIn;
  //hard monitor share

  {$IFDEF FixLoad}
    gSendCardNo := TReaderHelper.Create;
  //定置装车
  {$ENDIF}
end;

procedure THardwareWorker.BeforeStartServer;
begin
  gTruckQueueManager.StartQueue(gParamManager.ActiveParam.FDB.FID);
  //truck queue

  gHardwareHelper.OnProce := WhenReaderCardArrived;
  gHardwareHelper.StartRead;
  //long reader

  gBlueReader.OnCardArrived := WhenBlueReaderCardArrived;
  if not gHardwareHelper.ConnHelper then gBlueReader.StartReader;
  //blue reader, 如果不使用硬件守护服务器，则服务器独自读卡

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.OnCardProc := WhenHYReaderCardArrived;
    gHYReaderManager.StartReader;
  end;
  {$ENDIF}

  {$IFDEF M100Reader}
  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.OnCardProc := WhenTTCE_M100_ReadCard;
    gM100ReaderManager.StartReader;
  end;
  //三合一读卡器
  {$ENDIF}

  g02NReader.OnCardIn := WhenReaderCardIn;
  g02NReader.OnCardOut := WhenReaderCardOut;
  g02NReader.StartReader;
  //near reader

  gMultiJSManager.SaveDataProc := WhenSaveJS;
  gMultiJSManager.GetTruckProc := GetJSTruck;
  gMultiJSManager.StartJS;
  //counter
  gERelayManager.ControlStart;
  //erelay

  gRemotePrinter.StartPrinter;
  //printer
  gVoiceHelper.StartVoice;
  //voice

  if Assigned(gNetVoiceHelper) then
    gNetVoiceHelper.StartVoice;
  //NetVoice

  gCardManager.StartSender;
  //led display
  gDisplayManager.StartDisplay;
  //small led

  gProberManager.StartProber;
  //truck

  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StartPrinter;
  //sendcard
  {$ENDIF}

  {$IFDEF BasisWeight}  //  定量装车控制
  //gBasisWeightManager.TunnelManager.OnUserParseWeight := WhenParsePoundWeight;  //特殊地磅解析
  gBasisWeightManager.OnStatusChange := WhenBasisWeightStatusChange;
  gBasisWeightManager.StartService;
  {$ENDIF}
end;

procedure THardwareWorker.AfterStopServer;
begin
  gVoiceHelper.StopVoice;
  //voice
  gRemotePrinter.StopPrinter;
  //printer
  if Assigned(gNetVoiceHelper) then
    gNetVoiceHelper.StopVoice;
  //NetVoice  

  gERelayManager.ControlStop;
  //erelay
  gMultiJSManager.StopJS;
  //counter

  g02NReader.StopReader;
  g02NReader.OnCardIn := nil;
  g02NReader.OnCardOut := nil;

  gHardwareHelper.StopRead;
  gHardwareHelper.OnProce := nil;
  //reader

  gBlueReader.StopReader;
  gBlueReader.OnCardArrived := nil;
  //blue reader

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.StopReader;
    gHYReaderManager.OnCardProc := nil;
  end;
  {$ENDIF}

  {$IFDEF M100Reader}
  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.StopReader;
    gM100ReaderManager.OnCardProc := nil;
  end;
  //三合一读卡器
  {$ENDIF}

  gDisplayManager.StopDisplay;
  //small led
  gCardManager.StopSender;
  //led

  gProberManager.StopProber;
  //truck

  gTruckQueueManager.StopQueue;
  //queue

  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StopPrinter;
  //sendcard
  {$ENDIF}

  {$IFDEF BasisWeight}
  gBasisWeightManager.StopService;
  gBasisWeightManager.OnStatusChange := nil;
  {$ENDIF}
  
end;

end.
