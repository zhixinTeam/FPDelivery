unit UFormTestRecOther;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters, cxContainer, cxEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxTextEdit, cxCurrencyEdit,
  UFormBase;
type
  TProviderParam = record
    FID   : string;
    FName : string;
    FSaler: string;
  end;
type
  TfFormTestRecOther = class(TfFormNormal)
    cbStockNo: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    editStockName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    editDateBegin: TcxDateEdit;
    dxLayout1Item6: TdxLayoutItem;
    editDateEnd: TcxDateEdit;
    dxLayout1Item7: TdxLayoutItem;
    editResult: TcxCurrencyEdit;
    dxLayout1Item8: TdxLayoutItem;
    Memo1: TMemo;
    dxLayout1Item9: TdxLayoutItem;
    editSF: TcxCurrencyEdit;
    dxLayout1Item5: TdxLayoutItem;
    editProd: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure cbStockNoPropertiesChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure editProdKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FList: TStrings;
    FProvider: TProviderParam;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormTestRecOther: TfFormTestRecOther;

implementation

uses UDataModule, USysConst, USysDB, UMgrControl, ULibFun, UFormCtrl;

{$R *.dfm}

{ TfFormTestRecOther }

class function TfFormTestRecOther.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormTestRecOther.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

class function TfFormTestRecOther.FormID: integer;
begin
  Result := cFI_FormTestRecOther;
end;

procedure TfFormTestRecOther.FormCreate(Sender: TObject);
var
  nStr: string;
begin
  inherited;
  FList := TStringList.Create;
  FillChar(FProvider, 1, #0);

  nStr := 'select M_ID,M_Name from %s where M_IsMei=''%s''';
  nStr := Format(nStr,[sTable_Materails, sFlag_No]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      FList.Add(FieldByName('M_Name').AsString);
      cbStockNo.Properties.Items.Add(FieldByName('M_ID').AsString);
      Next;
    end;
  end;
end;

procedure TfFormTestRecOther.cbStockNoPropertiesChange(Sender: TObject);
begin
  editStockName.Text := FList.Strings[cbStockNo.ItemIndex];
end;

procedure TfFormTestRecOther.BtnOKClick(Sender: TObject);
var
  nStr: string;
  FListA: TStrings;
  nStockNo, nID:string;
  i: integer;
  nNKStandardZL, nNKStandardSF, nTestZL, nTestSF, NetValue, KZZL, KZSF: Double;
begin
  inherited;
  if cbStockNo.Text = '' then
  begin
    ShowMsg('���ϱ�Ų���Ϊ��.',sHint);
    cbStockNo.SetFocus;
    exit;
  end;

  if editProd.Text = '' then
  begin
    ShowMsg('��Ӧ�̲���Ϊ��.',sHint);
    editProd.SetFocus;
    exit;
  end;
  
  if editResult.Text = '' then
  begin
    ShowMsg('����������Ϊ��.',sHint);
    editResult.SetFocus;
    exit;
  end;

  FListA := TStringList.Create;
  nStockNo := cbStockNo.Text;
  nTestZL := editResult.Value;
  nTestSF := editSF.Value;
  
  //�����ڿر�׼
  nStr := 'Select * from %s where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr,[sTable_SysDict,'CtrlStandard',nStockNo]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount = 0 then
    begin
      ShowMsg('����['+nStockNo+']δ�����ڿر�׼�����������ڿر�׼.',sHint);
      exit;
    end;

    nNKStandardZL := FieldByName('D_ParamA').AsFloat;

    if FieldByName('D_ParamB').AsString = '' then
      nNKStandardSF := 0
    else
      nNKStandardSF := FieldByName('D_ParamB').AsFloat;
  end;

  nStr := 'select * from %s where D_InTime >= ''%s'' and D_InTime <''%s'''+
          ' and D_StockNo=''%s'' and D_ProID=''%s''';
  nStr := Format(nStr,[sTable_OrderDtl,editDateBegin.Text,editDateEnd.Text,nStockNo, FProvider.FID]);
  with FDM.QuerySQL(nStr) do
  begin
    if recordcount = 0 then
    begin
      ShowMsg('��ѡʱ���û�иù�Ӧ�̵Ĺ�����¼.',sHint);
      editDateBegin.SetFocus;
      exit;
    end;
    First;
    while not Eof do
    begin
      NetValue := FieldByName('D_MValue').AsFloat - FieldByName('D_PValue').AsFloat - FieldByName('D_KZValue').AsFloat;
      nID := FieldByName('D_ID').AsString;

      //��������
      if nTestZL >= nNKStandardZL then
        KZZL := 0
      else
        KZZL := ((nNKStandardZL - nTestZL) / nNKStandardZL)* FieldByName('D_Value').AsFloat;
        
      //ˮ�ֿ���
      if nTestSF <= nNKStandardSF then
        KZSF := 0
      else
        KZSF := ((nTestSF - nNKStandardSF) / 100)* FieldByName('D_Value').AsFloat;

      //���ھ���ֱ�ӿ۹�
      if KZZL > NetValue then
        KZZL := NetValue;
      if KZSF > NetValue then
        KZSF := NetValue;


      nStr := MakeSQLByStr([
                SF('D_TestJG1', nTestZL, sfVal),
                SF('D_TestJG2', nTestSF, sfVal),
                SF('D_Value', NetValue, sfVal),
                SF('D_HysMemo', Memo1.Text),
                SF('D_HysUser', gSysParam.FUserID),
                SF('D_SFKZ',KZSF , sfVal),
                SF('D_HysKZ',KZZL , sfVal)
                ], sTable_OrderDtl, SF('D_ID', nID), False);
       FListA.Add(nStr);
       Next;
    end;
  end;

  try
    FDM.ADOConn.BeginTrans;
    for i := 0 to FListA.Count -1 do
      FDM.ExecuteSQL(FListA[i]);

    nStr := '¼������['+editstockname.Text+']�ļ�����:����['+editresult.Text+
            ',ˮ��:'+editsf.Text+
            '],��Ӧ��:'+editprod.Text+'ʱ��:'+editdatebegin.text+' �� '+editdateend.Text;
    FDM.WriteSysLog(sFlag_MaterailsItem,(cbStockNo.Text),nStr);

    FDM.ADOConn.CommitTrans;
    
    ShowMsg('��Ʒ[ '+editstockname.Text+' ]������¼��ɹ�.',sHint);
  except
    FDM.ADOConn.RollbackTrans;
    FListA.Free;
    ShowMessage('¼�������ʧ�ܣ�');
    exit;
  end;
end;

procedure TfFormTestRecOther.editProdKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    nP.FParamA := EditProd.Text;
    CreateBaseFormItem(cFI_FormGetProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FProvider do
    begin
      FID   := nP.FParamB;
      FName := nP.FParamC;
      FSaler:= nP.FParamE;

      EditProd.Text := FName;
    end;

    EditProd.SelectAll;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormTestRecOther, TfFormTestRecOther.FormID);
end.
