unit UFormTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutcxEditAdapters,
  dxLayoutControl, StdCtrls, cxTextEdit, cxCurrencyEdit, dxSkinsCore,
  dxSkinsDefaultPainters;

type
  TfFormTestResult = class(TBaseForm)
    dxLayoutControl1: TdxLayoutControl;
    EditTestNo: TcxTextEdit;
    BtnExit: TButton;
    BtnOK: TButton;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Item7: TdxLayoutItem;
    EditResult1: TcxCurrencyEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditResult2: TcxCurrencyEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    Memo1: TMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
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
  fFormTestResult: TfFormTestResult;

implementation

{$R *.dfm}

uses
  UMgrControl, USysConst, USysDB, USysPopedom, ULibFun, UDataModule, UFormCtrl;

{ TfFormTestResult }

class function TfFormTestResult.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormTestResult.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfFormTestResult.EditLadingKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    if Sender = EditTestNo then ActiveControl := EditResult1 else
    if Sender = EditResult1 then ActiveControl := EditResult2 else
    if Sender = EditResult2 then ActiveControl := BtnOK else
  end;
end;

class function TfFormTestResult.FormID: integer;
begin
  Result := cFI_FormTestResult;
end;

//录入化验结果，修改净重，扣重，化验结果
procedure TfFormTestResult.BtnOKClick(Sender: TObject);
var
  nStr, nStockNo, nSQL, nID: string;
  NetValue, nNKStandard1, nNKStandard2, nTestRZ, nTestSF, RZKZ, SFKZ: Double;
  FListA: TStringList;
  i: Integer;
begin
  inherited;
  EditTestNo.Text := Trim(EditTestNo.Text);
  nTestRZ := EditResult1.Value;
  nTestSF := EditResult2.Value;
  FListA := TStringList.Create;

  if EditTestNo.Text = '' then
  begin
    ShowMsg('化验编号不能为空.',sHint);
    EditTestNo.SetFocus;
    exit;
  end;

  nStr := 'select * from %s where D_TestNo=''%s''';
  nStr := Format(nStr,[sTable_OrderDtl,EditTestNo.Text]);
  with FDM.QuerySQL(nStr) do
  begin
    if recordcount = 0 then
    begin
      ShowMsg('化验编号不正确.',sHint);
      EditTestNo.SetFocus;
      exit;
    end;
    First;
    while not Eof do
    begin
      nStockNo := FieldByName('D_StockNo').AsString;
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
        nNKStandard1 := FieldByName('D_ParamA').AsFloat;
        if FieldByName('D_ParamB').AsString = '' then
          nNKStandard2 := 0
        else
          nNKStandard2 := FieldByName('D_ParamB').AsFloat;
      end;

      if nTestRZ >= nNKStandard1 then
        RZKZ := 0
      else
        RZKZ := ((nNKStandard1 - nTestRZ) / nNKStandard1)* FieldByName('D_Value').AsFloat;

      if nTestSF <= nNKStandard2 then
        SFKZ := 0
      else
        SFKZ := ((nTestSF - nNKStandard2) / 100)* FieldByName('D_Value').AsFloat;

      RZKZ :=  Float2Float(RZKZ,100,True);
      SFKZ :=  Float2Float(SFKZ,100,True);

      //大于净重直接扣光
      if RZKZ > NetValue then
        RZKZ := NetValue;
      if SFKZ > NetValue then
        SFKZ := NetValue;

      nSQL := MakeSQLByStr([
                //SF('D_TestNo', EditTestNo.Text),
                SF('D_TestJG1', nTestRZ, sfVal),
                SF('D_TestJG2', nTestSF, sfVal),
                SF('D_Value', NetValue, sfVal),
                SF('D_HysMemo', Memo1.Text),
                SF('D_HysUser', gSysParam.FUserID),
                SF('D_SFKZ', SFKZ, sfVal),
                SF('D_HysKZ',RZKZ , sfVal)
                ], sTable_OrderDtl, SF('D_ID', nID), False);
       FListA.Add(nSQL);
       Next;
    end;
  end;
  try
    FDM.ADOConn.BeginTrans;
    for i := 0 to FListA.Count -1 do
      FDM.ExecuteSQL(FListA[i]);

    nStr := '录入物料['+EditTestNo.Text+']的检验结果,热值:['+editresult1.Text+
            '],水分:'+editresult1.text;
    FDM.WriteSysLog(sFlag_MaterailsItem,(EditTestNo.Text),nStr);
    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
    FListA.Free;
    ShowMessage('录入检验结果失败！');
    exit;
  end;
  ShowMsg('样品[ '+EditTestNo.Text+' ]检验结果录入成功.',sHint);
  FListA.Free;
  EditTestNo.Text := '';
  EditResult1.Text := '';
  EditResult2.Text := '';
  EditTestNo.SetFocus;
end;

initialization
  gControlManager.RegCtrl(TfFormTestResult, TfFormTestResult.FormID);
end.
