{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrRemotePrint,
  UMgrLEDDisp, UMgrRFID102, UBlueReader,UMgrTTCEM100,
  UMgrSendCardNo, DateUtils, UFormCtrl;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
//���¿��ŵ����ͷ
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���¿���
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���ų�ʱ
procedure WhenBusinessMITSharedDataIn(const nData: string);
//ҵ���м����������
function GetJSTruck(const nTruck,nBill: string): string;
//��ȡ��������ʾ����
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//����������
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);

function GetLadingOrders(const nCard,nPost: string; var nData: TLadingBillItems): Boolean;
function GetLadingBills(const nCard,nPost: string; var nData: TLadingBillItems): Boolean;
function SaveBill(const nBillData: string): string;
//���潻����
function SaveOrder(const nBillData: string): string;
//����ɹ���
function SaveBillCard(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//����ɹ����ſ�
//function GetWebOrderByCard(const nCard: string): Boolean;
//ͨ�����Ż�ȡ�̳Ƕ���

//������Ϣ��΢��ƽ̨
procedure SendMsgToWebMall(const nLid,nFactoryId:string;const nBillType:string);
//������Ϣ
function Do_send_event_msg(const nXmlStr: string): string;
//�޸����϶���״̬
function ModifyWebOrderStatus(const nLId,nBillType:string):string;
//�޸����϶���״̬
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
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
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
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
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
//Parm: ����;����;����;���
//Desc: ����Ӳ���ػ��ϵ�ҵ�����
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
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Parm: ��������
//Desc: ���潻����,���ؽ��������б�
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Parm: ��������
//Desc: ����ɹ���,���ؽ��������б�
function SaveOrder(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2018-03-20
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardLength(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardLength, nCard, '', @nOut);
  //xxxxx
end;

//Parm: �ſ���
//Desc: ͨ������ȡ���綩����Ϣ
function GetWebOrderByCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetWebOrderByCard, nCard, '', @nOut);
//  if not Result then
//    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����zyw:', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���;��λ;�ɹ����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2015-08-06
//Parm: ��λ;�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ�������
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: �¼�����;��λ��ʶ
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
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

//Date: 2012-4-22
//Parm: ����
//Desc: ��nCard���н���
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
  end; //ͬ��ͷͬ��,��2�����ڲ������ν���ҵ��.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);

  //ȥ����ȡ����
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
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //δ����,���ѽ���

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],����ˢ����Ч.';
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
        //̧��

        nStr := '����[ %s ]�ٴ�̧�˲���.';
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
      nStr := '����[ %s ]��������ʧ��.';
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
      //̧��
    end;

    nStr := 'ԭ���Ͽ�[%s]����̧�˳ɹ�';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;
  //�ɹ��ſ�ֱ��̧��

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ʱ����(����ģʽ)
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
      nStr := '����[ %s ]û���ڵ��ȶ�����.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '����[ %s ]��������ʧ��.';
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
    //̧��
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ģʽ,����ʱ�󶨵���(һ���൥)
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
      //��ͨ��
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: ����;��ͷ;��ӡ��;���鵥��ӡ��
//Desc: ��nCard���г���
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
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  //�ж��Ƿ���Ҫ¼���ǩ��
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FMustSeal and (FSeal = '') then
    begin
      nStr := '����[ %s ] ����¼���ǩ��.';
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
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nReader <> '' then
    BlueOpenDoor(nReader);
  //̧��

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
    //�ſ�����
    if (nHYPrinter <> '') and (nTrucks[0].FPrintHY) then
      nStr := nStr + #6 + nHYPrinter;
    //���鵥��ӡ��

    if nPrinter = '' then
         gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr)
    else gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);
  end; //��ӡ����
end;

//Date: 2016-5-4
//Parm: ����;��ͷ;��ӡ��
//Desc: ��nCard���г�
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
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  //�ж��Ƿ���Ҫ¼���ǩ��
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FMustSeal and (FSeal = '') then
    begin
      nStr := '����[ %s ] ����¼���ǩ��.';
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
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  nRet := GetCardLength(nCard);
  //Ϊtrue�Ƕ��ڿ���false �ǳ��ڿ�
  //BlueOpenDoor(nReader);
  //̧��

  Result := nRet;

  //����һ�δ�ӡ
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
    //�ſ�����

    //��ƽ
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
  //��ӡ����
end;

//------------------------------------------------------------------------------
//Date: 2017/3/29
//Parm: ����һ������
//Desc: ��������һ��������Ϣ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '����һ����������'  + nItem.FID + ' ::: ' + nItem.FCard;
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
    gM100ReaderManager.DealtWithCard(nItem, nRetain); //ΪTRUE�̿�
  end;
end;

//Date: 2012-10-19
//Parm: ����;��ͷ
//Desc: ��⳵���Ƿ��ڶ�����,�����Ƿ�̧��
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫͨ����բ�ĳ���.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '����[ %s ]���ڶ���,��ֹͨ����բ.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader);
  //̧��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //�������ʱ��,�������򽫲��ٽк�.
  end;
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nCard: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
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
        //̧��
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nCard, nReader.FID, nDBConn);
        //̧��
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
//Parm: ��ͷ����
//Desc: �����ͷ�ſ�����
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('�����ǩ %s:%s', [nReader.FTunnel, nReader.FCard]));
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
  WriteHardHelperLog(Format('���������� %s:%s', [nHost.FReaderID, nCard.FCard]));
  {$ENDIF}

  gHardwareHelper.SetReaderCard(nHost.FReaderID, nCard.FCard, False);
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;�Ƿ����Ⱥ�˳��;��ʾ��Ϣ
//Desc: ���nTuck�Ƿ������nTunnelװ��
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
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
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
        //���ڵ�ǰ����
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //ˢ��������е�Ʒ�ֲ�ƥ��

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //Ų���������µ�

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '����[ %s ]��������[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //��װ�ص�����

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]����[ %s ]������.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //ͬ��������
    Result := True;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: ͨ����;������;
//Desc: ��nTunnel�ϴ�ӡnBill��α��
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
    nStr := '��ͨ��[ %s ]���ͷ�Υ����ʧ��,����: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;������;��������
//Desc: ����nTunnel�ĳ�������������
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
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ٶ���.', [nTruck]);
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
//Parm: ��������
//Desc: ��ѯnBill�ϵ���װ��
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
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
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
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('ͨ��[ ' + nTunnel + ' ]: MakeTruckLadingDai����.');

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //���ͨ��

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //ˢ��ͨ����Ӧ�Ľ�����
      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
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

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: ����;ͨ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
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
  //�򿪷Ż�

  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  //xxxxx
  gERelayManager.ShowTxt(nTunnel, nStr);
  //��ʾ����
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr, nTmp: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan����.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
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
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //���ͨ��

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := 'ɢװ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    {$IFDEF FPST}
    //��ƽ��̬���ð�װ��������ֻ��һ�Σ���ʾƷ�ּ���
    nStr := nPTruck.FTruck + StringOfChar(' ', 12 - Length(nPTruck.FTruck));
    nTmp := nPTruck.FStockName + FloatToStr(nPTruck.FValue);
    nStr := nStr + nPTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
            FloatToStr(nPTruck.FValue);
    //xxxxx
    gERelayManager.ShowTxt(nTunnel, nStr); 

    WriteNearReaderLog('zyww::'+nTunnel+'@'+nCard);
    //���Ϳ��ź�ͨ���ŵ�����װ��������
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    {$ELSE}
    TruckStartFH(nPTruck, nTunnel);
    {$ENDIF}
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF FPST}
  WriteNearReaderLog('zyww::'+nTunnel+'@'+nCard);
  gSendCardNo.SendCardNo(nTunnel + '@'+ nCard);
  //��ƽ��̬���ð�װ����������һ�β���������ֻ��ʾƷ�ֳ�������
  nStr := nPTruck.FTruck + StringOfChar(' ', 12 - Length(nPTruck.FTruck));
  nTmp := nPTruck.FStockName + FloatToStr(nPTruck.FValue);
  nStr := nStr + nPTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nPTruck.FValue);
  //xxxxx
  gERelayManager.ShowTxt(nTunnel, nStr);
  {$ELSE}
  TruckStartFH(nPTruck, nTunnel);
  //ִ�зŻ�
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
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
    MakeTruckLadingSan(nCard, nHost.FTunnel);
  end;
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard��ʱ����������
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut�˳�.');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  if nHost.FETimeOut then
    gERelayManager.ShowTxt(nHost.FTunnel, '���ӱ�ǩ������Χ')
  else
    gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
    
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //ģ��ˢ��
  end;
end;

//Date: 2012-12-16
//Parm: ��������
//Desc: ����ҵ���м����Ӳ���ػ��Ľ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('�յ�Bus_MITҵ������:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
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
      //ֻ����32.5(b)

      nLen := cMultiJS_Truck - 2;
      Result := 'B-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: ������ͨ��
//Desc: ����nTunnel�������
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
    //�����������Ϣ
    if not GetLadingBills(nLid, sFlag_BillDone, nBills) then
    begin
      Exit;
    end;
  end
  else if nBillType=sFlag_Provide then
  begin
    //���زɹ�������Ϣ
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

//������Ϣ
function Do_send_event_msg(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if TWorkerBusinessCommander.CallMe(cBC_WeChat_send_event_msg, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//�޸����϶���״̬
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

        //��ѯ�����̳Ƕ���
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
          //���۾���
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

        //�ɹ�����
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

//�޸����϶���״̬
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
      gSysLoger.AddLog(Format('ModifyWebOrderStatus[ %s ]�쳣:[ %s ].', [nList,E.Message]));
      Exit;
    end;
  end;
  try
    if nWebOrderId <> '' then
      SendMsgToWebMall(nList,nFactId,nBillType);
  except
    on E: Exception do
    begin
      gSysLoger.AddLog(Format('SendMsgToWebMall[ %s ]�쳣:[ %s ].', [nList,E.Message]));
      Exit;
    end;
  end;
end;

end.