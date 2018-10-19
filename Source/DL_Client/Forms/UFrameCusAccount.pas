{*******************************************************************************
  ����: dmzn@163.com 2009-09-04
  ����: �ͻ��˻���ѯ
*******************************************************************************}
unit UFrameCusAccount;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter;

type
  TfFrameCusAccount = class(TfFrameNormal)
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    EditID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    procedure N3Click(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, USysBusiness, UFormBase;

class function TfFrameCusAccount.FrameID: integer;
begin
  Result := cFI_FrameCusAccountQuery;
end;

function TfFrameCusAccount.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select ca.*,cus.*,S_Name as C_SaleName,' +
            '(A_InitMoney + A_InMoney-A_OutMoney-A_Compensation-A_FreezeMoney) As A_YuE ' +
            'From $CA ca ' +
            ' Left Join $Cus cus On cus.C_ID=ca.A_CID ' +
            ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ';
  //xxxxx
  //left join (select Z_Customer,sum(Z_FixedMoney) as Z_FixedMoney from S_ZhiKa where Z_OnlyMoney='Y' and Z_InValid<>'Y' group by Z_Customer ) as fx on C_ID=fx.Z_Customer
  //zyw 2018-03-06 ����sql�����ͳ��ֽ������ռ�õĽ����ܻ��õ�

  if nWhere = '' then
       Result := Result + 'Where IsNull(C_XuNi, '''')<>''$Yes'''
  else Result := Result + 'Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$CA', sTable_CusAccount),
            MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
            MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: ִ�в�ѯ  
procedure TfFrameCusAccount.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := Format('C_ID like ''%%%s%%''', [EditID.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end
end;

//------------------------------------------------------------------------------
procedure TfFrameCusAccount.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N4.Visible := True;
  {$ELSE}
  N4.Visible := False;
  {$ENDIF}
  N6.Enabled := gSysParam.FIsAdmin;
end;

//Desc: ��ݲ˵�
procedure TfFrameCusAccount.N3Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('C_XuNi=''%s''', [sFlag_Yes]);
   20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameCusAccount.N4Click(Sender: TObject);
var nStr: string;
    nVal,nCredit: Double;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('A_CID').AsString;
    nVal := GetCustomerValidMoney(nStr, False, @nCredit);

    nStr := '�ͻ���ǰ���ý������:' + #13#10#13#10 +
            '*.�ͻ�����: %s ' + #13#10 +
            '*.�ʽ����: %.2f Ԫ' + #13#10 +
            '*.���ý��: %.2f Ԫ' + #13#10;
    nStr := Format(nStr, [SQLQuery.FieldByName('C_Name').AsString, nVal, nCredit]);
    ShowDlg(nStr, sHint);
  end;
end;

//Desc: У���ͻ��ʽ�
procedure TfFrameCusAccount.N6Click(Sender: TObject);
var nStr,nCID: string;
    nVal, nValAdj: Double;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;

  nCID := SQLQuery.FieldByName('A_CID').AsString;
  nValAdj := 0;

  {$IFDEF AdjustMoney}
  //��ƽ������У���ʽ������������ȥ�Ľ��
  nStr := 'select sum(A_value) from %s where A_OutCusId=''%s''';
  nStr := Format(nStr,[sTable_AdjustMoney,nCID]);
  with FDM.QuerySQL(nStr)do
  begin
    nValAdj := Fields[0].AsFloat;
  end;
  {$ENDIF}

  nStr := 'Select Sum(L_Money) from (' +
          '  select L_Value * L_Price as L_Money from %s' +
          '  where L_OutFact Is not Null And L_CusID = ''%s'') t';
  nStr := Format(nStr, [sTable_Bill, nCID]);

  with FDM.QuerySQL(nStr) do
  begin
    nVal := nValAdj + Float2Float(Fields[0].AsFloat, cPrecision, True);
    nStr := 'Update %s Set A_OutMoney=%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
    FDM.ExecuteSQL(nStr);
  end;

  nStr := 'Select Sum(L_Money) from (' +
          '  select L_Value * L_Price as L_Money from %s' +
          '  where L_OutFact Is Null And L_CusID = ''%s'') t';
  nStr := Format(nStr, [sTable_Bill, nCID]);

  with FDM.QuerySQL(nStr) do
  begin
    nVal := Float2Float(Fields[0].AsFloat, cPrecision, True);
    nStr := 'Update %s Set A_FreezeMoney=%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
    FDM.ExecuteSQL(nStr);
  end;

  InitFormData(FWhere);
  ShowMsg('У�����', sHint);
end;

procedure TfFrameCusAccount.N7Click(Sender: TObject);
var
  nCID, nStr: string;
  nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;

  if SQLQuery.FieldByName('a_CreditLimit').AsFloat <= 0 then
  begin
    ShowDlg('�޿������ý��',sHint);
    Exit;
  end;
  
  nCID := SQLQuery.FieldByName('A_CID').AsString;

  nStr := 'select * from %s where C_Parent=''%s''';
  nStr := Format(nStr,[sTable_Customer,nCID]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowDlg('�ÿͻ����¼��ͻ�,���ܵ�������.',sHint);
      Exit;
    end;

    nParam.FParamA := nCID;
    CreateBaseFormItem(cFI_FormAdjustCredit, PopedomItem, @nParam);

    if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;  
end;

initialization
  gControlManager.RegCtrl(TfFrameCusAccount, TfFrameCusAccount.FrameID);
end.