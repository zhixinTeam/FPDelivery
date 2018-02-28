unit UFormSealNum;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, CPort, CPortTypes,
  dxLayoutcxEditAdapters, cxContainer, cxEdit, cxTextEdit;

type
  TfFormSealNum = class(TfFormNormal)
    EditCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSealNum: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    ComPort1: TComPort;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure EditSealNumKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormSealNum: TfFormSealNum;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, USmallFunc, IniFiles, USysDB, UDataModule, ULibFun,
  USysBusiness, UBusinessConst;

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

{ TfFormNormal1 }

class function TfFormSealNum.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormSealNum.Create(Application) do
  begin
    ActiveControl := EditCard;
    ActionComPort(False);
    ShowModal;
    Free;
  end;
end;

class function TfFormSealNum.FormID: integer;
begin
  Result := cFI_FormSealNum;
end;

procedure TfFormSealNum.BtnOKClick(Sender: TObject);
var
  nStr, nSealNum, nCard: string;
  nRet: Boolean;
  gBills: TLadingBillItems;
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    ActiveControl := EditCard;
    EditCard.SelectAll;

    ShowMessage('请输入有效卡号');
    Exit;
  end;

  EditSealNum.Text := Trim(EditSealNum.Text);
  if EditSealNum.Text = '' then
  begin
    ActiveControl := EditSealNum;
    EditSealNum.SelectAll;
    ShowMessage('请输入有效封签号');
    Exit;
  end;
  nSealNum := EditSealNum.Text;
  nCard := EditCard.Text;

  nRet := GetLadingBills(nCard, sFlag_TruckOut, gBills);
  if not nRet then
  begin
    //ShowMessage('该磁卡未找到相应的交货单号.');
    EditCard.SetFocus;
    EditCard.SelectAll;
    Exit;
  end;

  try
    nStr := 'update %s set L_Seal=''%s'' where l_Card=''%s''';
    nStr := Format(nStr,[sTable_Bill,nSealNum,nCard]);

    FDM.ExecuteSQL(nStr);
    
    //nRet := SaveLadingBills(sFlag_TruckOut, gBills);
  except
    nRet := False;
    ShowMessage('录入封签号失败.');
    Exit;
  end;
//  if nRet then
//  begin
//    ShowMsg('录入封签号成功，且成功出厂.',sHint);
//    EditCard.Text := '';
//    EditSealNum.Text := '';
//    ActiveControl := EditCard;
//  end;
end;

procedure TfFormSealNum.ComPort1RxChar(Sender: TObject; Count: Integer);
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
    EditSealNum.SetFocus;
    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormSealNum.ActionComPort(const nStop: Boolean);
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

procedure TfFormSealNum.EditSealNumKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = #13 then
    BtnOKClick(Self);
end;

initialization
  gControlManager.RegCtrl(TfFormSealNum, TfFormSealNum.FormID);
end.
