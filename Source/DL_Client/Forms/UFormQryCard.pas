unit UFormQryCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxLayoutControl, StdCtrls, CPort, dxLayoutcxEditAdapters, cxContainer,
  cxEdit, cxTextEdit;

type
  TfFormQryCard = class(TfFormNormal)
    ComPort1: TComPort;
    EditCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    editCardType: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    editBill: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    editTruck: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    editStockName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    editNum: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    editCusName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
    procedure ActionComPort(const nStop: Boolean);
    procedure QryCard(CardNo:string);
    procedure QueryPorderInfo(const nCard: string);
    procedure QuerySaleInfo(const nCard: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormQryCard: TfFormQryCard;

implementation

{$R *.dfm}
uses
  USysDB, UDataModule, IniFiles, USysConst, CPortTypes, USmallFunc, UMgrControl,
  USysBusiness, UBusinessPacker;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gReaderItem: TReaderItem;

{ TfFormQryCard }

procedure TfFormQryCard.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;

class function TfFormQryCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormQryCard.Create(Application) do
  begin
    ActiveControl := EditCard;
    ActionComPort(False);
    ShowModal;
    Free;
  end;
end;

class function TfFormQryCard.FormID: integer;
begin
  Result := cFI_FormQryCard;
end;

procedure TfFormQryCard.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    FBuffer: string;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    EditCard.Text := ParseCardNO(nStr, True);
    QryCard(EditCard.Text);
    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormQryCard.QryCard(CardNo: string);
var
  nStr: string;
  nTruck:string;
begin
  nStr := 'select * from %s where c_card=''%s''';
  nStr := Format(nStr,[sTable_Card,CardNo]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount = 0 then
    begin
      editCardType.Text := '磁卡号无效';
      exit;
    end;
    if FieldByName('c_used').AsString=sFlag_Provide then
    begin
      QueryPorderinfo(CardNo);
    end
    else
    begin
      QuerySaleInfo(CardNo);
    end;
  end;
end;

procedure TfFormQryCard.QueryPorderinfo(const nCard: string);
var
  nStr:string;
begin
  nStr := 'select * from %s where o_card=''%s''';
  nStr := Format(nStr, [sTable_Order, nCard]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount < 1 then
    begin
      editBill.Text := '无开单信息';
      exit;
    end;
    editBill.Text := fieldbyname('o_id').AsString;
    editTruck.Text := fieldbyname('o_Truck').AsString;
    editStockName.Text := FieldByName('o_StockName').AsString;
    editCusName.Text := FieldByName('O_ProName').AsString;
    if FieldByName('o_CType').AsString = sFlag_OrderCardG then
      editCardType.Text := '供应长期卡'
    else
      editCardType.Text := '供应临时卡';
  end;
end;

procedure TfFormQryCard.QuerySaleInfo(const nCard: string);
var
  nStr: string;
  nHasBill: Boolean;
  nList: TStrings;
begin
  nHasBill := False;
  nStr := 'select * from %s where L_Card=''%s''';
  nStr := Format(nStr,[sTable_Bill,nCard]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount >0 then
    begin
      nHasBill := true;
      editBill.Text := fieldbyname('L_id').AsString;
      editTruck.Text := fieldbyname('L_Truck').AsString;
      editStockName.Text := fieldbyname('L_StockName').AsString;
      editNum.Text := fieldbyname('L_Value').AsString;
      editCusName.text := fieldbyname('L_CusName').AsString;
    end;
  end;

  nStr := 'select * from %s where T_Card= ''%s''';
  nStr := Format(nStr,[sTable_Truck,nCard]);
  with FDM.QueryTemp(nStr) do
  begin                                  
    if RecordCount > 0 then
    begin
      editCardType.Text := '销售长期卡';
      if nHasBill and (editTruck.Text <> FieldByName('T_Truck').AsString) then
      begin
        nStr := '销售长期卡绑定车辆 ['+ FieldByName('T_Truck').AsString +
                '] 与当前订单车辆 ['+editTruck.Text+'] 不一致.';
        ShowMessage(nStr);
        exit;
      end;
      editTruck.Text := FieldByName('T_Truck').AsString;
      
      //如果是长期卡，并且没有订单，去微信商城查订单
      if not nHasBill then
      begin
        nStr := GetBillByTruck(PackerEncodeStr(editTruck.Text));
        if nStr = '' then
        begin
          editBill.Text := '无商城订单';
          exit;
        end;
        nStr := PackerDecodeStr(nStr);
        nList := TStringList.Create;
        nList.Text := nStr;

        if Trim(nList.Values['order_type']) = 'NULL' then
        begin
          editBill.Text := '无商城订单';
          Exit;
        end;

        editStockName.Text :=  nList.Values['goodsname'];
        editNum.Text := nList.Values['data'];

        if Trim(nList.Values['order_type']) = 'S' then
        begin
          editBill.Text := '微信销售单';
          nStr := 'select C_Name from %s a,%s b where a.Z_Customer=b.C_ID and a.Z_ID=''%s''';
          nStr := Format(nStr,[sTable_ZhiKa,sTable_Customer,nList.Values['fac_order_no']]);
          with FDM.QuerySQL(nStr) do
          begin
            editcusname.Text := FieldByName('C_Name').AsString;
          end;
        end
        else
        begin
          editBill.Text := '微信供应单';
          nStr := 'select b_proid as provider_code,b_proname as provider_name,'+
                  'b_stockno as con_materiel_Code,b_restvalue as '+
                  'con_remain_quantity from %s where b_id=''%s''';
          nStr := Format(nStr,[sTable_OrderBase,nList.Values['fac_order_no']]);
          with FDM.QuerySQL(nStr) do
          begin
            editcusname.Text := FieldByName('provider_name').AsString;
          end;
        end;
      end;
    end
    else
    begin
      if nHasBill then
        editCardType.Text := '销售临时卡'
      else
        editCardType.Text := '空卡';
    end;
  end; 
end;

initialization
  gControlManager.RegCtrl(TfFormQryCard, TfFormQryCard.FormID);
end.
