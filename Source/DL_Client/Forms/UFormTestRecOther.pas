unit UFormTestRecOther;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters, cxContainer, cxEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxTextEdit, cxCurrencyEdit;

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
    procedure FormCreate(Sender: TObject);
    procedure cbStockNoPropertiesChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FList: TStrings;
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
  nNKStandard, nTestJG, KZLast, NetValue, KZ: Double;
begin
  inherited;
  if cbStockNo.Text = '' then
  begin
    ShowMsg('物料编号不能为空.',sHint);
    cbStockNo.SetFocus;
    exit;
  end;
  if editResult.Text = '' then
  begin
    ShowMsg('检验结果不能为空.',sHint);
    editResult.SetFocus;
    exit;
  end;
  FListA := TStringList.Create;
  nStockNo := cbStockNo.Text;
  nTestJG := editResult.Value;

  nStr := 'select * from %s where D_InTime >= ''%s'' and D_InTime <''%s'''+
          ' and D_StockNo=''%s''';
  nStr := Format(nStr,[sTable_Materails,editDateBegin.Text,editDateEnd.Text,nStockNo]);
  with FDM.QuerySQL(nStr) do
  begin
    if recordcount = 0 then
    begin
      ShowMsg('所选时间段没有采购记录.',sHint);
      editDateBegin.SetFocus;
      exit;
    end;
    First;
    while not Eof do
    begin
      NetValue := FieldByName('D_MValue').AsFloat - FieldByName('D_PValue').AsFloat - FieldByName('D_KZValue').AsFloat;
      nID := FieldByName('D_ID').AsString;

      //检索内控标准
      nStr := 'Select * from %s where D_Name=''%s'' and D_Value=''%s''';
      nStr := Format(nStr,[sTable_SysDict,'CtrlStandard',nStockNo]);
      with FDM.QueryTemp(nStr) do
      begin
        if recordcount = 0 then
        begin
          ShowMsg('物料['+nStockNo+']未设置内控标准，请先设置内控标准.',sHint);
          exit;
        end;

        nNKStandard := FieldByName('D_ParamA').AsFloat;
      end;
      
      if nTestJG <= nNKStandard then
        KZ := 0
      else
        KZ := ((nTestJG - nNKStandard) / nNKStandard)* FieldByName('D_Value').AsFloat;

      KZLast :=  Float2Float(KZ,100,True);

      //大于净重直接扣光
      if KZLast > NetValue then
        KZLast := NetValue;

      nStr := MakeSQLByStr([
                SF('D_TestJG1', nTestJG, sfVal),
                SF('D_Value', NetValue-KZLast, sfVal),
                SF('D_HysMemo', Memo1.Text),
                SF('D_HysUser', gSysParam.FUserID),
                SF('D_HysKZ',KZLast , sfVal)
                ], sTable_OrderDtl, SF('D_ID', nID), False);
       FListA.Add(nStr);
       Next;
    end;
  end;

  try
    FDM.ADOConn.BeginTrans;
    for i := 0 to FListA.Count -1 do
      FDM.ExecuteSQL(FListA[i]);

    nStr := '录入物料['+editstockname.Text+']的检验结果:['+editresult.Text+
            '],时间:'+editdatebegin.text+' 到 '+editdateend.Text;
    FDM.WriteSysLog(sFlag_MaterailsItem,(cbStockNo.Text),nStr);

    FDM.ADOConn.CommitTrans;
    
    ShowMsg('样品[ '+editstockname.Text+' ]检验结果录入成功.',sHint);
  except
    FDM.ADOConn.RollbackTrans;
    FListA.Free;
    ShowMessage('录入检验结果失败！');
    exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormTestRecOther, TfFormTestRecOther.FormID);
end.
