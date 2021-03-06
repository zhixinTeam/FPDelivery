{*******************************************************************************
  作者: dmzn@163.com 2012-4-22
  描述: 硬件动作业务
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB, UMgrVoiceNet,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue, UMgrBasisWeight,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrRemotePrint, UMgrTruckProbe,
  UMgrLEDDisp, UMgrRFID102, UBlueReader,UMgrTTCEM100,
  UMgrSendCardNo, DateUtils, UFormCtrl;


procedure WriteNearReaderLog(const nEvent: string);
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
//有新卡号到达读头
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//现场读头有新卡号
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//现场读头卡号超时
procedure WhenBusinessMITSharedDataIn(const nData: string);
//业务中间件共享数据
function GetJSTruck(const nTruck,nBill: string): string;
//获取计数器显示车牌
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//保存计数结果
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
procedure WhenBasisWeightStatusChange(const nTunnel: PBWTunnel);
//定量装车状态改变

function GetLadingOrders(const nCard,nPost: string; var nData: TLadingBillItems): Boolean;
function GetLadingBills(const nCard,nPost: string; var nData: TLadingBillItems): Boolean;
function SaveBill(const nBillData: string): string;
//保存交货单
function SaveOrder(const nBillData: string): string;
//保存采购单
function SaveBillCard(const nBill, nCard: string): Boolean;
//保存交货单磁卡
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//保存采购单磁卡
//function GetWebOrderByCard(const nCard: string): Boolean;
//通过卡号获取商城订单

//推送消息到微信平台
procedure SendMsgToWebMall(const nLid,nFactoryId:string;const nBillType:string);
//发送消息
function Do_send_event_msg(const nXmlStr: string): string;
//修改网上订单状态
function ModifyWebOrderStatus(const nLId,nBillType:string):string;
//修改网上订单状态
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;

procedure PustMsgToWeb(nList,nFactId,nBillType:string);

function GetWebOrderByCard(const nCard: string): Boolean;

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UWorkerBusiness,UMITConst;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2015-08-06
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessPurchaseOrder(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrder);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-16
//Parm: 命令;数据;参数;输出
//Desc: 调用硬件守护上的业务对象
function CallHardwareCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-23
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Parm: 开单数据
//Desc: 保存交货单,返回交货单号列表
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Parm: 开单数据
//Desc: 保存采购单,返回交货单号列表
function SaveOrder(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号
//Desc: 获取磁卡使用类型
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2018-03-20
//Parm: 磁卡号
//Desc: 获取磁卡使用类型
function GetCardLength(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardLength, nCard, '', @nOut);
  //xxxxx
end;

//Parm: 磁卡号
//Desc: 通过卡号取网络订单信息
function GetWebOrderByCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetWebOrderByCard, nCard, '', @nOut);
//  if not Result then
//    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象zyw:', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: 磁卡号;岗位;采购单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2015-08-06
//Parm: 岗位;采购单列表
//Desc: 保存nPost岗位上的采购单数据
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: 事件描述;岗位标识
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, '硬件守护辅助', nEvent);
end;

procedure BlueOpenDoor(const nReader: string);
var nIdx: Integer;
begin
  nIdx := 0;
  if nReader <> '' then
  while nIdx < 5 do
  begin
    if gHardwareHelper.ConnHelper then
         gHardwareHelper.OpenDoor(nReader)
    {$IFDEF BlueCard}
    else gHYReaderManager.OpenDoor(nReader);
    {$ELSE}
    else gHYReaderManager.OpenDoor(nReader);
    {$ENDIF}

    Inc(nIdx);
  end;
end;

procedure WriteBasisWeightLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBasisWeightManager, '库地磅 UHardBusiness', nEvent);
end;

//Date: 2019-03-12
//Parm: 通道号;提示信息;车牌号
//Desc: 在nTunnel的小屏上显示信息
procedure ShowLEDHint(const nTunnel: string; nHint: string;
  const nTruck: string = '');
begin
  if nTruck <> '' then
    nHint := nTruck + StringOfChar(' ', 12 - Length(nTruck)) + nHint;
  //xxxxx
  
  if Length(nHint) > 24 then
    nHint := Copy(nHint, 1, 24);
  gERelayManager.ShowTxt(nTunnel, nHint);
end;

//Date: 2017-10-16
//Parm: 内容;岗位;业务成功
//Desc: 播放门岗语音
procedure MakeGateSound(const nText,nPost: string; const nSucc: Boolean);
var nStr: string;
    nInt: Integer;
begin
  if nPost='' then Exit;
  try
    if gNetVoiceHelper=nil then Exit;
    if nSucc then
         nInt := 2
    else nInt := 3;

    //gHKSnapHelper.Display(nPost, nText, nInt);
    //小屏显示

    //if GetHasVoice(nPost) then
      gNetVoiceHelper.PlayVoice(nText, nPost);
    //播发语音
    //WriteHardHelperLog(Format('发送语音[%s %s]', [nPost ,nText]));
  except
    on nErr: Exception do
    begin
      nStr := '播放[ %s ]语音失败,描述: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteHardHelperLog(nStr);
    end;
  end;
end;

//Date: 2012-4-22
//Parm: 卡号
//Desc: 对nCard放行进厂
procedure MakeTruckIn(const nCard,nReader: string; const nDB: PDBWorker);
var nStr,nTruck,nCardType, nSQL: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nRet: Boolean;
    nList, nTmp, nListBill: TStrings;
    nBillData, nBillID: string;
    Fbegin:TDateTime;
begin
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //同读头同卡,在2分钟内不做二次进厂业务.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);

  //去网上取订单
  if not nRet then
  begin
    nRet := GetWebOrderByCard(nCard);
  end;

  if nRet then
  begin
    if not GetCardUsed(nCard, nCardType) then Exit;
    
    if nCardType = sFlag_Provide then
          nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)
    else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);
  end;

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要进厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //未进长,或已进厂

    nStr := '车辆[ %s ]下一状态为:[ %s ],进厂刷卡无效.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) then
      begin
        BlueOpenDoor(nReader);
        //抬杆

        nStr := '车辆[ %s ]再次抬杆操作.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    Exit;
  end;

  if nCardType = sFlag_Provide then
  begin
    if not SaveLadingOrders(sFlag_TruckIn, nTrucks) then
    begin
      nStr := '车辆[ %s ]进厂放行失败.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      BlueOpenDoor(nReader);
      //抬杆
    end;

    nStr := '原材料卡[%s]进厂抬杆成功';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;
  //采购磁卡直接抬杆

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //非延时队列(厂内模式)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '车辆[ %s ]没有在调度队列中.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '车辆[ %s ]进厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if gTruckQueueManager.IsTruckAutoIn then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
  end else
  begin
    BlueOpenDoor(nReader);
    //抬杆
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //厂外模式,进厂时绑定道号(一车多单)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
      nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
              nPTruck.FBill]);
      //xxxxx

      gDBConnManager.WorkerExec(nDB, nStr);
      //绑定通道
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: 卡号;读头;打印机;化验单打印机
//Desc: 对nCard放行出厂
procedure MakeTruckOut(const nCard,nReader,nPrinter: string;
 const nHYPrinter: string = '');
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  //判断是否需要录入封签号
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FMustSeal and (FSeal = '') then
    begin
      nStr := '车辆[ %s ] 必须录入封签号.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
  end;

  if nCardType = sFlag_Provide then
        nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks)
  else  nRet := SaveLadingBills(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nReader <> '' then
    BlueOpenDoor(nReader);
  //抬杆

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney,nTrucks[nIdx].FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //磁卡类型
    if (nHYPrinter <> '') and (nTrucks[0].FPrintHY) then
      nStr := nStr + #6 + nHYPrinter;
    //化验单打印机

    if nPrinter = '' then
         gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr)
    else gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
  end; //打印报表
end;

//Date: 2016-5-4
//Parm: 卡号;读头;打印机
//Desc: 对nCard放行出
function MakeTruckOutM100(const nCard,nReader,nPrinter, nHYPrinter: string): Boolean;
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  Result := False;               
  nCardType := '';

  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
    nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
    nRet := False;
  //if nCardType = sFlag_DuanDao then
  //  nRet := GetDuanDaoItems(nCard, sFlag_TruckOut, nTrucks)else
     
  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    Result := GetCardLength(nCard);
    //磁卡已无效

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);
    Result := GetCardLength(nCard);
    //磁卡已无效

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  //判断是否需要录入封签号
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FMustSeal and (FSeal = '') then
    begin
      nStr := '车辆[ %s ] 必须录入封签号.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;
  end;

  if nCardType = sFlag_Provide then
    nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Sale then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
    nRet := False;
  //if nCardType = sFlag_DuanDao then
  //  nRet := SaveDuanDaoItems(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  nRet := GetCardLength(nCard);
  //为true是短期卡，false 是长期卡
  if nReader <> '' then
    BlueOpenDoor(nReader);
  //抬杆

  Result := nRet;

  //发起一次打印
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney, FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //磁卡类型

    //富平
    if (nPrinter = '') and (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(FID + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + nStr);
    end else
    if (nPrinter <> '') and (nHyprinter <> '') then
    begin
      gRemotePrinter.PrintBill(FID + #6 + nHyprinter + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nHyprinter + nStr);
    end else
    if (nPrinter = '') then
    begin
      gRemotePrinter.PrintBill(FID + #6 + nHyprinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nHyprinter + nStr);
    end else
    if (nHyprinter = '') then
    begin
      gRemotePrinter.PrintBill(FID + #9 + nPrinter + nStr);
      WriteHardHelperLog(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
    end;
  end;
  //打印报表
end;

//Date: 2019-03-12
//Parm: 交货单号;重量
//Desc: 依据nBill状态写入nValue重量
function SavePoundData(const nTunnel: PBWTunnel; const nValue: Double;nChangeStatus:Boolean=False): Boolean;
var nStr, nStatus : string;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    nStr := 'Select L_Status,L_Value,L_PValue,IsNull(L_MValue, 0) L_MValue From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nTunnel.FBill]);

    with gDBConnManager.SQLQuery(nStr, nDBConn) do
    begin
      if RecordCount < 1 then
      begin
        WriteNearReaderLog(Format('交货单[ %s ]已丢失', [nTunnel.FBill]));
        Exit;
      end;

      nStatus := FieldByName('L_Status').AsString;
      if nStatus = sFlag_TruckIn then //皮重
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckBFP),
                SF('L_NextStatus', sFlag_TruckFH),
                SF('L_LadeTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', nValue, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_IsBasisWeightWithPM', sFlag_Yes)
          	 ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        gBasisWeightManager.SetTruckPValue(nTunnel.FID, nValue);
        //更新通道皮重, 确认磅重上限
      end else
      begin
        nStr := MakeSQLByStr([
                    SF('L_Status', sFlag_TruckFH),
                    SF('L_NextStatus', sFlag_TruckBFM),
                    SF('L_IsBasisWeightWithPM', sFlag_Yes)
                  ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        if (nValue>(FieldByName('L_MValue').AsFloat)) then
        begin
            nStr := MakeSQLByStr([
                    SF('L_MValue', nValue, sfVal),
                    SF('L_MDate', sField_SQLServer_Now, sfVal)
                  ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
            gDBConnManager.WorkerExec(nDBConn, nStr);
        end;

        // 经光栅检测通过  表示车辆按要求完全在榜上停稳 
        if nChangeStatus then
        begin
            nStr := MakeSQLByStr([
                    SF('L_Status', sFlag_TruckBFM),
                    SF('L_NextStatus', sFlag_TruckOut),
                    SF('L_MValue', nValue, sfVal),
                    SF('L_MDate', sField_SQLServer_Now, sfVal)
                  ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
            gDBConnManager.WorkerExec(nDBConn, nStr);
        end;
      end; //放灰状态,只更新重量,出厂时计算净重
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;   
end;

//Date: 2019-03-12
//Parm: 交货单号;重量
//Desc: 依据nBill状态写入nValue重量
function SaveBillStatus(const nTunnel: PBWTunnel) : Boolean;
var nStr, nStatus : string;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
//    nStr := 'Select L_Status,L_Value,L_PValue,IsNull(L_MValue, 0) L_MValue From %s Where L_ID=''%s''';
//    nStr := Format(nStr, [sTable_Bill, nTunnel.FBill]);
//    gDBConnManager.SQLQuery(nStr, nDBConn);
    if nTunnel.FStatusNew = bsStart then
    begin
      //**************************************************************************
      nStr := MakeSQLByStr([ SF('L_Status', sFlag_TruckFH),
                             SF('L_NextStatus', sFlag_TruckBFM)
                              ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
      gDBConnManager.WorkerExec(nDBConn, nStr);
      WriteNearReaderLog(Format('[ %s ] 更新订单状态为 已放灰', [nTunnel.FBill]));
      //**************************************************************************
      nStr := 'Insert into $FHLog(F_ID,F_PValue,F_Date)Select top 1 ''$FID'', $PValue, GetDate() From Master..SysDatabases '+
              'Where Not exists(Select * From $FHLog Where F_ID=''$FID'')';
      nStr := MacroValue(nStr, [MI('$FHLog', sTable_FHLog), MI('$FID', nTunnel.FBill), MI('$PValue', FloatToStr(nTunnel.FValTruckP) )]);
      gDBConnManager.WorkerExec(nDBConn, nStr);

      WriteNearReaderLog(Format('[ %s ] 更新装车皮重 %g ', [nTunnel.FBill, nTunnel.FValTruckP]));
    end
    else if nTunnel.FStatusNew = bsClose then
    begin
      nStr := 'UPDate $FHLog Set F_MValue= $MValue Where F_ID=''$FID'')';
      nStr := MacroValue(nStr, [MI('$FHLog', sTable_FHLog), MI('$FID', nTunnel.FBill), MI('$MValue', FloatToStr(nTunnel.FValMax))]);
      gDBConnManager.WorkerExec(nDBConn, nStr);

      WriteNearReaderLog(Format('[ %s ] 更新装车毛重 %g ', [nTunnel.FBill, nTunnel.FValMax]));
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2019-03-11
//Parm: 定量装车通道
//Desc: 当nTunnel状态改变时,处理业务
procedure WhenBasisWeightStatusChange(const nTunnel: PBWTunnel);
var nStr, nTruck, nVoiceTips, nVoiceID: string;
begin
  if nTunnel.FStatusNew = bsProcess then
  begin
    if nTunnel.FWeightMax > 0 then
         nStr := Format('%.2f/%.2f', [nTunnel.FWeightMax, nTunnel.FValTunnel])
    else nStr := Format('%.2f/%.2f', [nTunnel.FValue, nTunnel.FValTunnel]);

    ShowLEDHint(nTunnel.FID, nStr, nTunnel.FParams.Values['Truck']);
    Exit;
  end;

  case nTunnel.FStatusNew of
   bsInit      : WriteNearReaderLog('初始化:' + nTunnel.FID);
   bsNew       : WriteNearReaderLog('新添加:' + nTunnel.FID);
   bsStart     : WriteNearReaderLog('开始称重:' + nTunnel.FID);
   bsClose     : WriteNearReaderLog('称重关闭:' + nTunnel.FID);
   bsDone      : WriteNearReaderLog('称重完成:' + nTunnel.FID);
   bsStable    : WriteNearReaderLog('数据平稳:' + nTunnel.FID);
  end; //log

  if nTunnel.FStatusNew = bsClose then
  begin
    ShowLEDHint(nTunnel.FID, '装车业务关闭', nTunnel.FParams.Values['Truck']);
    WriteNearReaderLog(nTunnel.FID+'、装车业务关闭');

    gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_No);
    //通知DCS关闭装车
    Exit;
  end;

  nVoiceID:= '';  nTruck:= '';
  nVoiceID:= nTunnel.FTunnel.FOptions.Values['VoiceCard'];
  nTruck  := nTunnel.FParams.Values['Truck'];                               
  if nTunnel.FStatusNew = bsDone then
  begin
    {$IFDEF BasisWeightWithPM}
    ShowLEDHint(nTunnel.FID, '装车完成请等待保存称重');
                                                                    MakeGateSound(nTruck+'装车完成、等待保存称重', nVoiceID, False);

    WriteNearReaderLog(Format('%s %s 装车完成等待保存称重', [nTunnel.FID, nTruck]));
    {$ELSE}
    SaveBillStatus(nTunnel);
    ShowLEDHint(nTunnel.FID, '装车完成 请下磅');
    WriteNearReaderLog(Format('%s %s 装车完成', [nTunnel.FID, nTruck]));
                                                                    MakeGateSound(nTruck+'装车完成、请下磅', nVoiceID, False);

    gProberManager.OpenTunnel(nTunnel.FID + '_Z');
    //打开道闸
    {$ENDIF}
                                      {
    gERelayManager.LineClose(nTunnel.FID);
    //停止装车
    gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_No);
    //通知DCS关闭装车                     }
    Exit;
  end;

  if nTunnel.FStatusNew = bsStable then
  begin
    {$IFNDEF BasisWeightWithPM}
    SaveBillStatus(nTunnel);
    Exit; //非库底计量,不保存数据
    {$ENDIF}

    if (not gProberManager.IsTunnelOK(nTunnel.FID))
      {$IFDEF ProberMidChk} or gProberManager.IsTunnelOK(nTunnel.FID+'MID') {$ENDIF}
       then
    begin
      nTunnel.FStableDone := False;
      //继续触发事件
      ShowLEDHint(nTunnel.FID, '车辆未停到位 请移动车辆');
                                                                    //MakeGateSound(nTruck+'未停到位 请移动车辆', nVoiceID, False);
      Exit;
    end;

    ShowLEDHint(nTunnel.FID, '数据平稳准备保存称重');
    WriteNearReaderLog(nTunnel.FID+'、数据平稳准备保存称重');
                                   
    if SavePoundData(nTunnel, nTunnel.FValHas, True) then
    begin
      gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_Yes);
      //添加可放灰标记

      if nTunnel.FWeightDone then
      begin
        ShowLEDHint(nTunnel.FID, '毛重保存完毕请下磅.');            MakeGateSound(nTruck+'毛重保存完毕请下磅', nVoiceID, False);
        WriteNearReaderLog(Format('%s %s 毛重保存完毕', [nTunnel.FID, nTruck]));
        gProberManager.OpenTunnel(nTunnel.FID + '_Z');
      end else
      begin
        ShowLEDHint(nTunnel.FID, '保存完毕请等待装车.');
        WriteNearReaderLog(Format('%s %s 保存完毕、等待装车', [nTunnel.FID, nTruck]));
                                                                    MakeGateSound(nTruck+'请等待装车', nVoiceID, False);
      end;
    end else
    begin
      nTunnel.FStableDone := False;
      //继续触发事件
      ShowLEDHint(nTunnel.FID, '称重保存失败请联系工作人员');       MakeGateSound(nTruck+'称重保存失败请联系工作人员', nVoiceID, False);
      WriteNearReaderLog(Format('%s %s 称重失败、请管理员协助', [nTunnel.FID, nTruck]));
    end;
  end
  else if nTunnel.FStatusNew = bsStart then
  begin
    SaveBillStatus(nTunnel);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/29
//Parm: 三合一读卡器
//Desc: 处理三合一读卡器信息
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '三合一读卡器卡号'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}
  
  try
    if not nItem.FVirtual then Exit;
    case nItem.FVType of
      rtOutM100 :
        nRetain := MakeTruckOutM100(nItem.FCard, nItem.FVReader, nItem.FVPrinter, nItem.FVHYPrinter)
    else
        gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain); //为TRUE吞卡

    nStr:= Format('吞卡机：%s  卡号 %s ,卡片回收：%s ', [ nItem.FID, nItem.FCard, BoolToStr(nRetain, True)]);
    WriteHardHelperLog(nStr);
  end;
end;

//Date: 2012-10-19
//Parm: 卡号;读头
//Desc: 检测车辆是否在队列中,决定是否抬杆
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要通过道闸的车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '车辆[ %s ]不在队列,禁止通过道闸.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader);
  //抬杆

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //更新提货时间,语音程序将不再叫号.
  end;
end;

//Date: 2012-4-22
//Parm: 读头数据
//Desc: 对nReader读到的卡号做具体动作
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nCard: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived进入.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nCard := Fields[0].AsString;
    end else
    begin
      nStr := Format('磁卡号[ %s ]匹配失败.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nCard, nReader.FID, nDBConn);
      end else

      if nReader.FType = rtOut then
      begin
        if Assigned(nReader.FOptions) then
             nStr := nReader.FOptions.Values['HYPrinter']
        else nStr := '';
        MakeTruckOut(nCard, nReader.FID, nReader.FPrinter, nStr);
      end else

      if nReader.FType = rtGate then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID);
        //抬杆
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nCard, nReader.FID, nDBConn);
        //抬杆
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2014-10-25
//Parm: 读头数据
//Desc: 华益读头磁卡动作
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('华益标签 %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
      rt900 :gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
      rt02n :g02NReader.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard);
    end;
  end else g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
end;

procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('蓝卡读卡器 %s:%s', [nHost.FReaderID, nCard.FCard]));
  {$ENDIF}

  gHardwareHelper.SetReaderCard(nHost.FReaderID, nCard.FCard, False);
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '现场近距读卡器', nEvent);
end;

//Date: 2012-4-24
//Parm: 车牌;通道;是否检查先后顺序;提示信息
//Desc: 检查nTuck是否可以在nTunnel装车
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //不在当前队列
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //刷卡道与队列道品种不匹配

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //挪动车辆到新道

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '车辆[ %s ]自主换道[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //袋装重调队列

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]不在[ %s ]队列中.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //同步物料名
    Result := True;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: 通道号;交货单;
//Desc: 在nTunnel上打印nBill防伪码
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;

  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '向通道[ %s ]发送防违流码失败,描述: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: 车牌;通道;交货单;启动计数
//Desc: 对在nTunnel的车辆开启计数器
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]已不再队列.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon

      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: 交货单号
//Desc: 查询nBill上的已装量
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := '通道[ %s ]装车中,业务无效.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('通道[ ' + nTunnel + ' ]: MakeTruckLadingDai进入.');

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要栈台提货车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //重新定位车辆所在车道
    if IsJSRun then Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //检查通道

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //刷卡通道对应的交货单
      Continue;
    end;

    FSelected := False;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法栈台提货.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '袋装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '车辆[ %s ]栈台提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: 车辆;通道
//Desc: 授权nTruck在nTunnel车道放灰
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel: string);
var nStr,nTmp,nCardUse: string;
   nField: TField;
   nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_Card');
      if Assigned(nField) then nTmp := nField.AsString;

      nField := FindField('T_CardUse');
      if Assigned(nField) then nCardUse := nField.AsString;

      if nCardUse = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  gERelayManager.LineOpen(nTunnel);
  //打开放灰


  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);

  {$IFDEF HLST}
  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue)+'吨';
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue)+'吨';
  {$ENDIF}
  //xxxxx

  WriteNearReaderLog('发送通道 '+nTunnel+' 小屏、显示内容： '+nStr);
  gERelayManager.ShowTxt(nTunnel, nStr);
  //显示内容
end;

//Date: 2019-03-12
//Parm: 车辆;通道;皮重
//Desc: 授权nTruck在nTunnel车道放灰
procedure TruckStartFHEx(const nTruck: PTruckItem; const nTunnel: string;
 const nLading: TLadingBillItem);
var nStr: string;
begin
  gERelayManager.LineOpen(nTunnel);
  //开始放灰

  nStr := Format('Truck=%s', [nTruck.FTruck]);
  gBasisWeightManager.StartWeight(nTunnel, nTruck.FBill, nTruck.FValue,
    nLading.FPData.FValue, nStr);
  //开始定量装车

  if nLading.FStatus <> sFlag_TruckIn then
    gBasisWeightManager.SetParam(nTunnel, 'CanFH', sFlag_Yes);
  //添加可放灰标记
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr, nTmp: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan进入.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要放灰车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //未装或已装

    nStr := '车辆[ %s ]下一状态为:[ %s ],无法放灰.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr);
    Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';
    {$IFDEF HLST}
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + Format('请到%s库', [nPLine.FName]);
    {$ENDIF}
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //检查通道

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := '散装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    {$IFDEF FPST}
    //富平生态采用包装读卡器，只读一次，显示品种即可
    nStr := nPTruck.FTruck + StringOfChar(' ', 12 - Length(nPTruck.FTruck));
    nTmp := nPTruck.FStockName + FloatToStr(nPTruck.FValue);
    nStr := nStr + nPTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
            FloatToStr(nPTruck.FValue);
    //xxxxx
    gERelayManager.ShowTxt(nTunnel, nStr); 

    WriteNearReaderLog('zyww::'+nTunnel+'@'+nCard);
    //发送卡号和通道号到定置装车服务器
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    {$ELSE}
      TruckStartFH(nPTruck, nTunnel);
      {$IFDEF FixLoad}
      WriteNearReaderLog('启动定置装车::'+nTunnel+'@'+nCard);
      //发送卡号和通道号到定置装车服务器
      gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
      {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '车辆[ %s ]放灰处提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF FPST}
  WriteNearReaderLog('zyww::'+nTunnel+'@'+nCard);
  gSendCardNo.SendCardNo(nTunnel + '@'+ nCard);
  //富平生态采用包装读卡器，读一次不接连锁，只显示品种车辆即可
  nStr := nPTruck.FTruck + StringOfChar(' ', 12 - Length(nPTruck.FTruck));
  nTmp := nPTruck.FStockName + FloatToStr(nPTruck.FValue);
  nStr := nStr + nPTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nPTruck.FValue);
  //xxxxx
  gERelayManager.ShowTxt(nTunnel, nStr);
  {$ELSE}
    TruckStartFH(nPTruck, nTunnel);
    //执行放灰
    {$IFDEF FixLoad}
    WriteNearReaderLog('启动定置装车::'+nTunnel+'@'+nCard);
    //发送卡号和通道号到定置装车服务器
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    {$ENDIF}
  {$ENDIF}
end;

//Date: 2019-03-12
//Parm: 磁卡号;通道号
//Desc: 对nCard执行称量操作
procedure MakeTruckWeightFirst(const nCard,nTunnel: string;nVoiceID:string='');
var nStr: string;
    nIdx: Integer;
    nPound: TBWTunnel;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckWeightFirst进入.');
  {$ENDIF}                                                 

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    ShowLEDHint(nTunnel, '读取交货单信息失败');
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要装料车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    ShowLEDHint(nTunnel, '没有需要装料车辆');
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FStatus = sFlag_TruckNone then
    begin
      ShowLEDHint(nTunnel, '请进厂刷卡', nTrucks[0].FTruck);
      MakeGateSound(Format('%s 请到进厂点刷卡', [nTrucks[0].FTruck]), nVoiceID, False);
      Exit;
    end;
  end;

  if gBasisWeightManager.IsTunnelBusy(nTunnel, @nPound) and
     (nPound.FBill <> nTrucks[0].FID) then //通道忙
  begin
    if nPound.FValTunnel = 0 then //前车已下磅
    begin
      nStr := Format('%s 请等待前车', [nTrucks[0].FTruck]);
      ShowLEDHint(nTunnel, nStr);
      MakeGateSound(nStr, nVoiceID, False);
      Exit;
    end;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);

    nStr := Format('%s 请换道装车', [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, '请换道装车', nTrucks[0].FTruck);
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end; //检查通道

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    nStr := '车辆[ %s ]刷卡,等待称皮重.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    nStr := Format('请 %s 上磅称量皮重', [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, nStr);
    MakeGateSound(nStr, nVoiceID, False);
  end else
  begin
    if nPound.FValTunnel > 0 then
         nStr := '请 %s 上磅装车'
    else nStr := '请 %s 开始装车';

    nStr := Format(nStr, [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, nStr, nTrucks[0].FTruck);
    MakeGateSound(nStr, nVoiceID, False);
  end;

  TruckStartFHEx(nPTruck, nTunnel, nTrucks[0]);
  //执行放灰
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard新到卡号作出动作
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var nStr: string;
begin
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfOut then
    begin
      if Assigned(nHost.FOptions) then
           nStr := nHost.FOptions.Values['HYPrinter']
      else nStr := '';
      MakeTruckOut(nCard, '', nHost.FPrinter, nStr);
    end else
    begin
      if Assigned(nHost.FOptions) then
           nStr := nHost.FOptions.Values['DaiOrSan']
      else nStr := '';

      if nStr = 'S' then
        MakeTruckLadingSan(nCard, nHost.FTunnel)
      else
        MakeTruckLadingDai(nCard, nHost.FTunnel);
    end;
  end else

  if nHost.FType = rtKeep then
  begin
    if Assigned(nHost.FOptions) then
    begin
      if nHost.FOptions.Values['IsBasisWeight'] = sFlag_Yes then
      begin
        MakeTruckWeightFirst(nCard, nHost.FTunnel, nHost.FOptions.Values['VoiceCard']);

        gBasisWeightManager.SetParam(nHost.FTunnel, 'LEDText', nHost.FLEDText, True);
        //附加参数
        Exit;
      end;
    end;

    MakeTruckLadingSan(nCard, nHost.FTunnel);
  end;
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard超时卡作出动作
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut退出.');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  if nHost.FETimeOut then
    gERelayManager.ShowTxt(nHost.FTunnel, '电子标签超出范围')
  else
    gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
    
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: 磁卡号
//Desc: 对nCardNo做自动出厂(模拟读头刷卡)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //模拟刷卡
  end;
end;

//Date: 2012-12-16
//Parm: 共享数据
//Desc: 处理业务中间件与硬件守护的交互数据
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('收到Bus_MIT业务请求:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2015-01-14
//Parm: 车牌号;交货单
//Desc: 格式化nBill交货单需要显示的车牌号
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF LNYK}
  nWorker := nil;
  try
    nStr := 'Select L_StockNo From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := UpperCase(Fields[0].AsString);
      if nStr <> 'BPC-02' then Exit;
      //只处理32.5(b)

      nLen := cMultiJS_Truck - 2;
      Result := 'B-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: 计数器通道
//Desc: 保存nTunnel计数结果
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

procedure SendMsgToWebMall(const nLid,nFactoryId:string;const nBillType:string);
var nBills: TLadingBillItems;
    nXmlStr,nData:string;
    nIdx:Integer;
    nNetWeight:Double;
    MsgType: integer;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  
  nNetWeight := 0;
  if nBillType=sFlag_Sale then
  begin
    //加载提货单信息
    if not GetLadingBills(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else if nBillType=sFlag_Provide then
  begin
    //加载采购订单信息
    if not GetLadingOrders(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;  
  end
  else begin
    Exit;
  end;
  for nIdx := Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin

    if FStatus = 'N' then
      MsgType := 1
    else
    if FStatus = 'O' then
      MsgType := 2
    else
      Exit;

    nNetWeight := FValue;
    nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
        +'<DATA>'
        +'<head>'
        +'	  <Factory>%s</Factory>'
        +'	  <ToUser>%s</ToUser>'
        +'	  <MsgType>%d</MsgType>'
        +'</head>'
        +'<Items>'
        +'	  <Item>'
        +'	      <BillID>%s</BillID>'
        +'	      <Card>%s</Card>'
        +'	      <Truck>%s</Truck>'
        +'	      <StockNo>%s</StockNo>'
        +'	      <StockName>%s</StockName>'
        +'	      <CusID>%s</CusID>'
        +'	      <CusName>%s</CusName>'
        +'	      <CusAccount>0</CusAccount>'
        +'	      <MakeDate></MakeDate>'
        +'	      <MakeMan></MakeMan>'
        +'	      <TransID></TransID>'
        +'	      <TransName></TransName>'
        +'	      <NetWeight>%f</NetWeight>'
        +'	      <Searial></Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'	  </Item>	'
        +'</Items>'
        +'</DATA>';
    nXmlStr := Format(nXmlStr,[nFactoryId, FCusID, MsgType,//cSendWeChatMsgType_DelBill,
               FID, FCard, FTruck, FStockNo, FStockName, FCusID, FCusName,nNetWeight]);
    gSysLoger.AddLog('SendMsgToWebMall::'+nxmlstr);
    
    nXmlStr := PackerEncodeStr(nXmlStr);
    nData := Do_send_event_msg(nXmlStr);

    if ndata<>'' then
    begin
      gSysLoger.AddLog('ResultOFSendMsgToWebMall:'+nData);
    end;
  end;
end;

//发送消息
function Do_send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if TWorkerBusinessCommander.CallMe(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//修改网上订单状态
function ModifyWebOrderStatus(const nLId,nBillType:string):string;
var
  nXmlStr,nData,nSql:string;
  nDBConn: PDBWorker;
  nWebOrderId:string;
  nIdx:Integer;
  FNetWeight:Double;
  nMstType: Integer;
begin
  {$IFNDEF EnableWebMall}
  Exit;
  {$ENDIF}
  Result := '' ;
  FNetWeight := 0;
  nWebOrderId := '';
  nDBConn := nil;
  if nWebOrderId='' then
  begin
    with gParamManager.ActiveParam^ do
    begin
      try
        nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
        if not Assigned(nDBConn) then
        begin
          Exit;
        end;
        if not nDBConn.FConn.Connected then
        nDBConn.FConn.Connected := True;

        //查询网上商城订单
        nSql := 'select WOM_WebOrderID from %s where WOM_LID=''%s''';
        nSql := Format(nSql,[sTable_WebOrderMatch,nLId]);

        with gDBConnManager.WorkerQuery(nDBConn, nSql) do
        begin
          if recordcount>0 then
          begin
            nWebOrderId := FieldByName('WOM_WebOrderID').asstring;
          end;
        end;

        if nWebOrderId='' then Exit;

        if nBillType = sFlag_Sale then
        begin
          //销售净重
          nSql := 'select L_Value,L_Status from %s where l_id=''%s''';
          nSql := Format(nSql,[sTable_Bill,nLId]);
          with gDBConnManager.WorkerQuery(nDBConn, nSql) do
          begin
            if recordcount>0 then
            begin
              FNetWeight := FieldByName('L_Value').asFloat;
              //nEmptyOut := FieldByName('L_EmptyOut').AsString;
              if FieldByName('L_Status').AsString = 'N' then
                nMstType := 0
              else
              if FieldByName('L_Status').AsString = 'O' then
                nMstType := 1
              else Exit;
            end;          
          end;
        end;

        //采购净重
        if nBillType = sFlag_Provide then
        begin
          nSql := 'select sum(d_mvalue) d_mvalue,sum(d_pvalue) d_pvalue from %s where d_oid=''%s'' and d_status=''%s''';
          nSql := Format(nSql,[sTable_OrderDtl,nLId,sFlag_TruckOut]);
          with gDBConnManager.WorkerQuery(nDBConn, nSql) do
          begin
            if recordcount>0 then
            begin
              FNetWeight := FieldByName('d_mvalue').asFloat-FieldByName('d_pvalue').asFloat;
              nMstType := 1
            end
            else
            begin
              nSql := 'select * from %s where O_ID=''%s''';
              nSql := Format(nSql,[sTable_Order,nLId]);
              with gDBConnManager.WorkerQuery(nDBConn, nSql) do
              begin
                if recordcount>0 then
                begin
                  FNetWeight := FieldByName('O_Value').asFloat;
                  nMstType := 0
                end
                else Exit;
              end;
            end;
          end;
        end;
      finally
        gDBConnManager.ReleaseConnection(nDBConn);
      end;
    end;
  end;
  
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head><ordernumber>%s</ordernumber>'
            +'<status>%d</status>'
            +'<NetWeight>%f</NetWeight>'
            +'</head>'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[nWebOrderId,nMstType,FNetWeight]);
  gSysLoger.AddLog('ModifyWebOrderStatus::'+nxmlstr);
  nXmlStr := PackerEncodeStr(nXmlStr);

  nData := Do_ModifyWebOrderStatus(nXmlStr);
  gSysLoger.AddLog(nData);

  if ndata<>'' then
  begin
    gSysLoger.AddLog('ResultOFModifyWebOrderStatus:'+nData);
  end;
  Result := nWebOrderId;
end;

//修改网上订单状态
function Do_ModifyWebOrderStatus(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if TWorkerBusinessCommander.CallMe(cBC_WeChat_complete_shoporders, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

procedure PustMsgToWeb(nList,nFactId,nBillType:string);
var
  nWebOrderId:string;
begin
  try
    nWebOrderId := ModifyWebOrderStatus(nList,nBillType);
  except
    on E: Exception do
    begin
      gSysLoger.AddLog(Format('ModifyWebOrderStatus[ %s ]异常:[ %s ].', [nList,E.Message]));
      Exit;
    end;
  end;
  try
    if nWebOrderId <> '' then
      SendMsgToWebMall(nList,nFactId,nBillType);
  except
    on E: Exception do
    begin
      gSysLoger.AddLog(Format('SendMsgToWebMall[ %s ]异常:[ %s ].', [nList,E.Message]));
      Exit;
    end;
  end;
end;

end.
