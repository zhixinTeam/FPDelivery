unit UShowOrderInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  UMITPacker,UClientWorker,UBusinessConst,USysBusiness,UMainFrom;

type
  TFrmShowOrderInfo = class(TfrmFormBase)
    Label6: TLabel;
    tmrGetOrder: TTimer;
    BtnCancel: TSpeedButton;
    BtnOK: TSpeedButton;
    EditKZValue: TEdit;
    Label10: TLabel;
    Label8: TLabel;
    lblTruck: TLabel;
    lblMate: TLabel;
    Label4: TLabel;
    lblProvider: TLabel;
    lblID: TLabel;
    Label1: TLabel;
    lblTestNo: TLabel;
    Label3: TLabel;
    BtnPrintCode: TSpeedButton;
    CheckBox1: TCheckBox;
    procedure tmrGetOrderTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BtnPrintCodeClick(Sender: TObject);
  private
    { Private declarations }
    FPrintBarCode:string;
  public
    { Public declarations }
  end;

var
  gCardNO: string;
  FrmShowOrderInfo: TFrmShowOrderInfo;
  gOrders: TLadingBillItems;

implementation

uses
  Androidapi.JNI.GraphicsContentViewText, FMX.Helpers.Android,
  Androidapi.JNI.JavaTypes, FMX.Platform.Android, AndroidApi.JniBridge, AndroidApi.Jni.App,
  AndroidAPI.jni.OS,Androidapi.Helpers;

{$R *.fmx}

procedure TFrmShowOrderInfo.BtnCancelClick(Sender: TObject);
begin
  inherited;
  MainForm.Show;
  Self.Hide;
end;

procedure TFrmShowOrderInfo.BtnOKClick(Sender: TObject);
var
  nYSVaid: string;
begin
  inherited;
  if Length(gOrders)>0 then
  with gOrders[0] do
  begin
    if CheckBox1.IsChecked then
          nYSVaid := 'N'
    else  nYSVaid := 'Y';
    FYSValid := nYSVaid;
    FTestNo := lblTestNo.Text;

    FKZValue := StrToFloatDef(EditKZValue.Text, 0);

    if gsysparam.FIsHYS then //如果是化验室
    begin
      if FPrintBarCode = 'Y' then
        BtnPrintCodeClick(Self);

      if SaveHysYS('X', gOrders) then
        MainForm.Show;
    end
    else
    begin
      if SavePurchaseOrders('X', gOrders) then
        MainForm.Show;
    end;
  end;
end;

procedure TFrmShowOrderInfo.BtnPrintCodeClick(Sender: TObject);
var
  BarCodeIntent: JIntent;
  nBarcode: string;
begin
  nBarcode := trim(lblTestNo.Text);
  if nBarcode = '' then exit;

  BarCodeIntent := TJIntent.Create;
  BarCodeIntent.putExtra(StringToJString('data'), StringToJString(lblTestNo.Text));
  BarCodeIntent.setAction(StringToJString('HNZXTECH_ACTION'));
  SharedActivityContext.sendBroadcast(BarCodeIntent);
end;

procedure TFrmShowOrderInfo.FormActivate(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZValue.Text := '0.00';

  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
end;

procedure TFrmShowOrderInfo.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//如果按下物理返回键
  begin
    MessageDlg('确认退出吗？', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //退出程序

    Key := 0;//必须的，不然按否也会退出
    Exit;
  end;    }
end;

procedure TFrmShowOrderInfo.FormShow(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  lblTestNo.Text   := '';
  EditKZValue.Text := '0.00';

  BtnOK.Enabled := False;
  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
  if gSysParam.FIsHYS then
  begin
    checkbox1.visible := false;
    EditKZValue.visible := False;
    Label10.visible := False;
  end;
end;

procedure TFrmShowOrderInfo.tmrGetOrderTimer(Sender: TObject);
var nIdx, nInt: Integer;
    nStr : string;
    nTestNo, nCusID, nStockNo :string;
begin
  tmrGetOrder.Enabled := False;

  if not GetPurchaseOrders(gCardNO, 'X', gOrders) then
  begin
    BtnCancelClick(Self);
    Exit;
  end;

  nInt := 0;
  for nIdx := Low(gOrders) to High(gOrders) do
  with gOrders[nIdx] do
  begin
    FSelected := (FNextStatus='X') or (FNextStatus='M');
    if FSelected then Inc(nInt);
  end;

  if nInt<1 then
  begin
    nStr := '磁卡[%s]无需要验收车辆';
    nStr := Format(nStr, [gCardNo]);

    ShowMessage(nStr);
    Exit;
  end;

  with gOrders[0] do
  begin
    lblID.Text       := FID;
    lblProvider.Text := FCusName;
    lblMate.Text     := FStockName;
    lblTruck.Text    := FTruck;

    EditKZValue.Text := FloatToStr(FKZValue);
    nTestNo          := FTestNo;
    nCusID           := FCusID;
    nStockNo         := FStockNo;
    if nTestNo = '' then
    begin
      nTestNo := GetTestNo(nCusID,nStockNo);
      lblTestNo.Text := Copy(nTestNo,1,Pos('@',nTestNo)-1);
      FPrintBarCode := Copy(nTestNo,Pos('@',nTestNo)+1,1);
      FTestNo := lblTestNo.Text;
    end
    else
      lblTestNo.Text := nTestNo;
  end;

  BtnOK.Enabled := True;
end;

end.
