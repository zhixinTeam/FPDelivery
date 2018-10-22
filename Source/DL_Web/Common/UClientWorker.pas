{*******************************************************************************
  ����: dmzn@163.com 2018-05-03
  ����: �ͻ���ҵ����������
*******************************************************************************}
unit UClientWorker;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UBusinessConst, UBusinessPacker,
  UClientPacker, UManagerGroup, ULibFun;

type
  TClient2MITWorker = class(TObject)
  protected
    FIn,FOut: PBWDataBase;
    //�������
    function GetPacker: TBusinessPackerBase; virtual;
    function GetRemoteWorker: string; virtual; abstract;
    function GetFixedServiceURL: string; virtual; abstract;
    //���෽��
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TStringHelper.TStringArray): string;
    //��������
    function MITWork(var nData: string): Boolean;
    //ִ��ҵ��
  public
    function WorkActive(const nIn, nOut: Pointer): Boolean;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TClientWorkerQueryField = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessCommand = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

implementation

uses
  uniGUImForm, uniGUIApplication, MainModule, MIT_Service_Intf, USysDB,
  USysBusiness, USysConst;

procedure TClient2MITWorker.WriteLog(const nEvent: string);
begin
  UniApplication.UniSession.Log(nEvent);
end;

//Date: 2018-05-03
//Desc: Ĭ�Ϸ����
function TClient2MITWorker.GetPacker: TBusinessPackerBase;
begin
  Result := gMG.FObjectPool.Lock(TMITBusinessCommand) as TBusinessPackerBase;
end;

//Date: 2018-05-03
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TClient2MITWorker.WorkActive(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nWorkTimeInit: Int64;
    nPack: TBusinessPackerBase;
    nArray: TStringHelper.TStringArray;
begin
  nPack := nil;
  try
    nPack := GetPacker();
    //get packer

    FIn := nIn;
    FOut := nOut;
    //in,out

    with FIn^ do
    begin
      nParam := FParam;
      nPack.InitData(FIn, True, False);

      with FFrom,UniMainModule.FUserConfig do
      begin
        FUser   := FUserID;
        FIP     := FLocalIP;
        FMAC    := FLocalMAC;

        FTime   := Now();
        FKpLong := GetTickCount;
        nWorkTimeInit := FKpLong;
      end;
    end;

    nStr := nPack.PackIn(FIn);
    Result := MITWork(nStr);

    if not Result then
    begin
      if Pos(sParam_NoHintOnError, nParam) < 1 then
      begin
        UniMainModule.FMainForm.ShowMessage(nStr);
        //show dialog
      end else FOut.FErrDesc := nStr;
    
      Exit;
    end;

    nPack.UnPackOut(nStr, FOut);
    with FOut^,UniMainModule.FUserConfig do
    begin
      nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
      nStr := Format(nStr, [FUserID, ClassName(), FVia.FIP,
              GetTickCount - nWorkTimeInit]);
      WriteLog(nStr);

      Result := FResult;
      if Result then
      begin
        if FErrCode = sFlag_ForceHint then
        begin
          nStr := 'ҵ��ִ�гɹ�,��ʾ��Ϣ����: ' + #13#10#13#10 + FErrDesc;
          UniMainModule.FMainForm.ShowMessage(nStr);
        end;

        Exit;
      end;

      if Pos(sParam_NoHintOnError, nParam) < 1 then
      begin
        SetLength(nArray, 0);

        nStr := 'ҵ��ִ���쳣,��������: ' + #13#10#13#10 +

                ErrDescription(FErrCode, FErrDesc, nArray) +

                '������������������Ƿ���Ч,����ϵ����Ա!' + #32#32#32;
        UniMainModule.FMainForm.ShowMessage(nStr);
      end;
    end;
  finally
    gMG.FObjectPool.Release(nPack);
  end;
end;

//Date: 2018-05-03
//Parm: ����;����
//Desc: ��ʽ����������
function TClient2MITWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TStringHelper.TStringArray): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := nil;
  nListB := nil;
  try
    nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nListB := gMG.FObjectPool.Lock(TStrings) as TStrings;
    //lock object

    nListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
    nListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

    if nListA.Count <> nListB.Count then
    begin
      Result := '��.����: ' + nCode + #13#10 +
                '   ����: ' + nDesc + #13#10#13#10;
    end else Result := '';

    for nIdx:=0 to nListA.Count - 1 do
    if (Length(nInclude) = 0) or
       (TStringHelper.StrArrayIndex(nListA[nIdx], nInclude) > -1) then
    begin
      Result := Result + '��.����: ' + nListA[nIdx] + #13#10 +
                         '   ����: ' + nListB[nIdx] + #13#10#13#10;
    end;
  finally
    gMG.FObjectPool.Release(nListA);
    gMG.FObjectPool.Release(nListB);
  end;
end;

//Date: 2018-05-03
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TClient2MITWorker.MITWork(var nData: string): Boolean;
var nBuffer: AnsiString;
    nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gMG.FChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '����MIT����ʧ��(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      FHttp.TargetURL := GetFixedServiceURL;

      nBuffer := AnsiString(nData);
      Result := ISrvBusiness(FChannel).Action(AnsiString(GetRemoteWorker), nBuffer);
      nData := string(nBuffer);
      //call mit funciton
    except
      on nErr:Exception do
      begin
        nData := Format('%s(BY %s ).', [nErr.Message, gSysParam.FAppTitle]);
        WriteLog('Function:[ ' + ClassName() + ' ]' + nErr.Message);
      end;
    end;
  finally
    gMG.FChannelManager.ReleaseChannel(nChannel);
  end;
end;

//------------------------------------------------------------------------------
function TClientWorkerQueryField.GetRemoteWorker: string;
begin
  Result := sBus_GetQueryField;
end;

function TClientWorkerQueryField.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessCommand.GetRemoteWorker: string;
begin
  Result := sBus_BusinessCommand;
end;

function TClientBusinessCommand.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

initialization
  with gMG.FObjectPool do
  begin
    NewClass(TClientBusinessCommand,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessCommand.Create;
      end);
    //xxxxx
  end;
end.
