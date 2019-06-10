{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, UBase64,
  USysLoger, USysDB, UMITConst, DateUtils;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TK3SalePalnItem = record
    FInterID: string;       //主表编号
    FEntryID: string;       //附表编号
    FTruck: string;         //车牌号
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //获取卡片类型
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //登录注销，用于移动终端
    function GetServerNow(var nData: string): Boolean;
    //获取服务器时间
    function GetSerailID(var nData: string): Boolean;
    //获取串号
    function IsSystemExpired(var nData: string): Boolean;
    //系统是否已过期
    function GetCustomerValidMoney(var nData: string): Boolean;
    //获取客户可用金
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //获取纸卡可用金
    function CustomerHasMoney(var nData: string): Boolean;
    //验证客户是否有钱
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //保存车辆到Truck表
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //存取车辆称重数据
    function GetStockBatcode(var nData: string): Boolean;
    //获取品种批次号
    //防伪码校验
    function CheckSecurityCodeValid(var nData: string): Boolean;

    //工厂待装查询
    function GetWaitingForloading(var nData: string):Boolean;

    //网上订单可下单数量查询
    function GetBillSurplusTonnage(var nData:string):boolean;

    //获取车辆最大限载值
    function GetLimitValue(var nData:string):Boolean;
    function GetshoporderbyTruck(const nData: string): string;
    //根据车牌号获取订单

    //获取网上下单信息
    function GetWebOrderByCard(var nData:string):Boolean;

    function SaveWebOrderMatch(const nBillID,nWebOrderID,nBillType:string):Boolean;
    //保存网络订单信息，供微信中间件推消息

    function GetZhiKaFrozen(nCusId: string):Double;
    function GetCardLength(var nData: string): Boolean;
    //获取车辆是否是长期卡
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation
uses
  UMgrQueue, UHardBusiness, UWorkerClientWebChat ;   //,UCallWXServer

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
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
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
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

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);
   
   cBC_VerifPrintCode      : Result := CheckSecurityCodeValid(nData); //验证码查询
   cBC_WaitingForloading   : Result := GetWaitingForloading(nData); //待装车辆查询
   cBC_BillSurplusTonnage  : Result := GetBillSurplusTonnage(nData); //查询商城订单可用量
   cBC_GetLimitValue               : Result := GetLimitValue(nData);     //获取车辆最大限载值
   cBC_GetWebOrderByCard           : Result := GetWebOrderByCard(nData); //通过卡号获取商城订单
   cBC_GetCardLength               : Result := GetCardLength(nData);     //获取卡是否是长期卡
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: 获取卡片类型：销售S;采购P;其他O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      nData := '磁卡[ %s ]信息不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名，密码；返回用户数据
//Desc: 用户登录
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //未传递用户名

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名；验证数据
//Desc: 用户注销
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: 获取服务器当前时间
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: 按规则生成序列编号
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有[ %s.%s ]的编码配置.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //按日期编码
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: 验证系统是否已过期
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := '系统已过期 %d 天,请联系管理员!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('系统在 %d 天后过期', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nUseCredit: Boolean;
    nVal,nCredit, nZKFrozen: Double;
begin
  nUseCredit := False;
  if FIn.FExtParam = sFlag_Yes then
  begin
    nStr := 'Select MAX(C_End) From %s ' +
            'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
    nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
                    (Fields[0].AsDateTime > Now());
    //信用未过期
  end;

  nZKFrozen := GetZhiKaFrozen(FIn.FData); //纸卡冻结金额

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat - nZKFrozen;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if nUseCredit then
      nVal := nVal + nCredit;

    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;
    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;
{$ENDIF}

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney,nCredit, nFrozen: Double;
    nCusId: string;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在,或客户账户无效.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;
    nCusId := FieldByName('A_CID').AsString;

    nFrozen := GetZhiKaFrozen(nCusId);

    nStr := 'Select MAX(C_End) From %s ' +
            'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
    nStr := Format(nStr, [sTable_CusCredit, nCusId,
            sFlag_Yes]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
       (Fields[0].AsDateTime > Now()) then
    begin
      nVal := nVal + nCredit;
      //信用未过期
    end;

    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;
    //total money

    {原版备份
    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;}

    if FOut.FExtParam <> sFlag_Yes then
      nMoney := nVal - nFrozen;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;
{$ENDIF}

//Date: 2014-09-05
//Desc: 验证客户是否有钱,以及信用是否过期
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nStr := 'Select C_Name From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
         nName := Fields[0].AsString
    else nName := '已删除';
  end;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('客户[ %s ]的资金余额不足.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s ' +
          'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime <= Now()) then
  begin
    nData := Format('客户[ %s ]的信用已过期.', [nName]);
    Result := False;
  end;
end;

//Date: 2014-10-02
//Parm: 车牌号[FIn.FData];
//Desc: 保存车辆到sTable_Truck表
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: 车牌号(Truck); 表字段名(Field);数据值(Value)
//Desc: 更新车辆信息到sTable_Truck表
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: 车牌号[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 称重数据[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //保存车牌号

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '进厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

//Date: 2016-02-24
//Parm: 物料编号[FIn.FData];预扣减量[FIn.ExtParam];
//Desc: 按规则生成指定品种的批次编号
function TWorkerBusinessCommander.GetStockBatcode(var nData: string): Boolean;
var nStr,nP: string;
    nNew: Boolean;
    nInt,nInc: Integer;
    nVal,nPer: Double;

    //生成新批次号
    function NewBatCode: string;
    begin
      nStr := 'Select * From %s Where B_Stock=''%s''';
      nStr := Format(nStr, [sTable_StockBatcode, FIn.FData]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := FieldByName('B_UseYear').AsString;

        if nStr = sFlag_Yes then
        begin
          nStr := Copy(Date2Str(Now()), 3, 2);
          nP := nP + nStr;
          //前缀后两位年份
        end;

        nStr := FieldByName('B_Base').AsString;
        nInt := FieldByName('B_Length').AsInteger;
        nInt := nInt - Length(nP + nStr);

        if nInt > 0 then
             Result := nP + StringOfChar('0', nInt) + nStr
        else Result := nP + nStr;

        nStr := '物料[ %s.%s ]将立即使用批次号[ %s ],请通知化验室确认已采样.';
        nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                              FieldByName('B_Name').AsString, Result]);
        //xxxxx

        FOut.FBase.FErrCode := sFlag_ForceHint;
        FOut.FBase.FErrDesc := nStr;
      end;

      nStr := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_StockBatcode, SF('B_Stock', FIn.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
begin
  Result := True;
  FOut.FData := '';
  
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatchAuto]);
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := Fields[0].AsString;
    if nStr <> sFlag_Yes then Exit;
  end  else Exit;
  //默认不使用批次号

  nStr := 'Select * from %s where D_name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NoBatchAuto,FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then exit;
  //特殊品种无需批次号

  Result := False; //Init
  nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_StockBatcode, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '物料[ %s ]未配置批次号规则.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := FieldByName('B_Batcode').AsString;
    nInc := FieldByName('B_Incement').AsInteger;
    nNew := False;

    if FieldByName('B_UseDate').AsString = sFlag_Yes then
    begin
      nP := FieldByName('B_Prefix').AsString;
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime, False);

      nInt := FieldByName('B_Length').AsInteger;
      nInt := Length(nP + nStr) - nInt;

      if nInt > 0 then
      begin
        System.Delete(nStr, 1, nInt);
        FOut.FData := nP + nStr;
      end else
      begin
        nStr := StringOfChar('0', -nInt) + nStr;
        FOut.FData := nP + nStr;
      end;

      nNew := True;
    end;

    if (not nNew) and (FieldByName('B_AutoNew').AsString = sFlag_Yes) then      //元旦重置
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nStr := Copy(nStr, 1, 4);
      nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
      nP := Copy(nP, 1, 4);

      if nStr <> nP then
      begin
        nStr := 'Update %s Set B_Base=1 Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, FIn.FData]);
        
        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
        nNew := True;
      end;
    end;

    if not nNew then //编号超期
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

      if (Str2Date(nP) > Str2Date('2000-01-01')) and
         (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, FIn.FData]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
        nNew := True;
      end;
    end;

    if not nNew then //编号超发
    begin
      nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FIn.FExtParam);
      //已使用+预使用
      nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
      //可用上限

      if nVal >= nPer then //超发
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, FIn.FData]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
      end else
      begin
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
        //提醒
      
        if nVal >= nPer then //超发提醒
        begin
          nStr := '物料[ %s.%s ]即将更换批次号,请通知化验室准备取样.';
          nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                                FieldByName('B_Name').AsString]);
          //xxxxx

          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := nStr;
        end;
      end;
    end;
  end;

  if FOut.FData = '' then
    FOut.FData := NewBatCode;
  //xxxxx
  
  Result := True;
  FOut.FBase.FResult := True;
end;

//Date: 2016-09-20
//Parm: 防伪码[FIn.FData]
//Desc: 防伪码校验
function TWorkerBusinessCommander.CheckSecurityCodeValid(var nData: string): Boolean;
var
  nStr,nCode,nBill_id: string;
  nSprefix:string;
  nIdx,nIdlen:Integer;
  nDs:TDataSet;
  nBills: TLadingBillItems;
begin
  nSprefix := '';
  nidlen := 0;
  Result := True;
  nCode := FIn.FData;
  if nCode='' then
  begin
    nData := '';
    FOut.FData := nData;
    Exit;
  end;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);
  nDs :=  gDBConnManager.WorkerQuery(FDBConn, nStr);

  if nDs.RecordCount>0 then
  begin
    nSprefix := nDs.FieldByName('B_Prefix').AsString;
    nIdlen := nDs.FieldByName('B_IDLen').AsInteger;
    nIdlen := nIdlen-length(nSprefix);
  end;

  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, 6) + //YYMMDD
              Copy(nCode, 12, Length(nCode) - 11); //XXXX  
  {$IFDEF CODECOMMON}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, 6) + //YYMMDD
              Copy(nCode, 12, Length(nCode) - 11); //XXXX
  {$ENDIF}

  {$IFDEF CODEAREA}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, nIdlen); //YYMMDDXXXX
  {$ENDIF}

  {$IFDEF CODEBATCODE}
  //生成提货单号
  nBill_id := nSprefix+Copy(nCode, 1, nIdlen); //YYMMDDXXXX
  {$ENDIF}


  //查询数据库
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
      'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
      'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,l_project,l_area,'+
      'l_workaddr,l_transname,l_hydan,l_outfact From $Bill b ';
  nStr := nStr + 'Where L_ID=''$CD''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', nBill_id)]);

  nDs := gDBConnManager.WorkerQuery(FDBConn, nStr);
  if nDs.RecordCount<1 then
  begin
    SetLength(nBills, 1);
    ZeroMemory(@nBills[0],0);
    FOut.FData := CombineBillItmes(nBills);
    Exit;
  end;

  SetLength(nBills, nDs.RecordCount);
  nIdx := 0;
  nDs.First;
  while not nDs.eof do
  begin
    with  nBills[nIdx] do
    begin
      FID         := nDs.FieldByName('L_ID').AsString;
      FZhiKa      := nDs.FieldByName('L_ZhiKa').AsString;
      FCusID      := nDs.FieldByName('L_CusID').AsString;
      FCusName    := nDs.FieldByName('L_CusName').AsString;
      FTruck      := nDs.FieldByName('L_Truck').AsString;

      FType       := nDs.FieldByName('L_Type').AsString;
      FStockNo    := nDs.FieldByName('L_StockNo').AsString;
      FStockName  := nDs.FieldByName('L_StockName').AsString;
      FValue      := nDs.FieldByName('L_Value').AsFloat;
      FPrice      := nDs.FieldByName('L_Price').AsFloat;

      FCard       := nDs.FieldByName('L_Card').AsString;
      FIsVIP      := nDs.FieldByName('L_IsVIP').AsString;
      FStatus     := nDs.FieldByName('L_Status').AsString;
      FNextStatus := nDs.FieldByName('L_NextStatus').AsString;
      FSelected := True;
      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := nDs.FieldByName('L_PValue').AsFloat;
      FMData.FValue := nDs.FieldByName('L_MValue').AsFloat;
      Fhydan := nDs.FieldByName('l_hydan').AsString;
      
      //FProject := nDs.FieldByName('l_project').AsString;
      //FArea := nDs.FieldByName('l_area').AsString;
      //Foutfact := nDs.FieldByName('l_outfact').AsDateTime;
    end;

    Inc(nIdx);
    nDs.Next;
  end;

  FOut.FData := CombineBillItmes(nBills);
end;

//Date: 2016-09-20
//Parm: 
//Desc: 工厂待装查询
function TWorkerBusinessCommander.GetWaitingForloading(var nData: string):Boolean;
var nFind: Boolean;
    nLine: PLineItem;
    nIdx,nInt, i: Integer;
    nQueues: TQueueListItems;
begin
  gTruckQueueManager.RefreshTrucks(True);
  Sleep(320);
  //刷新数据

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    i := 0;
    SetLength(nQueues, 0);
    //保存查询记录

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      if not nLine.FIsValid then Continue;
      //通道无效

      nFind := False;
      for nInt:=Low(nQueues) to High(nQueues) do
      begin
        with nQueues[nInt] do
        if FStockNo = nLine.FStockNo then
        begin
          Inc(FLineCount);
          FTruckCount := FTruckCount + nLine.FRealCount;

          nFind := True;
          Break;
        end;
      end;

      if not nFind then
      begin
        SetLength(nQueues, i+1);
        with nQueues[i] do
        begin
          FStockNO    := nLine.FStockNo;
          FStockName  := nLine.FStockName;

          FLineCount  := 1;
          FTruckCount := nLine.FRealCount;
        end;

        Inc(i);
      end;
    end;

    for nIdx:=Low(nQueues) to High(nQueues) do
    begin
      with FListB, nQueues[nIdx] do
      begin
        Clear;

        Values['StockName'] := FStockName;
        Values['LineCount'] := IntToStr(FLineCount);
        Values['TruckCount']:= IntToStr(FTruckCount);
      end;

      FListC.Add(PackerEncodeStr(FListB.Text));
    end;

    FOut.FData := PackerEncodeStr(FListC.Text);
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2016-09-23
//Parm:
//Desc: 网上订单可下单数量查询
function TWorkerBusinessCommander.GetBillSurplusTonnage(var nData:string):boolean;
var nStr,nCusID: string;
    nVal,nCredit,nPrice: Double;
    nStockNo:string;
begin
  nCusID := '';
  nStockNo := '';
  nPrice := 1;
  nCredit := 0;
  nVal := 0;
  Result := False;
  nCusID := Fin.FData;
  if nCusID='' then Exit;  
  //未传递客户号

  nStockNo := Fin.FExtParam;
  if nStockNo='' then Exit;
  //未传递产品编号

  //产品销售价格表擦查询单价
  nStr := 'select p_price from %s where P_StockNo=''%s'' order by P_Date desc';
  //nStr := Format(nStr, [sTable_SPrice, nStockNo]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '未设单价，查询失败!';
      Exit;
    end;
    nPrice := FieldByName('p_price').AsFloat;
    if Float2PInt(nPrice, 100000, False)<=0 then
    begin
      nData := '单价设置不正确，查询失败!';
      Exit;    
    end;
  end;

  //调用GetCustomerValidMoney查询可用金额
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;
  nVal := StrToFloat(FOut.FData);
  if Float2PInt(nVal, cPrecision, False)<=0 then
  begin
    nData := '编号为[ %s ]的客户账户可用金额不足.';
    nData := Format(nData, [nCusID]);
    Exit;
  end;
  FOut.FData := FormatFloat('0.0000',nVal/nPrice);
  Result := True;  
end;


function TWorkerBusinessCommander.GetLimitValue(
  var nData: string): Boolean;
var
  nStr:string;
begin
  Result := False;

  nStr := 'select S_Value from S_Truck a left join Sys_LoadStandard b on t_loadstand=b.S_No where T_Truck=''%s''';
  nStr := Format(nStr, [FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      nData := '车辆[ %s ]信息不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

function TWorkerBusinessCommander.GetWebOrderByCard(
  var nData: string): Boolean;
var
  nStr, nTruck, nSQL, nBillData, nBillID: string;
  nList, nTmp, nListBill,nListB ,nListC : TStrings;
  FBegin: TDateTime;
  nMsg: string;
  nWebOrderValue, MaxQuantity:Double;
  nCardNo:string;
begin
  Result := True;
  nCardNo := FIn.FData;
  nStr := 'Select * From %s Where T_Card=''%s''';
  nStr := Format(nStr, [sTable_Truck, nCardNo]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nMsg := '取商城订单失败,磁卡[ %s ]未绑定车辆或卡号不存在.';
      nMsg := Format(nMsg,[nCardNo]);
      WriteLog(nMsg);
      Result := False;
      Exit;
    end;
    //拿车牌号去网上商城查询订单

    nTruck := FieldByName('T_Truck').AsString;
    //nData := GetBillByTruck(PackerEncodeStr(nTruck));
    nData := GetshoporderbyTruck(PackerEncodeStr(nTruck));
    WriteLog('ndata=:'+ndata);
    if nData = '' then
    begin
      Writelog('未查询到网上商城订单详细信息，请检查订单号是否正确');
      Result := False;
      Exit;
    end;

    {$IFDEF UseWXServiceEx}
    try

      nData      := PackerDecodeStr(nData);
      nList      := TStringList.Create;
      nList.Text := nData;
      nListB     := TStringList.Create;
      nListC     := TStringList.Create;

      WriteLog('订单详情::'+nList.Text);

      nListB.Text := PackerDecodeStr(nList.Values['details']);

      if nListB.Count > 0 then
      begin
        nListC.Text := PackerDecodeStr(nListB[0]);
        if Trim(nList.Values['type']) = 'NULL' then
        begin
          writelog('磁卡 ['+nCardNo+'] 未查到微信商城订单信息.');
          Result := False;
          Exit;
        end;
        nStr := '取微信商城订单,磁卡 [%s] 车牌 [%s] 订单信息: [%s]';
        nStr := Format(nStr, [nCardNo,nTruck,nList.Text]);
        WriteLog(nStr);

        //验证是否重复
        nStr := 'select * from %s where WOM_WebOrderID=''%s'' ';
        nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['orderNo']]);
        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        begin
          if RecordCount > 0 then
          begin
            nMsg := '商城订单[ %s ]已成功办卡,退出操作.';
            nMsg := Format(nMsg,[nList.Values['orderNo']]);
            Result := False;
            Exit;
          end;
        end;

        if Pos('销售',Trim(nList.Values['type'])) > 0  then
        begin
          //销售单
          try
            nTmp := TStringList.Create;
            nListBill := TStringList.Create;

            nSQL := 'select Z_Customer,D_Price,D_StockName,D_Type,Z_PrintHy,Z_Seal '+
                    'from %s a join %s b on a.Z_ID = b.D_ZID ' +
                    'where Z_ID=''%s'' and D_StockNo=''%s'' ';
            nSQL := Format(nSQL,[sTable_ZhiKa,sTable_ZhiKaDtl,nListC.Values['contractNo'],nListC.Values['materielNo']]);
            with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
            begin
              if RecordCount = 0 then
              begin
                nMsg := '纸卡[%s]不存在或者已经被删除.';
                nMsg := Format(nMsg,[nListC.Values['contractNo']]);
                //nData := nMsg;
                Result := False;
                Exit;
              end;
              nTmp.Values['Type'] := FieldByName('D_Type').AsString;
              nTmp.Values['StockNO'] := nListC.Values['materielNo'];
              nTmp.Values['StockName'] := FieldByName('D_StockName').AsString;
              nTmp.Values['Price'] := FieldByName('D_Price').AsString;
              nTmp.Values['Value'] := nListC.Values['quantity'];

              if FieldByName('Z_PrintHy').AsBoolean then
                   nTmp.Values['PrintHY'] := sFlag_Yes
              else nTmp.Values['PrintHY'] := sFlag_No;

              nListBill.Add(PackerEncodeStr(nTmp.Text));

              with nListBill do
              begin
                Values['Bills'] := PackerEncodeStr(nListBill.Text);
                Values['ZhiKa'] := nListC.Values['contractNo'];
                Values['Truck'] := nList.Values['licensePlate'];
                Values['Lading'] := sFlag_TiHuo;
                Values['Memo']  := EmptyStr;
                Values['IsVIP'] := sFlag_TypeCommon;
                Values['Seal'] := '';
                Values['HYDan'] := '';
                Values['WebOrderID'] := nList.Values['orderNo'];

                if FieldByName('Z_Seal').AsBoolean then
                     Values['MustSeal'] := '1'
                else Values['MustSeal'] := '0';
              end;
            end;
            nBillData := PackerEncodeStr(nListBill.Text);
            FBegin := Now;
            nBillID := SaveBill(nBillData);
            if nBillID = '' then
            begin
              nMsg := '保存商城订单[ %s ]失败.';
              nMsg := Format(nMsg,[nList.Values['orderNo']]);
              Result := False;
              Exit;
            end;
            if not SaveBillCard(nBillID,nCardNo) then
            begin
              nMsg := '保存订单[ %s ]的磁卡信息[ %s ]失败.';
              nMsg := Format(nMsg,[nBillID, nCardNo]);
              Result := False;
              Exit;
            end;
            WriteLog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
            FBegin := Now;
            SaveWebOrderMatch(nBillID, nList.Values['orderNo'] ,sFlag_Sale);
            writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
            nTmp.Free;
            nListBill.Free;
            nlist.Free;
          except
            nlist.Free;
            nTmp.Free;
            nListBill.Free;
            Result :=False;
          end;
        end
        else
        begin
          //采购单
          nTmp := TStringList.Create;
          nListBill := TStringList.Create;
      
          //校验订单有效性
          nStr := 'select b_proid as provider_code,b_proname as provider_name,b_stockno as con_materiel_Code,b_restvalue as con_remain_quantity from %s where b_id=''%s''';
          nStr := Format(nStr,[sTable_OrderBase,nListC.Values['contractNo']]);
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if RecordCount<=0 then
            begin
              nMsg := '采购合同编号有误或采购合同已被删除[%s]。';
              nMsg := Format(nMsg,[nListC.Values['contractNo']]);
              Result := False;
              Exit;
            end;

            if nListC.Values['materielNo']<>FieldByName('con_materiel_Code').AsString then
            begin
              nMsg := '商城货单中原材料[ %s ]有误。';
              nMsg := Format(nMsg,[nListC.Values['materielNo']]);
              Result := False;
              Exit;
            end;

            nwebOrderValue := StrToFloatDef(nListC.Values['quantity'],0);
            MaxQuantity := FieldByName('con_remain_quantity').AsFloat;
            if nwebOrderValue - MaxQuantity >0.00001 then
            begin
              nMsg := '商城货单中提货数量有误，最多可提货数量为[%f]。';
              nMsg := Format(nMsg,[MaxQuantity]);
              Result := False;
              Exit;
            end;

            nListBill.Values['ProviderID'] := FieldByName('provider_code').AsString;
            nListBill.Values['ProviderName'] := FieldByName('provider_name').AsString;
          end;


          try
            nListBill.Values['SQID'] := nListC.Values['contractNo'];
            nListBill.Values['Area'] := '';
            nListBill.Values['Truck'] := nList.Values['licensePlate'];
            nListBill.Values['Project'] := nListC.Values['contractNo'];
            nListBill.Values['CardType'] := 'L';


            nListBill.Values['StockNO']   := nListC.Values['materielNo'];
            nListBill.Values['StockName'] := nListC.Values['materielName'];
            nListBill.Values['Value'] := nListC.Values['quantity'];

            nListBill.Values['WebOrderID'] := nList.Values['orderNo'];

            FBegin := Now;
            nBillID := SaveOrder(PackerEncodeStr(nListBill.Text));

            if nBillID = '' then
            begin
              nMsg := '保存商城采购单[ %s ]失败';
              nMsg := Format(nMsg,[nList.Values['orderNo']]);
              Result := False;
              Exit;
            end;

            if not SaveOrderCard(nBillID,nCardNo) then
            begin
              nMsg := '保存采购单[ %s ]的磁卡信息[ %s ]失败';
              nMsg := Format(nMsg,[nBillID,nCardNo]);
              Result := False;
              Exit;
            end;

            writelog('TfFormNewPurchaseCard.SaveBillProxy 保存采购单-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
            FBegin := Now;
            SaveWebOrderMatch(nBillID,nList.Values['orderNo'],sFlag_Provide);
            writelog('TfFormNewPurchaseCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
            nList.Free;
            nTmp.Free;
            nListBill.Free;
          except
            nTmp.Free;
            nListBill.Free;
            nList.Free;
            Result := False;
            exit;
          end;
        end;
      end;
    finally
      nListC.Free;
      nListB.Free;
    end;

  {$ELSE}
    //老版微信下单
    nData := PackerDecodeStr(nData);
    nList := TStringList.Create;
    nList.Text := nData;

    if Trim(nList.Values['order_type']) = 'NULL' then
    begin
      writelog('磁卡 ['+nCardNo+'] 未查到微信商城订单信息.');
      Result := False;
      Exit;
    end;

    nStr := '取微信商城订单,磁卡 [%s] 车牌 [%s] 订单信息: [%s]';
    nStr := Format(nStr, [nCardNo,nTruck,nList.Text]);
    WriteLog(nStr);

    //验证是否重复
    nStr := 'select * from %s where WOM_WebOrderID=''%s'' ';
    nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['ordernumber']]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nMsg := '商城订单[ %s ]已成功办卡,退出操作.';
        nMsg := Format(nMsg,[nList.Values['ordernumber']]);
        Result := False;
        Exit;
      end;
    end;
    
    if Trim(nList.Values['order_type']) = 'S' then
    begin
      //销售单
      try
        nTmp := TStringList.Create;
        nListBill := TStringList.Create;

        nSQL := 'select Z_Customer,D_Price,D_StockName,D_Type,Z_PrintHy,Z_Seal '+
                'from %s a join %s b on a.Z_ID = b.D_ZID ' +
                'where Z_ID=''%s'' and D_StockNo=''%s'' ';
        nSQL := Format(nSQL,[sTable_ZhiKa,sTable_ZhiKaDtl,nlist.Values['fac_order_no'],nlist.Values['goodsID']]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if RecordCount = 0 then
          begin
            nMsg := '纸卡[%s]不存在或者已经被删除.';
            nMsg := Format(nMsg,[nList.Values['fac_order_no']]);
            //nData := nMsg;
            Result := False;
            Exit;
          end;
          nTmp.Values['Type'] := FieldByName('D_Type').AsString;
          nTmp.Values['StockNO'] := nlist.Values['goodsID'];
          nTmp.Values['StockName'] := FieldByName('D_StockName').AsString;
          nTmp.Values['Price'] := FieldByName('D_Price').AsString;
          nTmp.Values['Value'] := nlist.Values['data'];

          if FieldByName('Z_PrintHy').AsBoolean then
               nTmp.Values['PrintHY'] := sFlag_Yes
          else nTmp.Values['PrintHY'] := sFlag_No;

          nListBill.Add(PackerEncodeStr(nTmp.Text));

          with nListBill do
          begin
            Values['Bills'] := PackerEncodeStr(nListBill.Text);
            Values['ZhiKa'] := nList.Values['fac_order_no'];
            Values['Truck'] := nList.Values['tracknumber'];
            Values['Lading'] := sFlag_TiHuo;
            Values['Memo']  := EmptyStr;
            Values['IsVIP'] := sFlag_TypeCommon;
            Values['Seal'] := '';
            Values['HYDan'] := '';
            Values['WebOrderID'] := nList.Values['ordernumber'];

            if FieldByName('Z_Seal').AsBoolean then
                 Values['MustSeal'] := '1'
            else Values['MustSeal'] := '0';
          end;
        end;
        nBillData := PackerEncodeStr(nListBill.Text);
        FBegin := Now;

        nBillID := SaveBill(nBillData);
        if nBillID = '' then
        begin
          nMsg := '保存商城订单[ %s ]失败.';
          nMsg := Format(nMsg,[nList.Values['ordernumber']]);
          Result := False;
          Exit;
        end;
        if not SaveBillCard(nBillID,nCardNo) then
        begin
          nMsg := '保存订单[ %s ]的磁卡信息[ %s ]失败.';
          nMsg := Format(nMsg,[nBillID, nCardNo]);
          Result := False;
          Exit;
        end;
        WriteLog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
        FBegin := Now;
        SaveWebOrderMatch(nBillID, nList.Values['ordernumber'] ,sFlag_Sale);
        writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
        nTmp.Free;
        nListBill.Free;
        nlist.Free;
      except
        nlist.Free;
        nTmp.Free;
        nListBill.Free;
        Result :=False;
      end;
    end
    else
    begin
      //采购单
      nTmp := TStringList.Create;
      nListBill := TStringList.Create;
      
      //校验订单有效性
      nStr := 'select b_proid as provider_code,b_proname as provider_name,b_stockno as con_materiel_Code,b_restvalue as con_remain_quantity from %s where b_id=''%s''';
      nStr := Format(nStr,[sTable_OrderBase,nList.Values['fac_order_no']]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount<=0 then
        begin
          nMsg := '采购合同编号有误或采购合同已被删除[%s]。';
          nMsg := Format(nMsg,[nList.Values['fac_order_no']]);
          Result := False;
          Exit;
        end;

        if nList.Values['goodsID']<>FieldByName('con_materiel_Code').AsString then
        begin
          nMsg := '商城货单中原材料[ %s ]有误。';
          nMsg := Format(nMsg,[nList.Values['goodsID']]);
          Result := False;
          Exit;
        end;

        nwebOrderValue := StrToFloatDef(nList.Values['data'],0);
        MaxQuantity := FieldByName('con_remain_quantity').AsFloat;
        if nwebOrderValue - MaxQuantity >0.00001 then
        begin
          nMsg := '商城货单中提货数量有误，最多可提货数量为[%f]。';
          nMsg := Format(nMsg,[MaxQuantity]);
          Result := False;
          Exit;
        end;

        nListBill.Values['ProviderID'] := FieldByName('provider_code').AsString;
        nListBill.Values['ProviderName'] := FieldByName('provider_name').AsString;
      end;


      try
        nListBill.Values['SQID'] := nList.Values['fac_order_no'];
        nListBill.Values['Area'] := '';
        nListBill.Values['Truck'] := nList.Values['tracknumber'];
        nListBill.Values['Project'] := nList.Values['fac_order_no'];
        nListBill.Values['CardType'] := 'L';


        nListBill.Values['StockNO'] := nList.Values['fac_order_no'];
        nListBill.Values['StockName'] := nList.Values['goodsname'];
        nListBill.Values['Value'] := nList.Values['data'];

        nListBill.Values['WebOrderID'] := nList.Values['ordernumber'];

        FBegin := Now;
        nBillID := SaveOrder(PackerEncodeStr(nListBill.Text));

        if nBillID = '' then
        begin
          nMsg := '保存商城采购单[ %s ]失败';
          nMsg := Format(nMsg,[nList.Values['ordernumber']]);
          Result := False;
          Exit;
        end;

        if not SaveOrderCard(nBillID,nCardNo) then
        begin
          nMsg := '保存采购单[ %s ]的磁卡信息[ %s ]失败';
          nMsg := Format(nMsg,[nBillID,nCardNo]);
          Result := False;
          Exit;
        end;

        writelog('TfFormNewPurchaseCard.SaveBillProxy 保存采购单-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
        FBegin := Now;
        SaveWebOrderMatch(nBillID,nList.Values['ordernumber'],sFlag_Provide);
        writelog('TfFormNewPurchaseCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
        nList.Free;
        nTmp.Free;
        nListBill.Free;
      except
        nTmp.Free;
        nListBill.Free;
        nList.Free;
        Result := False;
        exit;
      end;
    end;
    {$ENDIF}
  end;
end;

{//Date: 2017-10-26
//Parm: 命令;数据;参数;服务地址;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessWechat(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerWebChatData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerWebChatData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;
    nIn.FBase.FParam := sParam_NoHintOnError;

    //if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
    //  nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessWebchat);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);
    if not Result then
      gSysLoger.AddLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;  }

//根据车牌号获取订单
function TWorkerBusinessCommander.GetshoporderbyTruck(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallRemoteWorker(sCLI_BusinessWebchat, nData, '', @nOut, cBC_WX_get_shoporderbyTruck) then
     Result := nOut.FData
  else Result := '';
end;

function TWorkerBusinessCommander.SaveWebOrderMatch(const nBillID,
  nWebOrderID, nBillType: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
        SF('WOM_WebOrderID'   , nWebOrderID),
        SF('WOM_LID'          , nBillID),
        SF('WOM_StatusType'   , 0),
        SF('WOM_MsgType'      , 1),
        SF('WOM_BillType'     , nBillType),
        SF('WOM_deleted'     , sFlag_No)
        ], sTable_WebOrderMatch, '', True);

  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

function TWorkerBusinessCommander.GetZhiKaFrozen(nCusId: string): Double;
var
  nStr: string;
begin
  nStr := 'select SUM(Z_FixedMoney)as frozen from %s where Z_InValid<>''%s'' or '+
          ' Z_InValid is null and Z_OnlyMoney=''%s'' and Z_Customer=''%s''' ;
  nStr := Format(nStr,[sTable_ZhiKa,sFlag_Yes,sFlag_Yes,nCusId]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    Result := fieldbyname('frozen').AsFloat;
  end;
end;

//验证车辆是否是长期卡，为TRUE吞卡
function TWorkerBusinessCommander.GetCardLength(
  var nData: string): Boolean;
var nStr: string;
begin
  Result := True;

  nStr := 'select * from %s where T_Card=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      Result := False;
      exit;
    end;
  end;

  nStr := 'select * from %s where O_Card=''%s'' and O_CType=''%s''';
  nStr := Format(nStr, [sTable_Order, FIn.FData, sFlag_OrderCardG]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
      Result := False;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.
