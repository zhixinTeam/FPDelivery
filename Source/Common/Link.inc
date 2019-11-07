//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{.$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式
{$DEFINE COMMON}
//通用中间件

{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{$DEFINE COMMON}
//通用版本


{$DEFINE HLST}
//特定系统            HLST   FPST  

{$IFDEF FPST} 
//富平生态水泥
  {$DEFINE FPST}
  {$DEFINE HYRFID201}
  //华益读卡器
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {.$DEFINE EnableWebMall}
  //启用网上商城
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE StockLimited}
  //日发货量限制
  {$DEFINE M100Reader}
  //吞卡机
  {$DEFINE ChangeBillWhenPriceAdjust}
  //纸卡调价时修改已提货单据价格
  {$DEFINE AdjustMoney}
  //金额调拨功能
  {$DEFINE FixLoad}
  //定置装车
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE AutoProId}
  //自动生成供应商编号
  {$DEFINE PrintHY}
  //出厂打印化验单
  {$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
 {$DEFINE UseWXServiceEx}
  //使用二期微信中间件
{$ENDIF}

{$IFDEF HLST} 
//黄陵生态水泥
  {$DEFINE FPST}
  {$DEFINE PrintFactorysBill} //打印多厂单据
  {$DEFINE BasisWeight}
  //启用定量装车
  {.$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛重

  {$DEFINE HYRFID201}
  //华益读卡器
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {.$DEFINE EnableWebMall}
  //启用网上商城
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE StockLimited}
  //日发货量限制
  {$DEFINE M100Reader}
  //吞卡机
  {$DEFINE ChangeBillWhenPriceAdjust}
  //纸卡调价时修改已提货单据价格
  {$DEFINE AdjustMoney}
  //金额调拨功能
  {.$DEFINE FixLoad}
  //定置装车
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE AutoProId}
  //自动生成供应商编号
  {$DEFINE PrintHY}
  //出厂打印化验单
  {$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
 {$DEFINE UseWXServiceEx}
  //使用二期微信中间件
{$ENDIF}


