
unit UMgrSendCardNo;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdComponent, IdTCPConnection,
  IdTCPClient, IdUDPServer, IdGlobal, IdSocketHandle, USysLoger, UWaitItem,
  ULibFun;

type
  PRPDataBase = ^TRPDataBase;
  TRPDataBase = record
    FCommand   : Byte;     //命令字
    FDataLen   : Word;     //数据长
  end;

  PRPPrintBill = ^TRPPrintBill;
  TRPPrintBill = record
    FBase      : TRPDataBase;
    FBill      : string;
  end;

const
  cRPCmd_PrintBill  = $10;  //打印单
  cSizeRPBase       = SizeOf(TRPDataBase);

type
  PHostItem = ^THostItem;
  THostItem = record
    FID        : string;
    FName      : string;
    FHost      : string;
    FPort      : Integer;
  end;

  TRecTcpClient = record
    FTcpClient: TIdTCPClient;
    FTunnel: string;
  end;

  TReaderHelper = class;
  TReaderConnector = class(TThread)
  private
    FOwner: TReaderHelper;
    //拥有者
    FBuffer: TList;
    //发送缓冲
    FWaiter: TWaitObject;
    //等待对象
    //FClient: TIdTCPClient;
    //网络对象
  protected
    procedure DoExuecte;
    procedure Execute; override;
    //执行线程
  public
    FClientCount: Integer;
    FClientLIst: array of TIdTCPClient;
    FClientListRec: array of TRecTcpClient;
    constructor Create(AOwner: TReaderHelper);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TReaderHelper = class(TObject)
  private
    FPrinter: TReaderConnector;
    //打印对象
    FBuffData: TList;
    //临时缓冲
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    procedure ClearBuffer(const nList: TList);
    //清理缓冲
  public
    FHostList: TList;
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartPrinter;
    procedure StopPrinter;
    //启停读取
    procedure SendCardNo(const nBill: string);
    //打印单
  end;

var
  gSendCardNo: TReaderHelper = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TReaderHelper, '定置装车服务', nEvent);
end;

constructor TReaderHelper.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
  FHostList := TList.Create;
end;

destructor TReaderHelper.Destroy;
begin
  StopPrinter;
  ClearBuffer(FBuffData);
  FBuffData.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TReaderHelper.ClearBuffer(const nList: TList);
var nIdx: Integer;
    nBase: PRPDataBase;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nBase := nList[nIdx];

    case nBase.FCommand of
     cRPCmd_PrintBill : Dispose(PRPPrintBill(nBase));
    end;

    nList.Delete(nIdx);
  end;
end;

procedure TReaderHelper.StartPrinter;
begin
  if not Assigned(FPrinter) then
    FPrinter := TReaderConnector.Create(Self);
  FPrinter.WakupMe;
end;

procedure TReaderHelper.StopPrinter;
begin
  if Assigned(FPrinter) then
    FPrinter.StopMe;
  FPrinter := nil;
end;

//Desc: 对nBill执行打印操作
procedure TReaderHelper.SendCardNo(const nBill: string);
var nIdx: Integer;
    nPtr: PRPPrintBill;
    nBase: PRPDataBase;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nBase := FBuffData[nIdx];
      if nBase.FCommand <> cRPCmd_PrintBill then Continue;

      nPtr := PRPPrintBill(nBase);
      if CompareText(nBill, nPtr.FBill) = 0 then Exit;
    end;

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCommand := cRPCmd_PrintBill;
    nPtr.FBill := nBill;

    if Assigned(FPrinter) then
      FPrinter.WakupMe;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 载入nFile配置文件
procedure TReaderHelper.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
    nHost: PHostItem;
    nIdx: Integer;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('items');
    if Assigned(nNode) then
    begin
      for nIdx:=0 to nNode.NodeCount - 1 do
      begin
        New(nHost);
        FHostList.add(nhost);
        nTmp := nNode.Nodes[nIdx];
        with nHost^ do
        begin
          FID    := nTmp.NodeByName('id').ValueAsString;
          FName  := nTmp.NodeByName('name').ValueAsString;;
          FHost  := nTmp.NodeByName('ip').ValueAsString;
          FPort  := nTmp.NodeByName('port').ValueAsInteger;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TReaderConnector.Create(AOwner: TReaderHelper);
var
  i, nCount: integer;
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  nCount := FOwner.FHostList.Count;
  SetLength(FClientLIst,nCount);
  for i := 0 to nCount -1 do
  begin
    FClientLIst[i] := TIdTCPClient.Create;
    FClientLIst[i].ReadTimeout := 5 * 1000;
    FClientLIst[i].ConnectTimeout := 5 * 1000;
  end;

  SetLength(FClientListRec,nCount);
  for i := 0 to nCount -1 do
  begin
    FClientListRec[i].FTcpClient := TIdTCPClient.Create;
    FClientListRec[i].FTcpClient.ReadTimeout := 5 * 1000;
    FClientListRec[i].FTcpClient.ConnectTimeout := 5 * 1000;
    FClientListRec[i].FTunnel := PHostItem(FOwner.FHostList[i]).FID;
  end;

  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;

  {FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000; }
end;

destructor TReaderConnector.Destroy;
var
  i: Integer;
begin
  for i := 0 to FOwner.FHostList.Count -1 do
  begin
    FClientLIst[i].Disconnect;
    FClientLIst[i].Free;
  end;

  for i := 0 to FOwner.FHostList.Count -1 do
  begin
    FClientListRec[i].FTcpClient.Disconnect;
    FClientListRec[i].FTcpClient.Free;
  end;

  {FClient.Disconnect;
  FClient.Free;}

  FOwner.ClearBuffer(FBuffer);
  FBuffer.Free;

  FWaiter.Free;
  inherited;
end;

procedure TReaderConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TReaderConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TReaderConnector.Execute;
var
  nIdx, i: Integer;
  nHost: PHostItem;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    //循环配置服务端IP，port
    FClientCount := FOwner.FHostList.Count;
    for nIdx := 0 to FClientCount - 1 do
    begin
      nHost := FOwner.FHostList.Items[nIdx];

      try
        if not FClientLIst[nIdx].Connected then
        begin
          FClientLIst[nIdx].Host := nHost.FHost;
          FClientLIst[nIdx].Port := nhost.FPort;
          FClientLIst[nIdx].Connect;
        end;
      except
        WriteLog('定置装车 ['+nhost.FHost+'] 服务连接失败.'); 
        FClientLIst[nIdx].Disconnect;
        Continue;
      end;
    end;

    {try
      if not FClient.Connected then
      begin
        FClient.Host := '';//FOwner.FHost.FHost;
        FClient.Port :=  0;//FOwner.FHost.FPort;
        FClient.Connect;
      end;
    except
      WriteLog('连接远程打印服务失败.');
      FClient.Disconnect;
      Continue;
    end; }

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        FBuffer.Add(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    try
      DoExuecte;
      FOwner.ClearBuffer(FBuffer);
    except
      FOwner.ClearBuffer(FBuffer);
      for i := 0 to FClientCount -1 do
      begin
        FClientLIst[i].Disconnect;

        if Assigned(FClientLIst[i].IOHandler) then
          FClientLIst[i].IOHandler.InputBuffer.Clear;
      end;

      //FClient.Disconnect;
      //if Assigned(FClient.IOHandler) then
      //  FClient.IOHandler.InputBuffer.Clear;
      raise;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TReaderConnector.DoExuecte;
var nIdx, i: Integer;
    nBuf,nTmp: TIdBytes;
    nPBase: PRPDataBase;
    nStr, nTunnel: string;
begin
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nPBase := FBuffer[nIdx];

    if nPBase.FCommand = cRPCmd_PrintBill then
    begin
      SetLength(nTmp, 0);
      nTmp := ToBytes(PRPPrintBill(nPBase).FBill);
      nPBase.FDataLen := Length(nTmp);

      nBuf := RawToBytes(nPBase^, cSizeRPBase);
      AppendBytes(nBuf, nTmp);

      nStr := PRPPrintBill(nPBase).FBill;
      nTunnel := Copy(nStr,0,Pos('@',nStr)-1);

      for i := 0 to FClientCount -1 do
      begin
        if FClientListRec[i].FTunnel = nTunnel then
        begin
          FClientListRec[i].FTcpClient.Socket.Write(nBuf);
          Break;
        end;
      end;

      {for i := 0 to FClientCount -1 do
      begin
        FClientLIst[i].Socket.Write(nBuf);
      end;}
      //FClient.Socket.Write(nBuf);
    end;
  end;
end;

initialization
  gSendCardNo := TReaderHelper.Create;
finalization
  FreeAndNil(gSendCardNo);
end.
