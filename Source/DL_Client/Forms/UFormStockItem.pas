unit UFormStockItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, cxContainer, cxEdit,
  dxLayoutcxEditAdapters, cxDropDownEdit, cxCalendar, cxLabel, cxTextEdit,
  cxMaskEdit, StdCtrls, ComCtrls, cxTreeView, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, USysDataFun,
  cxGridDBTableView, cxGrid, ADODB, cxPC, ExtCtrls, cxCurrencyEdit;

type
  TfFormStockItem = class(TBaseForm)
    dxLayout1: TdxLayoutControl;
    BtnEdit: TButton;
    BtnDel: TButton;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    DataSource1: TDataSource;
    ADOQuery: TADOQuery;
    cxPG1: TcxPageControl;
    dxLayout1Item1: TdxLayoutItem;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxView1: TcxGridDBTableView;
    cxLevel1: TcxGridLevel;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    Panel1: TPanel;
    cbxType: TcxComboBox;
    EditStockNo: TcxTextEdit;
    EditStockName: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxView1Column1: TcxGridDBColumn;
    cxView1Column2: TcxGridDBColumn;
    cxView1Column3: TcxGridDBColumn;
    BtnAdd: TButton;
    dxLayout1Item4: TdxLayoutItem;
    cxGrid3: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Panel2: TPanel;
    cbStock: TcxComboBox;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    EditValue: TcxCurrencyEdit;
    cxTabSheet3: TcxTabSheet;
    cxGrid4: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    Panel3: TPanel;
    cbCtrlStand: TcxComboBox;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    EditCtrlStandValue: TcxCurrencyEdit;
    cxTabSheet4: TcxTabSheet;
    cxGrid5: TcxGrid;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    Panel4: TPanel;
    cbTestRules: TcxComboBox;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    EditTestRulesValue: TcxCurrencyEdit;
    EditCtrlStandValue2: TcxCurrencyEdit;
    cxLabel10: TcxLabel;
    cxGridDBTableView2Column1: TcxGridDBColumn;
//    procedure cxTreeView1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    function CheckExt(nType,nField,nText:string):Boolean;
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure SelData(nParam:string);
    procedure FormDestroy(Sender: TObject);
    procedure cxPG1Change(Sender: TObject);
    procedure Initform(i:Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    //procedure LoadDict;
  end;

var
  fFormStockItem: TfFormStockItem;
  FListA, FListB: TStringList;

implementation

{$R *.dfm}
uses
  UDataModule, USysDB, USysConst, UMgrControl, UFormCtrl, ULibFun;

class function TfFormStockItem.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else New(nP);

  with TfFormStockItem.Create(Application) do
  try
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormStockItem.FormID: integer;
begin
  Result := cFI_FormStockItem;
end;

procedure TfFormStockItem.FormCreate(Sender: TObject);
var
  nStr:string;
begin
  inherited;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  nStr := 'select M_ID,M_Name from %s';
  nStr := Format(nStr,[sTable_Materails]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      FListB.Add(FieldByName('M_ID').AsString);
      cbCtrlStand.Properties.Items.Add(FieldByName('M_Name').AsString);
      cbTestRules.Properties.Items.Add(FieldByName('M_Name').AsString);
      Next;
    end;
  end;
  Initform(0);
end;

procedure TfFormStockItem.BtnAddClick(Sender: TObject);
var
  nStr, nType: string;
begin
  case cxPG1.ActivePageIndex of
  0:begin
      EditStockNo.Text := Trim(EditStockNo.Text);
      if cbxType.ItemIndex = 0 then
        nType := sFlag_Dai
      else
        nType := sFlag_San;

      if CheckExt(sFlag_StockItem,'D_ParamB',EditStockNo.Text) then
      begin
        ShowMessage('水泥编号'+EditStockNo.Text+'已经存在.');
        EditStockNo.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := MakeSQLByStr([
                SF('D_Name', sFlag_StockItem),
                SF('D_Desc', '水泥类型'),
                SF('D_Value', EditStockName.Text),
                SF('D_Memo', nType),
                SF('D_ParamB',EditStockNo.Text)
                ], sTable_SysDict, '', True);

          FDM.ADOConn.BeginTrans;
          FDM.ExecuteSQL(nStr);
          nStr := '添加水泥类型['+EditStockNo.Text+']';
          FDM.WriteSysLog(sFlag_StockItem,EditStockNo.Text,nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Close;
          ADOQuery.Open;
          ADOQuery.Locate('D_ParamB',EditStockNo.Text,[loCaseInsensitive]);
        except
          fdm.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          Exit;
        end;
      end;
    end;
  1:begin
      if cbStock.ItemIndex < 0 then Exit;
      if CheckExt(sFlag_StockLimited,'D_Value',FListA.Strings[cbStock.Itemindex]) then
      begin
        ShowMessage('水泥['+cbstock.Text+']限额已经设定，勿重复添加.');
        cbStock.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := MakeSQLByStr([
                SF('D_Name', sFlag_StockLimited),
                SF('D_Desc', '日发货量'),
                SF('D_Value', FListA.Strings[cbStock.ItemIndex]),
                SF('D_Memo', cbStock.Text),
                SF('D_ParamA',EditValue.Value,sfVal)
                ], sTable_SysDict, '', True);

          FDM.ADOConn.BeginTrans;
          fdm.ExecuteSQL(nStr);
          nStr := '添加水泥['+cbstock.Text+']限额'+editvalue.Text;
          FDM.WriteSysLog(sFlag_StockLimited,cbstock.Text,nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Close;
          ADOQuery.Open;
          ADOQuery.Locate('D_Value',FListA.Strings[cbStock.itemindex],[loCaseInsensitive]);
        except
          FDM.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          Exit;
        end;
      end;
    end;
  2:begin
      if cbCtrlStand.ItemIndex < 0 then Exit;
      if CheckExt(sFlag_CtrlStandard,'D_Value',FListB.Strings[cbCtrlStand.Itemindex]) then
      begin
        ShowMessage('原材料['+cbCtrlStand.Text+']标准已经设定，勿重复添加.');
        cbCtrlStand.SetFocus;
        Exit;
      end
      else
      begin
        nStr := MakeSQLByStr([
                SF('D_Name', sFlag_CtrlStandard),
                SF('D_Desc', '采购内控标准'),
                SF('D_Value', FListB.Strings[cbCtrlStand.ItemIndex]),
                SF('D_Memo', cbCtrlStand.Text),
                SF('D_ParamA',EditCtrlStandValue.Value,sfVal),
                SF('D_ParamB',EditCtrlStandValue2.Text)
                ], sTable_SysDict, '', True);
        try
          FDM.ADOConn.BeginTrans;
          fdm.ExecuteSQL(nStr);
          nStr := '添加原材料['+cbCtrlStand.Text+']内控标准,标准1:'+EditCtrlStandValue.Text+',标准2:'+EditCtrlStandValue2.Text;
          FDM.WriteSysLog(sFlag_CtrlStandard,cbCtrlStand.Text,nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Close;
          ADOQuery.Open;
          ADOQuery.Locate('D_Value',FListB.Strings[cbCtrlStand.itemindex],[loCaseInsensitive]);
        except
          FDM.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          Exit;
        end;
      end;
    end;
  3:begin
      if cbTestRules.ItemIndex < 0 then Exit;
      if CheckExt(sFlag_TestRules,'D_Value',FListB.Strings[cbTestRules.Itemindex]) then
      begin
        ShowMessage('原材料['+cbTestRules.Text+']检验规则已经设定，勿重复添加.');
        cbTestRules.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := MakeSQLByStr([
                SF('D_Name', sFlag_TestRules),
                SF('D_Desc', '检验规则'),
                SF('D_Value', FListB.Strings[cbTestRules.ItemIndex]),
                SF('D_Memo', cbTestRules.Text),
                SF('D_ParamA',EditTestRulesValue.Value,sfVal)
                ], sTable_SysDict, '', True);

          FDM.ADOConn.BeginTrans;
          fdm.ExecuteSQL(nStr);
          nStr := '添加原材料[ '+cbTestRules.Text+' ]检验规则:[ '+EditTestRulesValue.Text+' ]车一抽检';
          FDM.WriteSysLog(sFlag_CtrlStandard,cbTestRules.Text,nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Close;
          ADOQuery.Open;
          ADOQuery.Locate('D_Value',FListB.Strings[cbTestRules.itemindex],[loCaseInsensitive]);
        except
          FDM.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          Exit;
        end;
      end;
    end;
  end
end;

function TfFormStockItem.CheckExt(nType, nField, nText: string): Boolean;
var
  nStr: string;
begin
  Result := False;
  nStr := 'select * from %s where D_Name=''%s'' and %s=''%s''';
  nStr := Format(nStr,[sTable_SysDict,nType, nField, nText]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount > 0 then
      Result := True
  end;
end;

procedure TfFormStockItem.BtnEditClick(Sender: TObject);
var
  nStr, nType: string;
begin
  case cxPG1.ActivePageIndex of
  0:begin
      EditStockNo.Text := Trim(EditStockNo.Text);
      if cbxType.ItemIndex = 0 then
        nType := sFlag_Dai
      else
        nType := sFlag_San;

      if not CheckExt(sFlag_StockItem,'D_ParamB',EditStockNo.Text) then
      begin
        ShowMessage('水泥['+editstockno.Text+']不存在.');
        EditStockNo.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := MakeSQLByStr([
                SF('D_Value', EditStockName.Text),
                SF('D_Memo', nType)
                ], sTable_SysDict, SF('D_ParamB', EditStockNo.Text), False);

          FDM.ADOConn.BeginTrans;
          FDM.ExecuteSQL(nStr);
          nStr := '修改水泥类型['+EditStockNo.Text+']';
          FDM.WriteSysLog(sFlag_StockItem,EditStockNo.Text,nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Refresh;
        except
          fdm.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          exit;
        end;
      end;
    end;
  1:begin
      if not CheckExt(sFlag_StockLimited,'D_Value',FListA.Strings[cbStock.itemindex]) then
      begin
        ShowMessage('水泥['+cbstock.Text+']日限额不存在.');
        cbStock.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := 'D_Value = '+''''+FListA.Strings[cbStock.ItemIndex]+''''+' and D_Name='+''''+sFlag_StockLimited+'''';
          nStr := MakeSQLByStr([
                SF('D_ParamA',EditValue.Value)
                ], sTable_SysDict, nStr, False);

          FDM.ADOConn.BeginTrans;
          FDM.ExecuteSQL(nStr);
          nStr := '修改水泥['+FListA.Strings[cbStock.ItemIndex]+']日发货量限额至：['+EditValue.Text+']吨';
          FDM.WriteSysLog(sFlag_StockLimited,FListA.Strings[cbStock.ItemIndex],nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Refresh;
        except
          fdm.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          exit;
        end;
      end;
    end;
  2:begin
      if not CheckExt(sFlag_CtrlStandard,'D_Value',FListB.Strings[cbCtrlStand.itemindex]) then
      begin
        ShowMessage('原材料[ '+cbCtrlStand.Text+' ]内控标准不存在.');
        cbCtrlStand.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := 'D_Value = '+''''+FListB.Strings[cbCtrlStand.ItemIndex]+''''+' and D_Name='+''''+sFlag_CtrlStandard+'''';
          nStr := MakeSQLByStr([
                SF('D_ParamA',EditCtrlStandValue.Value,sfVal),
                SF('D_ParamB',EditCtrlStandValue2.Text)
                ], sTable_SysDict, nStr, False);
          FDM.ADOConn.BeginTrans;
          FDM.ExecuteSQL(nStr);
          nStr := '修改原材料[ '+FListB.Strings[cbCtrlStand.ItemIndex]+' ]内控标准'+#13+'标准1:['
                  +EditCtrlStandValue.Text+'],标准2:['+EditCtrlStandValue2.Text+']';
          FDM.WriteSysLog(sFlag_StockLimited,FListB.Strings[cbCtrlStand.ItemIndex],nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Refresh;
        except
          fdm.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          exit;
        end;
      end;
    end;
  3:begin
      if not CheckExt(sFlag_TestRules,'D_Value',FListB.Strings[cbTestRules.itemindex]) then
      begin
        ShowMessage('原材料[ '+cbTestRules.Text+' ]检验规则不存在.');
        cbTestRules.SetFocus;
        Exit;
      end
      else
      begin
        try
          nStr := 'D_Value = '+''''+FListB.Strings[cbTestRules.ItemIndex]+''''+' and D_Name='+''''+sFlag_TestRules+'''';
          nStr := MakeSQLByStr([
                SF('D_ParamA',EditTestRulesValue.Value,sfVal)
                ], sTable_SysDict, nStr, False);
          FDM.ADOConn.BeginTrans;
          FDM.ExecuteSQL(nStr);
          nStr := '修改原材料[ '+FListB.Strings[cbTestRules.ItemIndex]+' ]检验规则为：['+EditTestRulesValue.text+']';
          FDM.WriteSysLog(sFlag_StockLimited,FListB.Strings[cbTestRules.ItemIndex],nStr);
          FDM.ADOConn.CommitTrans;
          ShowMsg(nStr+'成功.',sHint);
          ADOQuery.Refresh;
        except
          fdm.ADOConn.RollbackTrans;
          ShowMessage(nStr+'失败.');
          exit;
        end;
      end;
    end;
  end
end;

procedure TfFormStockItem.BtnDelClick(Sender: TObject);
var
  nStr, nStr2, nSQL: string;
begin
  case cxPG1.ActivePageIndex of
  0:begin
      if cxView1.DataController.GetSelectedCount < 1 then
      begin
        ShowMsg('请选择要删除的记录', sHint);
        Exit;
      end;

      nStr := ADOQuery.FieldByName('D_ParamB').AsString;
      nSQL := 'Select Count(*) From %s Where L_StockNo=''%s''';
      nSQL := Format(nSQL, [sTable_Bill, nStr]);

      with FDM.QueryTemp(nSQL) do
      if Fields[0].AsInteger > 0 then
      begin
        ShowMsg('该水泥类型不能删除', '已产生业务记录');
        Exit;
      end;

      nStr := ADOQuery.FieldByName('D_ParamB').AsString;
      if not QueryDlg('确定要删除编号为[ ' + nStr + ' ]的水泥类型吗', sAsk) then Exit;
      try
        fdm.ADOConn.BeginTrans;
        nSQL := 'Delete from %s where D_Name=''%s'' and D_ParamB=''%s''';
        nSQL := Format(nSQL,[sTable_SysDict,sFlag_StockItem,nStr]);
        FDM.ExecuteSQL(nSQL);
        nStr2 := '删除水泥类型['+nStr+']';
        FDM.WriteSysLog(sFlag_StockItem,nStr,nStr2);
        FDM.ADOConn.CommitTrans;

        ShowMsg(nStr2+'成功.',sHint);
        ADOQuery.Close;
        ADOQuery.Open;
      except
        FDM.ADOConn.RollbackTrans;
        ShowMessage(nStr2+'失败.');
        Exit;
      end;
    end;
  1:begin
      if cxGridDBTableView1.DataController.GetSelectedCount < 1 then
      begin
        ShowMsg('请选择要删除的记录', sHint);
        Exit;
      end;
      nStr := ADOQuery.FieldByName('D_Value').AsString;
      if not QueryDlg('确定要解除[ ' + nStr + ' ]的发货限额吗', sAsk) then Exit;

      try
        fdm.ADOConn.BeginTrans;

        nSQL := 'Delete from %s where D_Name=''%s'' and D_Value=''%s''';
        nSQL := Format(nSQL,[sTable_SysDict,sFlag_StockLimited,nStr]);
        FDM.ExecuteSQL(nSQL);
        nStr2 := '删除水泥['+nStr+']日限额';
        FDM.WriteSysLog(sFlag_StockItem,nStr,nStr2);
        FDM.ADOConn.CommitTrans;

        ShowMsg(nStr2+'成功.',sHint);
        ADOQuery.Close;
        ADOQuery.Open;
      except
        FDM.ADOConn.RollbackTrans;
        ShowMessage(nStr2+'失败.');
        Exit;
      end;
    end;
  2:begin
      if cxGridDBTableView2.DataController.GetSelectedCount < 1 then
      begin
        ShowMsg('请选择要删除的记录', sHint);
        Exit;
      end;
      nStr := ADOQuery.FieldByName('D_Value').AsString;
      if not QueryDlg('确定要解除[ ' + nStr + ' ]的内控标准吗', sAsk) then Exit;

      try
        fdm.ADOConn.BeginTrans;

        nSQL := 'Delete from %s where D_Name=''%s'' and D_Value=''%s''';
        nSQL := Format(nSQL,[sTable_SysDict,sFlag_CtrlStandard,nStr]);
        FDM.ExecuteSQL(nSQL);
        nStr2 := '删除原材料['+nStr+']内控标准';
        FDM.WriteSysLog(sFlag_CtrlStandard,nStr,nStr2);
        FDM.ADOConn.CommitTrans;

        ShowMsg(nStr2+'成功.',sHint);
        ADOQuery.Close;
        ADOQuery.Open;
      except
        FDM.ADOConn.RollbackTrans;
        ShowMessage(nStr2+'失败.');
        Exit;
      end;
    end;
  3:begin
      if cxGridDBTableView3.DataController.GetSelectedCount < 1 then
      begin
        ShowMsg('请选择要删除的记录', sHint);
        Exit;
      end;
      nStr := ADOQuery.FieldByName('D_Value').AsString;
      if not QueryDlg('确定要删除[ ' + nStr + ' ]的检验规则吗', sAsk) then Exit;

      try
        fdm.ADOConn.BeginTrans;
        nSQL := 'Delete from %s where D_Name=''%s'' and D_Value=''%s''';
        nSQL := Format(nSQL,[sTable_SysDict,sFlag_TestRules,nStr]);

        FDM.ExecuteSQL(nSQL);
        nStr2 := '删除原材料['+nStr+']内控标准';
        FDM.WriteSysLog(sFlag_TestRules,nStr,nStr2);
        FDM.ADOConn.CommitTrans;
        ShowMsg(nStr2+'成功.',sHint);
        ADOQuery.Close;
        ADOQuery.Open;
      except
        FDM.ADOConn.RollbackTrans;
        ShowMessage(nStr2+'失败.');
        Exit;
      end;
    end;
  end;
end;

procedure TfFormStockItem.cxView1CellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  case cxPG1.ActivePageIndex of
  0:begin
      EditStockNo.Text := ADOQuery.fieldbyname('D_ParamB').AsString;
      EditStockName.Text := ADOQuery.fieldbyname('D_Value').AsString;
      if ADOQuery.FieldByName('D_Memo').AsString = 'D' then
        cbxType.ItemIndex := 0
      else
        cbxType.ItemIndex := 1;
    end;
  1:begin
      cbStock.ItemIndex := FListA.IndexOf(ADOQuery.fieldbyname('D_Value').AsString);
      EditValue.Value := ADOQuery.fieldbyname('D_ParamA').AsFloat;
    end;
  2:begin
      cbCtrlStand.ItemIndex := FListB.IndexOf(ADOQuery.fieldbyname('D_Value').AsString);
      EditCtrlStandValue.Value := ADOQuery.fieldbyname('D_ParamA').AsFloat;
      EditCtrlStandValue2.Text := ADOQuery.fieldbyname('D_ParamB').AsString;
    end;
  3:begin
      cbTestRules.ItemIndex := FListB.IndexOf(ADOQuery.fieldbyname('D_Value').AsString);
      EditTestRulesValue.Value := ADOQuery.fieldbyname('D_ParamA').AsFloat;
    end;
  end;
end;

procedure TfFormStockItem.SelData(nParam: string);
var
  nStr: string;
begin
  nStr := 'select * from %s where D_Name=''%s''';
  nStr := Format(nStr,[sTable_SysDict,nParam]);
  with ADOQuery do
  begin
    Close;
    SQL.clear;
    sql.Add(nStr);
    Open;
  end;
end;

procedure TfFormStockItem.FormDestroy(Sender: TObject);
begin
  inherited;
  FListA.Free;
end;

procedure TfFormStockItem.cxPG1Change(Sender: TObject);
begin
  inherited;
  Initform(cxPG1.ActivePageIndex);
end;

procedure TfFormStockItem.Initform(i:Integer);
begin
  case i of
    0:begin
        SelData(sFlag_StockItem);
        with ADOQuery do
        begin
          First;
          cbStock.Properties.Items.Clear;
          FListA.Clear;
          while not Eof do
          begin
            cbStock.Properties.Items.Add(FieldByName('D_Value').AsString);
            FListA.Add(FieldByName('D_ParamB').AsString);
            Next;
          end;
        end;
      end;
    1:begin
        SelData(sFlag_StockLimited);
      end;
    2:begin
        SelData(sFlag_CtrlStandard);
      end;
    3:begin
        SelData(sFlag_TestRules);
      end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormStockItem, TfFormStockItem.FormID);
end.
