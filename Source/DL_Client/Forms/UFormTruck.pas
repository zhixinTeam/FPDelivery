{*******************************************************************************
  ����: dmzn@163.com 2014-11-25
  ����: ������������
*******************************************************************************}
unit UFormTruck;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, dxLayoutcxEditAdapters,
  dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormTruck = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditOwner: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    CheckVerify: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    CheckUserP: TcxCheckBox;
    CheckVip: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    CheckGPS: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditSBTare: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditCarModel: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    checkNoLimit: TcxCheckBox;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
    procedure EditCarModelPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    FTruckNum: string;
    FLoadId,FCarModel,FValue: TStringList;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;


implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormTruck.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormTruck.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '���� - ���';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '���� - �޸�';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTruck.FormID: integer;
begin
  Result := cFI_FormTrucks;
end;

procedure TfFormTruck.LoadFormData(const nID: string);
var nStr, nLoadId: string;
begin
  FLoadId := TStringList.Create;
  FCarModel := TStringList.Create;
  FValue := TStringList.Create;
  nStr := 'select * from %s ';
  nStr := Format(nStr,[sTable_LoadStandard]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      FLoadId.Add(FieldByName('S_No').AsString);
      //FCarModel.Add(FieldByName('S_CarModel').AsString);
      EditCarModel.Properties.Items.Add(FieldByName('S_CarModel').AsString);
      FValue.Add(FieldByName('S_Value').AsString);
      Next;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_Id=%s';
    nStr := Format(nStr, [sTable_Truck, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckVerify.Checked := True;
      CheckValid.Checked := True;
      Exit;
    end;

    FTruckNum := FieldByName('T_Truck').AsString; 
    EditTruck.Text := FieldByName('T_Truck').AsString;
    EditOwner.Text := FieldByName('T_Owner').AsString;
    EditPhone.Text := FieldByName('T_Phone').AsString;
    EditSBTare.Text := FieldByName('T_SBTare').AsString;
    nLoadId := FieldByName('T_LoadStand').AsString;
    
    CheckVerify.Checked := FieldByName('T_NoVerify').AsString = sFlag_No;
    CheckValid.Checked := FieldByName('T_Valid').AsString = sFlag_Yes;
    CheckUserP.Checked := FieldByName('T_PrePUse').AsString = sFlag_Yes;

    CheckVip.Checked   := FieldByName('T_VIPTruck').AsString = sFlag_TypeVIP;
    CheckGPS.Checked   := FieldByName('T_HasGPS').AsString = sFlag_Yes;

    checkNoLimit.Checked   := FieldByName('T_NoLimit').AsString = sFlag_Yes;
  end;
  if FLoadId.IndexOf(nLoadId) >=0 then
  begin
    EditCarModel.ItemIndex := FLoadId.IndexOf(nLoadId);
    EditValue.Text := FValue.Strings[FLoadId.IndexOf(nLoadId)];
  end;
end;

//Desc: ����
procedure TfFormTruck.BtnOKClick(Sender: TObject);
var nStr,nTruck,nU,nV,nP,nVip,nGps,nEvent,nNOLimit: string;
begin
  nTruck := UpperCase(Trim(EditTruck.Text));
  if nTruck = '' then
  begin
    ActiveControl := EditTruck;
    ShowMsg('�����복�ƺ���', sHint);
    Exit;
  end;

  if EditCarModel.ItemIndex = -1 then
  begin
    ActiveControl := EditCarModel;
    ShowMsg('��ѡ����',sHint);
    Exit;
  end;

  if FTruckID = '' then
  begin
    nStr := 'select * from %s where T_Truck=''%s''';
    nStr := Format(nStr,[sTable_Truck,nTruck]);
  end
  else
  begin
    nStr := 'select * from %s where T_Truck=''%s'' and T_Truck<>''%s''';
    nStr := Format(nStr,[sTable_Truck,nTruck, FTruckNum]);
  end;
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount > 0 then
    begin
      ActiveControl := EditTruck;
      ShowMsg('���ƺ����Ѿ����ڣ�', sHint);
      Exit;
    end;
  end;


  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if CheckVerify.Checked then
       nU := sFlag_No
  else nU := sFlag_Yes;

  if CheckUserP.Checked then
       nP := sFlag_Yes
  else nP := sFlag_No;

  if CheckVip.Checked then
       nVip:=sFlag_TypeVIP
  else nVip:=sFlag_TypeCommon;

  if CheckGPS.Checked then
       nGps := sFlag_Yes
  else nGps := sFlag_No;

  if checkNoLimit.Checked then
       nNOLimit := sFlag_Yes
  else nNOLimit := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_Id', FTruckID, sfVal);

  nStr := MakeSQLByStr([SF('T_Truck', nTruck),
          SF('T_Owner', EditOwner.Text),
          SF('T_Phone', EditPhone.Text),
          SF('T_NoVerify', nU),
          SF('T_Valid', nV),
          SF('T_PrePUse', nP),
          SF('T_VIPTruck', nVip),
          SF('T_HasGPS', nGps),
          SF('T_NoLimit', nNOLimit),
          SF('T_LoadStand', FLoadId.Strings[EditCarModel.ItemIndex]),
          SF('T_SBTare', StrToFloat(EditSBTare.Text),sfVal),
          SF('T_LastTime', sField_SQLServer_Now, sfVal)
          ], sTable_Truck, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  if FTruckID='' then
        nEvent := '���[ %s ]������Ϣ.'
  else  nEvent := '�޸�[ %s ]������Ϣ.';
  nEvent := Format(nEvent, [nTruck]);
  FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);


  ModalResult := mrOk;
  ShowMsg('������Ϣ����ɹ�', sHint);
end;

procedure TfFormTruck.EditCarModelPropertiesChange(Sender: TObject);
begin
  inherited;
  EditValue.Text := FValue.Strings[EditCarModel.Itemindex];
end;

initialization
  gControlManager.RegCtrl(TfFormTruck, TfFormTruck.FormID);
end.
