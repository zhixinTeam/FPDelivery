unit UFormBackCashRule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit, cxMCListBox, ComCtrls, cxListView;

type
  TfFormBackCashRule = class(TfFormNormal)
    editZhika: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    editStockNo: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    GroupBox1: TGroupBox;
    dxLayout1Item5: TdxLayoutItem;
    btnDel: TButton;
    dxLayout1Item6: TdxLayoutItem;
    btnAdd: TButton;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    ListDetail: TcxListView;
    EditStart: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    editValue: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormBackCashRule: TfFormBackCashRule;

implementation

{$R *.dfm}

uses
  UFormBase, USysConst, UDataModule, USysDB, UMgrControl, ULibFun, UFormCtrl;

{ TfFormBackCashRule }

class function TfFormBackCashRule.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nP: PFormCommandParam;
  nStr: string;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormBackCashRule.Create(Application) do
  begin
    editZhika.Text := nP.FParamA;
    editStockNo.Text := nP.FParamB;
    if nP.FParamA = '' then
    begin
      nStr := 'select * from %s where B_StockNo=''%s''';
      nStr := Format(nStr,[sTable_BackCashRuleTmp,nP.FParamB]);
    end
    else
    begin
      nStr := 'select * from %s where B_Zhika=''%s'' and B_StockNo=''%s''';
      nStr := Format(nStr,[sTable_BackCashRule, nP.FParamA ,nP.FParamB]);
    end;

    with FDM.QueryTemp(nStr) do
    if recordcount > 0 then
    begin
      First;
      while not Eof do
      begin
        with ListDetail.Items.Add do
        begin
          Caption := FieldByName('B_LeaveL').AsString;
          SubItems.Add(FieldByName('B_LeaveH').AsString);
          SubItems.Add(FieldByName('B_value').AsString);
        end;
        Next;
      end;
    end;

    ShowModal;
    Free;
  end;
end;

class function TfFormBackCashRule.FormID: integer;
begin
  Result := cFI_FormBackCashRule;
end;

procedure TfFormBackCashRule.btnAddClick(Sender: TObject);
var
  nStart, nEnd: Double;
  FStart, Fend: Double;
  i :integer;
begin
  if not IsDataValid then Exit;

  nStart := StrToFloat(EditStart.Text);
  nEnd   := StrToFloat(EditEnd.Text);

  if nEnd <= nStart then
  begin
    ShowMsg('结束值应大于起始值',sHint);
    EditEnd.SetFocus;
    Exit;
  end;

  //循环检测范围是否重叠
  for i := 0 to ListDetail.Items.Count -1 do
  begin
    FStart := StrToFloat(ListDetail.Items[i].Caption);
    Fend := StrToFloat(ListDetail.Items[i].SubItems.Strings[0]);

    if FloatRelation(FStart, nStart, rtLE) and
       FloatRelation(FEnd, nStart, rtGreater) then
    begin
      ActiveControl := EditStart;
      ShowMsg('起始范围已重叠.', sHint);
      Exit;
    end
    else 
    if FloatRelation(FStart, nEnd, rtLess) and
       FloatRelation(FEnd, nEnd, rtGE) then
    begin
      ActiveControl := EditEnd;
      ShowMsg('结束范围已重叠.', sHint);
      Exit;
    end;
  end;

  with ListDetail.Items.Add do
  begin
    caption := EditStart.Text;
    subitems.add(EditEnd.Text);
    subitems.add(editValue.Text);
  end;

end;

procedure TfFormBackCashRule.btnDelClick(Sender: TObject);
var
  n: integer;
begin
  n := ListDetail.ItemIndex;
  if n > -1 then
  begin
    ListDetail.Items.Delete(n);
  end;
end;

procedure TfFormBackCashRule.BtnOKClick(Sender: TObject);
var
  nStr: string;
  i: integer;
  nStar, nEnd, nValue: Double;
  nList: TStrings;
begin
  nList := TStringList.Create;

  if editZhika.Text = '' then
  begin
    nStr := 'delete from %s where B_StockNo=''%s''';
    nStr := Format(nStr,[sTable_BackCashRuleTmp,editStockNo.Text]);
  end
  else
  begin
    nStr := 'delete from %s where B_ZhiKa=''%s'' and B_StockNo=''%s''';
    nStr := Format(nStr, [sTable_BackCashRule,editZhika.Text,editStockNo.Text]);
  end;

  nList.Add(nStr);

  for i := 0 to ListDetail.Items.Count - 1 do
  begin
    nStar := StrToFloat(ListDetail.Items[i].Caption);
    nEnd := StrToFloat(ListDetail.Items[i].SubItems.Strings[0]);
    nValue := StrToFloat(ListDetail.Items[i].SubItems.Strings[1]);

    if editZhika.Text = '' then
    begin
      nStr := MakeSQLByStr([SF('B_ZhiKa', editZhika.Text),
              SF('B_StockNo', editStockNo.Text),
              SF('B_User', gSysParam.FUserID),
              SF('B_Date', Now),
              SF('B_LeaveL', nStar, sfVal),
              SF('B_LeaveH', nEnd, sfVal),
              SF('B_Value', nValue, sfVal)
              ], sTable_BackCashRuleTmp, '', True);
      nList.Add(nStr);
    end
    else
    begin
      nStr := MakeSQLByStr([SF('B_ZhiKa', editZhika.Text),
              SF('B_StockNo', editStockNo.Text),
              SF('B_User', gSysParam.FUserID),
              SF('B_Date', Now),
              SF('B_LeaveL', nStar, sfVal),
              SF('B_LeaveH', nEnd, sfVal),
              SF('B_Value', nValue, sfVal)
              ], sTable_BackCashRule, '', True);
      nList.Add(nStr);
    end;
  end;

  nStr := '';

  if nList.Count > 0 then
  try
    FDM.ADOConn.BeginTrans;

    for i := 0 to nList.Count-1 do
      fdm.ExecuteSQL(nList[i]);

    FDM.WriteSysLog(sFlag_ZhiKaItem, editZhika.Text, '修改纸卡返现规则.', False);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('提成规则失败', sError);
    Exit;
  end;
  nList.Free;
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormBackCashRule, TfFormBackCashRule.FormID);

end.
