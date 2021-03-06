{*******************************************************************************
  作者: dmzn@163.com 2009-6-15
  描述: 办理纸卡
*******************************************************************************}
unit UFrameZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, Dialogs,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  dxLayoutcxEditAdapters, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin;

type
  TfFrameZhiKa = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditSale: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N13Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*基类函数*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
    procedure RechargeLog(const nZhiKa,nZKName,nMemo: string;const nValue:string);
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, USysConst, USysDB, USysBusiness,
  UFormDateFilter, UFormInputbox;

//------------------------------------------------------------------------------
class function TfFrameZhiKa.FrameID: integer;
begin
  Result := cFI_FrameZhiKa;
end;

procedure TfFrameZhiKa.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameZhiKa.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameZhiKa.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  
  Result := 'Select zk.*,sm.S_Name,sm.S_PY,cus.C_Name,cus.C_PY From $ZK zk ' +
            ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
            ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer';
  //纸卡

  if nWhere = '' then
       Result := Result + ' Where (zk.Z_Date>=''$ST'' and zk.Z_Date <''$End'')' +
                 ' and (Z_InValid Is Null or Z_InValid<>''$Yes'')'
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$ZK', sTable_ZhiKa), 
             MI('$Con', sTable_SaleContract), MI('$SM', sTable_Salesman),
             MI('$Cus', sTable_Customer), MI('$Yes', sFlag_Yes),
             MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd +1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 添加
procedure TfFrameZhiKa.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormZhiKa, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameZhiKa.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;        

  nParam.FParamA := SQLQuery.FieldByName('Z_ID').AsString;
  nParam.FCommand := cCmd_EditData;
  CreateBaseFormItem(cFI_FormZhiKa, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFrameZhiKa.BtnDelClick(Sender: TObject);
var nStr,nID, nReson: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nID := SQLQuery.FieldByName('Z_ID').AsString;
  nStr := 'Select Count(*) From %s Where L_ZhiKa=''%s''';
  nStr := Format(nStr, [sTable_Bill, nID]);

  with FDM.QueryTemp(nStr) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该订单不能删除', '已提货'); Exit;
  end;

  nStr := Format('确定要删除编号为[ %s ]的订单吗?', [nID]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if not ShowInputBox('请输入删除原因:', sHint, nReson) then Exit;
  if nReson = '' then
  begin
    ShowDlg('删除原因不能为空.',sHint);
    Exit;
  end;

  FDM.ADOConn.BeginTrans;
  try
    DeleteZhiKa(nID);

    FDM.WriteSysLog(sFlag_ZhiKaItem, nID, '删除订单:[ '+ nID +' ], 原因:' + nReson);

    FDM.ADOConn.CommitTrans;

    InitFormData(FWhere);
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

//Desc: 执行查询
procedure TfFrameZhiKa.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'Z_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCID then
  begin
    EditCID.Text := Trim(EditCID.Text);
    if EditCID.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCID.Text, EditCID.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditSale then
  begin
    EditSale.Text := Trim(EditSale.Text);
    if EditSale.Text = '' then Exit;

    FWhere := 'S_Name like ''%%%s%%'' Or S_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditSale.Text, EditSale.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 查看内容
procedure TfFrameZhiKa.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('Z_ID').AsString;
    CreateBaseFormItem(cFI_FormZhiKa, PopedomItem, @nParam);
  end;
end;

//Desc: 日期筛选
procedure TfFrameZhiKa.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 打印纸卡
procedure TfFrameZhiKa.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('Z_ID').AsString;
    PrintZhiKaReport(nStr, False);
  end;
end;

//Desc: 快捷查询
procedure TfFrameZhiKa.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('Z_Freeze=''%s''', [sFlag_Yes]);
    20: FWhere := Format('Z_InValid=''%s''', [sFlag_Yes]);
    30: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

//Desc: 冻结
procedure TfFrameZhiKa.N8Click(Sender: TObject);
var nStr,nFlag,nMsg: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    case TComponent(Sender).Tag of
     10:
       if SQLQuery.FieldByName('Z_Freeze').AsString <> sFlag_Yes then
       begin
         nFlag := sFlag_Yes; nMsg := '订单已成功冻结';
       end else Exit;
     20:
       if SQLQuery.FieldByName('Z_Freeze').AsString = sFlag_Yes then
       begin
         nFlag := sFlag_No; nMsg := '冻结已成功解除';
       end else Exit;
    end;

    nStr := 'Update %s Set Z_Freeze=''%s'' Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nFlag, SQLQuery.FieldByName('Z_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg(nMsg, sHint);
  end;
end;

//Desc: 设置纸卡限提金额
procedure TfFrameZhiKa.N10Click(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;
  if not BtnEdit.Enabled then
  begin
    ShowMsg('您没有该权限', sHint); Exit;
  end;

  nP.FCommand := cCmd_EditData;
  nP.FParamA := SQLQuery.FieldByName('Z_ID').AsString;
  CreateBaseFormItem(cFI_FormZhiKaFixMoney, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

procedure TfFrameZhiKa.N11Click(Sender: TObject);
var
  nStr, nID, nStrMoney, nZKName, nMemo, nCusId: string;
  nMOney, nVal, nZKFrozen: Double;
begin
  if SQLQuery.FieldByName('Z_OnlyMoney').AsString <> sFlag_Yes then
  begin
    ShowDlg('此纸卡没有限提,不能充值.',sHint);
    exit;
  end;

  nStrMoney := '';
  if not ShowInputBox('请输入本次充值金额:', sHint, nStrMoney) then Exit;

  try
    nMOney := StrToFloat(nStrMoney);
  except
    ShowDlg('充值失败,请输入合法的金额.',sHint);
    Exit;
  end;

  nCusId := SQLQuery.FieldByName('Z_Customer').AsString;
  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nCusId]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount < 0 then
    begin
      ShowMsg('客户['+nCusId+']不存在.',sHint);
      Exit;
    end;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
  end;

  nStr := 'select SUM(Z_FixedMoney)as frozen from %s where Z_InValid<>''%s'' or '+
          ' Z_InValid is null and Z_OnlyMoney=''%s'' and Z_Customer=''%s''' ;
  nStr := Format(nStr,[sTable_ZhiKa,sFlag_Yes,sFlag_Yes,nCusId]);
  with FDM.QueryTemp(nStr) do
  begin
    nZKFrozen := fieldbyname('frozen').AsFloat;
  end;

  if nMOney > nVal - nZKFrozen then
  begin
    showmessage('充值金额超过客户可用金额.');
    exit;
  end;
  
  FDM.ADOConn.BeginTrans;
  try
    nID := SQLQuery.FieldByName('Z_ID').AsString;
    nZKName := SQLQuery.FieldByName('Z_Name').AsString;
    nMemo := '为纸卡[ '+ nID +' ]充值, 金额:' + nStrMoney;

    nStr := 'Update %s set Z_FixedMoney = Z_FixedMoney+%s where Z_ID=''%s''';
    nStr := Format(nStr,[sTable_ZhiKa, nStrMoney, nID]);
    FDM.ExecuteSQL(nStr);

    //写入充值记录
    RechargeLog(nID,nZKName,nMemo,nStrMoney);

    FDM.WriteSysLog(sFlag_ZhiKaItem, nID, nMemo);
    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('充值成功.',sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('充值失败.',sHint);
  end;
end;

procedure TfFrameZhiKa.RechargeLog(const nZhiKa, nZKName, nMemo: string;
  const nValue: string);
var nStr,nSQL: string;
begin
  nSQL := 'Insert Into $T(R_Date,R_Man,R_ZhiKa,R_ZKName,R_memo,R_Value) ' +
          'Values(''$D'',''$M'',''$ZK'',''$ZName'',''$Memo'',''$V'')';
  nSQL := MacroValue(nSQL, [MI('$T', sTable_ZKReChargeLog), MI('$D', DateTime2Str(Now)),
                            MI('$ZK', nZhiKa), MI('$ZName', nZKName),
                            MI('$Memo', nMemo), MI('$V', nValue)]);

  nSQL := MacroValue(nSQL, [MI('$M', gSysParam.FUserName)]);
  FDM.ExecuteSQL(nSQL);
end;

procedure TfFrameZhiKa.PMenu1Popup(Sender: TObject);
begin
  N13.Enabled := gSysParam.FIsAdmin;
end;

procedure TfFrameZhiKa.N13Click(Sender: TObject);
var
  nStr, nID:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要置为无效的订单', sHint); Exit;
  end;

  nID := SQLQuery.FieldByName('Z_ID').AsString;

  nStr := '确定将订单['+nID+']设为无效订单吗，一旦设为无效将不能再次启用.';
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'update %s set Z_InValid=''%s'' where Z_Id=''%s''';
  nStr := Format(nStr,[sTable_ZhiKa,sFlag_Yes,nID]);
  FDM.ExecuteSQL(nStr);
  InitFormData(FWhere);
  ShowMsg('操作成功.', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFrameZhiKa, TfFrameZhiKa.FrameID);
end.
