{*******************************************************************************
  作者: juner11212436@163.com 2017-12-28
  描述: 自助办卡窗口--单厂版
*******************************************************************************}
unit uZXNewCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Contnrs,UFormCtrl,
  dxSkinsCore, dxSkinsDefaultPainters;

type

  TfFormNewCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditCus: TcxTextEdit;
    EditCName: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    EditType: TcxComboBox;
    EditPrice: TcxButtonEdit;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item10: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    dxLayout1Item11: TdxLayoutItem;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    dxLayout1Group2: TdxLayoutGroup;
    PrintHY: TcxCheckBox;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure lvOrdersClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    //FSzttceApi:TSzttceApi; //发卡机驱动
    FAutoClose:Integer; //窗口自动关闭倒计时（分钟）
    FWebOrderIndex:Integer; //商城订单索引
    FWebOrderItems:array of stMallOrderItem; //商城订单数组
    FCardData:TStrings; //云天系统返回的大票号信息
    Fbegin:TDateTime;
    procedure InitListView;
    procedure SetControlsReadOnly;
    function DownloadOrder(const nCard:string):Boolean;
    procedure Writelog(nMsg:string);
    procedure AddListViewItem(var nWebOrderItem:stMallOrderItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    function SaveBillProxy:Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID,nBillType:string):Boolean;
  public
    { Public declarations }
    procedure SetControlsClear;
    //property SzttceApi:TSzttceApi read FSzttceApi write FSzttceApi;
  end;

var
  fFormNewCard: TfFormNewCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormBase,UDataReport,UDataModule,NativeXml,UFormWait,
  DateUtils, UMgrTTCEDispenser;
{$R *.dfm}

{ TfFormNewCard }

procedure TfFormNewCard.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;
procedure TfFormNewCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FCardData.Free;
  Action:=  caFree;
  fFormNewCard := nil;
end;

procedure TfFormNewCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxlytmLayout1Item13.Visible := False;
  EditTruck.Properties.Buttons[0].Visible := False;
  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
  EditPrice.Properties.Buttons[0].Visible := False;
  dxLayout1Item11.Visible := False;
  {$IFDEF PrintHY}
  PrintHY.Checked := True;
  {$ELSE}
  PrintHY.Checked := False;
  {$ENDIF}
end;

procedure TfFormNewCard.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
  EditPrice.Properties.ReadOnly := True;
end;

procedure TfFormNewCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '请先输入或扫描订单号';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;
    lvOrders.Items.Clear;
    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nListA,nListB,nListC:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
begin
  Result := False;
  FWebOrderIndex := 0;

  nXmlStr := PackerEncodeStr(nCard);

  FBegin := Now;
  nData := get_shoporderbyno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('订单已撤销或已使用.',sHint);
    Writelog('订单已撤销或已使用.');
    Exit;
  end;
  Writelog('TfFormNewCard.DownloadOrder(nCard='''+nCard+''') 查询商城订单-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //解析网城订单信息
  Writelog('get_shoporderbyno res:'+nData);

  {$IFDEF UseWXServiceEx}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    nListC := TStringList.Create;
    try
      nListA.Text := PackerDecodeStr(nData);

      nListB.Text := PackerDecodeStr(nListA.Values['details']);
      nWebOrderCount := nListB.Count;
      SetLength(FWebOrderItems,nWebOrderCount);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListC.Text := PackerDecodeStr(nListB[i]);

        FWebOrderItems[i].FOrder_id     := nListA.Values['orderId'];
        FWebOrderItems[i].FOrdernumber  := nListA.Values['orderNo'];
        FWebOrderItems[i].Ftracknumber  := nListA.Values['licensePlate'];
        FWebOrderItems[i].FfactoryName  := nListA.Values['factoryName'];
        FWebOrderItems[i].FdriverId     := nListA.Values['driverId'];
        FWebOrderItems[i].FdrvName      := nListA.Values['drvName'];
        FWebOrderItems[i].FdrvPhone     := nListA.Values['FdrvPhone'];
        FWebOrderItems[i].FType         := nListA.Values['type'];
        FWebOrderItems[i].FXHSpot       := nListA.Values['orderRemark'];
        with nListC do
        begin
          FWebOrderItems[i].FCusID          := Values['clientNo'];
          FWebOrderItems[i].FCusName        := Values['clientName'];
          FWebOrderItems[i].FGoodsID        := Values['materielNo'];
          FWebOrderItems[i].FGoodstype      := Values['orderDetailType'];
          FWebOrderItems[i].FGoodsname      := Values['materielName'];
          FWebOrderItems[i].FData           := Values['quantity'];
          FWebOrderItems[i].ForderDetailType:= Values['orderDetailType'];
          FWebOrderItems[i].FYunTianOrderId := Values['contractNo'];  ;
          AddListViewItem(FWebOrderItems[i]);
        end;
      end;
    finally
      nListC.Free;
      nListB.Free;
      nListA.Free;
    end;
  {$ELSE}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    try
      nListA.Text := nData;

      nWebOrderCount := nListA.Count;
      SetLength(FWebOrderItems,nWebOrderCount);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListB.Text := PackerDecodeStr(nListA.Strings[i]);
        FWebOrderItems[i].FOrder_id := nListB.Values['order_id'];
        FWebOrderItems[i].FOrdernumber := nListB.Values['ordernumber'];
        FWebOrderItems[i].FGoodsID := nListB.Values['goodsID'];
        FWebOrderItems[i].FGoodstype := nListB.Values['goodstype'];
        FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
        FWebOrderItems[i].FData := nListB.Values['data'];
        FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
        FWebOrderItems[i].FYunTianOrderId := nListB.Values['fac_order_no'];
        AddListViewItem(FWebOrderItems[i]);
      end;
    finally
      nListB.Free;
      nListA.Free;
    end;
  {$ENDIF}
  LoadSingleOrder;
end;

procedure TfFormNewCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]clientid[%s]clientname[%s]sotckno[%s]stockname[%s]';
  nStr := Format(nStr,[editWebOrderNo.Text,EditCus.Text,EditCName.Text,EditStock.Text,EditSName.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

procedure TfFormNewCard.AddListViewItem(
  var nWebOrderItem: stMallOrderItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrdernumber;

  nlistitem.SubItems.Add(nWebOrderItem.FGoodsID);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
  nlistitem.SubItems.Add(nWebOrderItem.FYunTianOrderId);
end;

procedure TfFormNewCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '网上订单编号';
  col.Width := 300;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥型号';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '水泥名称';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '提货车辆';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '办理吨数';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '订单编号';
  col.Width := 250;
end;

procedure TfFormNewCard.FormCreate(Sender: TObject);
begin
  editWebOrderNo.Properties.MaxLength := gSysParam.FWebOrderLength;
  FCardData := TStringList.Create;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  InitListView;
  gSysParam.FUserID := 'AICM';
end;

procedure TfFormNewCard.LoadSingleOrder;
var
  nOrderItem:stMallOrderItem;
  nRepeat:Boolean;
  nWebOrderID:string;
  nMsg,nStr:string;
  nIsSale : Boolean;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrdernumber;

  FBegin := Now;
  nRepeat := IsRepeatCard(nWebOrderID);

  if nRepeat then
  begin
    nMsg := '此订单已成功办卡，请勿重复操作';
    ShowMsg(nMsg,sHint);
    Writelog(nMsg);
    Exit;
  end;
  writelog('TfFormNewCard.LoadSingleOrder 检查商城订单是否重复使用-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  //填充界面信息
  {$IFDEF UseWXServiceEx}
    if Pos('销售',nOrderItem.FType) > 0 then
      nIsSale := True
    else
      nIsSale := False;

    if not nIsSale then
    begin
      nMsg := '此订单不是销售订单！';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      Exit;
    end;

    //填充界面信息
    //基本信息
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'select Z_Customer,D_Price from %s a join %s b on a.Z_ID = b.D_ZID ' +
            'where Z_ID=''%s'' and D_StockNo=''%s'' ';

    nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,nOrderItem.FYunTianOrderId,nOrderItem.FGoodsID]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount = 1 then
      begin
        EditPrice.Text  := Fields[1].AsString;
      end;
    end;

    //提单信息
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname;
    EditValue.Text  := nOrderItem.FData;
    EditTruck.Text  := nOrderItem.Ftracknumber;
    EditCus.Text    := nOrderItem.FCusID;
    EditCName.Text  := nOrderItem.FCusName;
  {$ELSE}
    //基本信息
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'select Z_Customer,D_Price from %s a join %s b on a.Z_ID = b.D_ZID ' +
            'where Z_ID=''%s'' and D_StockNo=''%s'' ';

    nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,nOrderItem.FYunTianOrderId,nOrderItem.FGoodsID]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount = 1 then
      begin
        EditCus.Text    := Fields[0].AsString;
        EditPrice.Text  := Fields[1].AsString;
      end;
    end;

    nStr := 'Select C_Name From %s Where C_ID=''%s'' ';
    nStr := Format(nStr, [sTable_Customer, EditCus.Text]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount>0 then
      begin
        EditCName.Text  := Fields[0].AsString;
      end;
    end;

    //提单信息
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname; //copy(nOrderItem.FGoodsname,1,Length(nOrderItem.FGoodsname)-4);
    EditValue.Text := nOrderItem.FData;
    EditTruck.Text := nOrderItem.Ftracknumber;
  {$ENDIF}

  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewCard.IsRepeatCard(const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '车牌号长度应大于2位';
      Writelog(nHint);
      Exit;
    end;
  end;
  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    if not Result then
    begin
      nHint := '请填写有效的办理量';
      Writelog(nHint);
      Exit;
    end;
  end;
end;

procedure TfFormNewCard.BtnOKClick(Sender: TObject);
begin
  BtnOK.Enabled := False;
  try
    if not SaveBillProxy then Exit;
    Close;
  finally
    BtnOK.Enabled := True;
  end;
end;

function TfFormNewCard.SaveBillProxy: Boolean;
var
  nHint:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact:Boolean;
  nBillData:string;
  nBillID :string;
  nWebOrderID:string;
  nNewCardNo:string;
  nidx:Integer;
  i:Integer;
  nRet: Boolean;
  nOrderItem:stMallOrderItem;
begin
  Result := False;
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := editWebOrderNo.Text;

  if Trim(EditValue.Text) = '' then
  begin
    ShowMsg('获取物料价格异常！请联系管理员',sHint);
    Writelog('获取物料价格异常！请联系管理员');
    Exit;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  nNewCardNo := '';
  Fbegin := Now;
  try
    //连续三次读卡均失败，则回收卡片，重新发卡
    for nIdx:=0 to 3 do
    begin
      nNewCardNo := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
      if nNewCardNo <> '' then
        Break;
      Sleep(500);
    end;
    //连续三次读卡,成功则退出。


      //连续三次读卡均失败，则回收卡片，重新发卡
      for i := 0 to 3 do
      begin
        for nIdx:=0 to 3 do
        begin
          nNewCardNo:= gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
          if nNewCardNo<>'' then Break;
          Sleep(500);
        end;
        //连续三次读卡,成功则退出。
        if nNewCardNo<>'' then
          if IsCardValid(nNewCardNo) then Break;
      end;

    if nNewCardNo = '' then
    begin
      ShowDlg('卡箱异常,请查看是否有卡.', sWarn, Self.Handle);
      Exit;
    end;
    WriteLog('读取到卡片: ' + nNewCardNo);
  except on Ex:Exception do
    begin
      WriteLog('卡箱异常 '+Ex.Message);
      ShowDlg('卡箱异常, 请联系管理人员.', sWarn, Self.Handle);
    end;
  end;

  if not IsCardValid(nNewCardNo) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nHint := '卡号' + nNewCardNo + '非法,回收中,请稍后重新取卡';
    WriteLog(nHint);
    ShowMsg(nHint, sWarn);
    Exit;
  end;

  //保存提货单
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    if Pos('袋',EditSName.Text) > 0 then
      nTmp.Values['Type'] := 'D'
    else
      nTmp.Values['Type'] := 'S';

    nTmp.Values['StockNO'] := EditStock.Text;
    nTmp.Values['StockName'] := EditSName.Text;//copy(EditSName.Text,1,Length(EditSName.Text)-2);//EditSName.Text;
    nTmp.Values['Price'] := EditPrice.Text;
    nTmp.Values['Value'] := EditValue.Text;

    if PrintHY.Checked  then
         nTmp.Values['PrintHY'] := sFlag_Yes
    else nTmp.Values['PrintHY'] := sFlag_No;

    nList.Add(PackerEncodeStr(nTmp.Text));
    nPrint := nStocks.IndexOf(EditStock.Text) >= 0;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := nOrderItem.FYunTianOrderId;
      Values['Truck'] := Trim(EditTruck.Text);
      Values['Lading'] := sFlag_TiHuo;
      Values['Memo']  := EmptyStr;
      Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
      Values['Seal'] := '';
      Values['HYDan'] := '';
      Values['WebOrderID'] := nWebOrderID;
    end;
    nBillData := PackerEncodeStr(nList.Text);
    FBegin := Now;
    nBillID := SaveBill(nBillData);
    if nBillID = '' then Exit;
    writelog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    FBegin := Now;
    SaveWebOrderMatch(nBillID,nWebOrderID,sFlag_Sale);
    writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  finally
    nStocks.Free;
    nList.Free;
    nTmp.Free;
  end;

  ShowMsg('提货单保存成功', sHint);

  //发卡2019-05-20
  if not SaveBillCard(nBillID,nNewCardNo) then
  begin
    nHint := '卡号[ %s ]关联订单失败,请到开票窗口重新关联磁卡.';
    nHint := Format(nHint, [nNewCardNo]);

    WriteLog(nHint);
    ShowMsg(nHint,sWarn);
  end
  else begin
    if not gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint) then
      ShowMessage('出卡失败,请联系管理员将磁卡取出.')
    else
      ShowMsg('发卡成功,卡号['+nNewCardNo+'],请收好您的卡片',sHint);
  end;

  Result := True;
  if nPrint then
    PrintBillReport(nBillID, True);
  //print report
end;

function TfFormNewCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string):Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
  SF('WOM_WebOrderID'   , nWebOrderID),
  SF('WOM_LID'          , nBillID),
  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
  SF('WOM_BillType'     , nBillType),
  SF('WOM_deleted'     , sFlag_No)
  ], sTable_WebOrderMatch, '', True);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;
procedure TfFormNewCard.lvOrdersClick(Sender: TObject);
var
  nSelItem:TListItem;
  i:Integer;
begin
  nSelItem := lvorders.Selected;
  if Assigned(nSelItem) then
  begin
    for i := 0 to lvOrders.Items.Count-1 do
    begin
      if nSelItem = lvOrders.Items[i] then
      begin
        FWebOrderIndex := i;
        LoadSingleOrder;
        Break;
      end;
    end;
  end;
end;

procedure TfFormNewCard.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    btnQuery.SetFocus;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

end.
