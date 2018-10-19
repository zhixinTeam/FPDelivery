{*******************************************************************************
  作者: dmzn@163.com 2012-4-21
  描述: 远程打印服务程序
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdGlobal, UMgrRemotePrint, SyncObjs, UTrayIcon, StdCtrls, ExtCtrls,
  ComCtrls;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnConn: TButton;
    Timer2: TTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnConnClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*状态栏图标*}
    FIsBusy: Boolean;
    FBillList: TStrings;
    FSyncLock: TCriticalSection;
    //同步锁
    procedure ShowLog(const nStr: string);
    //显示日志
    procedure DoExecute(const nContext: TIdContext);
    //执行动作
    procedure PrintBill(var nBase: TRPDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //打印单据
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;
type
  TWeightItem = record
    FMValue: Double;
    FValue: Double;
  end;


implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, UDataReport, USysLoger, UFormConn,
  DB, USysDB, Math;

var
  gPath: string;               //程序路径

resourcestring
  sHint               = '提示';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '打印服务主单元', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;

  FIsBusy := False;
  FBillList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  //new item 

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //数据库连接
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    //nIni.WriteString('Config', 'Port', EditPort.Text);
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Enabled);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FBillList.Free;
  FSyncLock.Free;
  //lock
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnConn.Enabled := not CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

  FSyncLock.Enter;
  try
    FBillList.Clear;
    Timer2.Enabled := CheckSrv.Checked;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: 数据库配置
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //数据库连接
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
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
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TRPDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeRPBase, False);
    BytesToRaw(nBuf, nBase, cSizeRPBase);

    case nBase.FCommand of
     cRPCmd_PrintBill :
      begin
        PrintBill(nBase, nBuf, nContext);
        //print
      end;
    end;
  end;
end;

function SmallTOBig(small: real): string;
var
  SmallMonth, BigMonth: string;
  wei1, qianwei1: string[2];
  qianwei, dianweizhi, qian: integer;
  fs_bj: boolean;
begin
  if small < 0 then
    fs_bj := True
  else
    fs_bj := False;
  small      := abs(small);
  {------- 修改参数令值更精确 -------}
  {小数点后的位置，需要的话也可以改动-2值}
  qianwei    := -2;
  {转换成货币形式，需要的话小数点后加多几个零}
  Smallmonth := formatfloat('0.00', small);
  {---------------------------------}
  dianweizhi := pos('.', Smallmonth);{小数点的位置}
  {循环小写货币的每一位，从小写的右边位置到左边}
  for qian := length(Smallmonth) downto 1 do
  begin
    {如果读到的不是小数点就继续}
    if qian <> dianweizhi then
    begin
      {位置上的数转换成大写}
      case StrToInt(Smallmonth[qian]) of
        1: wei1 := '壹';
        2: wei1 := '贰';
        3: wei1 := '叁';
        4: wei1 := '肆';
        5: wei1 := '伍';
        6: wei1 := '陆';
        7: wei1 := '柒';
        8: wei1 := '捌';
        9: wei1 := '玖';
        0: wei1 := '零';
      end;
      {判断大写位置，可以继续增大到real类型的最大值}
      case qianwei of
        -3: qianwei1 := '';
        -2: qianwei1 := '';
        -1: qianwei1 := '';
        0: qianwei1  := '点';
        1: qianwei1  := '拾';
        2: qianwei1  := '佰';
        3: qianwei1  := '仟';
        4: qianwei1  := '万';
        5: qianwei1  := '拾';
        6: qianwei1  := '佰';
        7: qianwei1  := '仟';
        8: qianwei1  := '亿';
        9: qianwei1  := '拾';
        10: qianwei1 := '佰';
        11: qianwei1 := '仟';
      end;
      inc(qianwei);
      BigMonth := wei1 + qianwei1 + BigMonth;{组合成大写金额}
    end;
  end;

  BigMonth := StringReplace(BigMonth, '零拾', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零佰', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零仟', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零亿', '亿', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零万', '万', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '亿万', '亿', [rfReplaceAll]);

  BigMonth := StringReplace(BigMonth, '拾零', '拾', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '佰零', '佰', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '仟零', '仟', [rfReplaceAll]);

  BigMonth := BigMonth + '吨';
  BigMonth := StringReplace(BigMonth, '点吨', '吨', [rfReplaceAll]);

  if BigMonth = '吨整' then
    BigMonth := '零吨整';

  if copy(BigMonth, 1, 2) = '元' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  //if copy(BigMonth, 1, 2) = '零' then
  //  BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if fs_bj = True then
    SmallTOBig := '- ' + BigMonth
  else
    SmallTOBig := BigMonth;
end;


//------------------------------------------------------------------------------
//Date: 2012-4-1
//Parm: 交货单号;提示;数据对象;打印机
//Desc: 打印nBill交货单号
function PrintBillReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
    nLoadLimit, nWuCha, nMValue, nPValue, nNetValue, nOKNetValue:Double;//限载值,允许误差,超载量
    nParam: TReportParamItem;
    WeightList : array of TWeightItem;
    I, nCount :Integer;
begin
  nHint := '';
  Result := False;
  nStr := 'Select *,%s As L_ValidMoney From %s b Where L_ID=''%s''';
  nStr := Format(nStr, [nMoney, sTable_Bill, nBill]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '交货单[ %s ] 已无效!!';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;
  //判断是否需要分页打印
  nMValue := nDS.FieldByName('L_MValue').AsFloat;
  nPValue := nDS.FieldByName('L_PValue').AsFloat;

  nStr := 'select b.S_Value from %s a,%s b where a.T_LoadStand=b.S_No and T_Truck=''%s''';
  nStr := Format(nStr,[sTable_Truck,sTable_LoadStandard,nDS.FieldByName('L_Truck').AsString]);
  with FDM.SQLQuery(nStr,FDM.SQLTemp) do
  begin
    if recordcount = 0 then
      nLoadLimit := 49
    else
      nLoadLimit := fieldbyname('S_Value').AsFloat;
  end;


  nStr := 'select D_Value from %s where D_Memo=''%s''';
  nStr := Format(nStr,[sTable_SysDict,'LoadLimitWC']);
  with FDM.SQLQuery(nStr,FDM.SQLTemp) do
    nWuCha := fieldbyname('D_Value').AsFloat;


  SetLength(WeightList,0);
  //不超限载或者为袋装的
  if (Float2Float((nLoadLimit+nWuCha),cPrecision,True) >= Float2Float(nMValue,cPrecision,True))
      or (nDS.FieldByName('L_Type').AsString = 'D')then
  begin
    nCount := 1;
    SetLength(WeightList,1);
    WeightList[0].FMValue := nMValue;
    WeightList[0].FValue :=  nDS.FieldByName('L_Value').AsFloat;;
  end
  else
  begin
    nNetValue := nMValue - nPValue;         //净重
    nOKNetValue := nLoadLimit - nPValue;    //最大净重

    nCount := Ceil( nNetValue / nOKNetValue );   //打印张数
    SetLength(WeightList, nCount);

    for i := 0 to nCount -2 do
    begin
      WeightList[i].FMValue := nLoadLimit;
      WeightList[i].FValue := nOKNetValue;
    end;
    WeightList[nCount-1].FMValue := nMValue - (nOKNetValue * (nCount-1));
    WeightList[nCount-1].FValue :=  nNetValue - (nOKNetValue * (nCount-1));
  end;

  nStr := gPath + 'Report\LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件';
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  //循环打印
  for i := Low(WeightList) to High(WeightList) do
  begin
    nStr := 'Select '+FloatToStrF(WeightList[i].FMValue,ffFixed,5,2)+' as l_Mvalue,'+
            FloatToStrF(WeightList[i].FValue,ffFixed,5,2)+' as l_Value,'+
            'L_ID,L_ZhiKa,L_Order,L_Project,L_Area,L_CusID,L_CusName,L_SaleID,L_SaleMan,L_Type,'+
            'L_StockNo,L_StockName,L_Price,L_Truck,L_InTime,L_InMan,L_PValue,L_PDate,L_PMan,L_MDate,L_MMan,'+
            'L_OutFact,L_OutMan,L_Seal,L_HYDan,L_PrintHY,L_Man,L_Date,'+
            '%s As L_ValidMoney From %s b Where L_ID=''%s''';
    nStr := Format(nStr, [nMoney, sTable_Bill, nBill]);
    nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
    if not Assigned(nDS) then Exit;

    nParam.FName := 'BigValue';
    nParam.FValue := SmallTOBig(FDM.SQLQuery1.fieldbyname('L_Value').AsFloat);
    FDR.AddParamItem(nParam);

    nParam.FName := 'PgNum';//当前页
    nParam.FValue := i+1;
    FDR.AddParamItem(nParam);

    nParam.FName := 'PgCount';//总页数
    nParam.FValue := nCount;
    FDR.AddParamItem(nParam);

    FDR.Dataset1.DataSet := FDM.SQLQuery1;
    FDR.PrintReport;
  end;
  Result := FDR.PrintSuccess;

  {$IFDEF PrintGLF}
  if nDS.FieldByName('L_PrintGLF').AsString <> 'Y' then Exit;

  nStr := gPath + 'Report\BillLoad.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  {$ENDIF}
end;

//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function PrintOrderReport(const nOrder: string; var nHint: string;
 const nPrinter: string = ''; const nMoney: string = '0'): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  nHint := '';
  Result := False;
  
  nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.SQLQuery(nStr, FDM.SQLQuery1);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nHint := '采购单[ %s ] 已无效!!';
    nHint := Format(nHint, [nOrder]);
    Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_Printer'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  nParam.FName := 'BigValue';
  nParam.FValue := SmallTOBig(FDM.SQLQuery1.fieldbyname('D_Value').AsFloat);
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  if Pos('dj', Result) > 0 then
    Result := gPath + 'Report\HuaYan42_DJ.fr3'
  else if Pos('sl', Result) > 0 then
    Result := gPath + 'Report\HuaYan_sl.fr3'
  else if Pos('kf', Result) > 0 then
    Result := gPath + 'Report\HuaYan_kf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + 'Report\HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + 'Report\HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + 'Report\HuaYan52.fr3'
  else Result := '';
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr: string;
begin
  nHint := '';
  Result := False;

  nStr := 'select a.*,b.*,c.* from $Bill c ' +
              ' left join $SR b on b.R_SerialNo=c.L_HYDan ' +
              ' left join $SP a on a.P_ID=b.R_PID ' +
              'where c.L_ID= ''$ID''';
  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$ID', nBill),
          MI('$SR', sTable_StockRecord), MI('$SP', sTable_StockParam)]);
  //xxxxx

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有对应的化验单';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  //未勾选则不打印
  if FDM.SqlTemp.FieldByName('L_PrintHY').AsString = 'N' then exit;
  if FDM.SqlTemp.FieldByName('P_Stock').AsString = '' then exit;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR: string;
    nField: TField;
begin
  nHint := '';
  Result := False;

  {$IFDEF HeGeZhengSimpleData}
  nSR := 'Select * from %s b ' +
          ' Left Join %s sp On sp.P_Stock=b.L_StockName ' +
          'Where b.L_ID=''%s''';
  nStr := Format(nSR, [sTable_Bill, sTable_StockParam, nBill]);
  {$ELSE}
  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Reporter=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  {$ENDIF}

  if FDM.SQLQuery(nStr, FDM.SqlTemp).RecordCount < 1 then
  begin
    nHint := '提货单[ %s ]没有对应的合格证';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

  with FDM.SqlTemp do
  begin
    nField := FindField('L_PrintHY');
    if Assigned(nField) and (nField.AsString <> sFlag_Yes) then
    begin
      nHint := '交货单[ %s ]无需打印合格证.';
      nHint := Format(nHint, [nBill]);
      Exit;
    end;
  end;

  nStr := gPath + 'Report\HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nHint := '无法正确加载报表文件: ' + nStr;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;
  
  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//------------------------------------------------------------------------------
//Desc: 打印单据
procedure TfFormMain.PrintBill(var nBase: TRPDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  FSyncLock.Enter;
  try
    FBillList.Add(nStr);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('添加打印交货单: %s', [nStr]));
  //loged
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
var nPos: Integer;
    nBill,nHint,nPrinter,nHYPrinter,nMoney, nType, nStr: string;
begin
  if not FIsBusy then
  begin
    FSyncLock.Enter;
    try
      if FBillList.Count < 1 then Exit;
      nBill := FBillList[0];
      FBillList.Delete(0);
    finally
      FSyncLock.Leave;
    end;

    //bill #9 printer #8 money #7 CardType #6 HYPrinter

    nPos := Pos(#7, nBill);
    if nPos > 1 then
    begin
      nType := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nType, 1, nPos);
    end else nType := '';

    nPos := Pos(#8, nBill);
    if nPos > 1 then
    begin
      nMoney := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nMoney, 1, nPos);

      if not IsNumber(nMoney, True) then
        nMoney := '0';
      //xxxxx
    end else nMoney := '0';

    nPos := Pos(#9, nBill);
    if nPos > 1 then
    begin
      nPrinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nPrinter, 1, nPos);
    end else nPrinter := '';

    nPos := Pos(#6, nBill);
    if nPos > 1 then
    begin
      nHYPrinter := nBill;
      nBill := Copy(nBill, 1, nPos - 1);
      System.Delete(nHYPrinter, 1, nPos);
    end else nHYPrinter := '';

    WriteLog('开始打印: ' + nBill);
    try
      FIsBusy := True;
      //set flag
      
      if nType = 'P' then
      begin
        PrintOrderReport(nBill, nHint, nPrinter);
        if nHint <> '' then WriteLog(nHint);
      end else
      begin
        {$IFDEF PrintHYEach}
          {$IFNDEF HeGeZhengOnly}
          if PrintHuaYanReport(nBill, nHint, nHYPrinter) then
          begin
            nStr := 'update %s set L_HYPrintNum=L_HYPrintNum + 1 where L_ID=''%s''';
            nStr := Format(nStr,[sTable_Bill,nBill]);
            FDM.ExecuteSQL(nStr);
          end;
          if nHint <> '' then WriteLog(nHint);
          {$ENDIF}

          //PrintHeGeReport(nBill, nHint, nHYPrinter);
          //if nHint <> '' then WriteLog(nHint);
        {$ENDIF}
        PrintBillReport(nBill, nHint, nPrinter, nMoney);
        if nHint <> '' then WriteLog(nHint);
      end;
    except
      on E: Exception do
        WriteLog(E.Message);
      //xxxxx
    end;

    FIsBusy := False;
    WriteLog('打印结束.');
  end;
end;

procedure TfFormMain.Button1Click(Sender: TObject);
var
  nStr:string;
  myini:TIniFile;
begin
  FSyncLock.Enter;
  myini := TIniFile.Create(gPath + 'Config.ini');
  try
    nStr:=myini.ReadString('Test','Data','');
    if nStr<>'' then
      FBillList.Add(nStr);
  finally
    myini.Free;
    FSyncLock.Leave;
  end;

  WriteLog(Format('添加测试打印交货单: %s', [nStr]));
end;

end.
