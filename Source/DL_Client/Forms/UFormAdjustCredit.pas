unit UFormAdjustCredit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters, cxContainer, cxEdit,
  ComCtrls, cxListView, cxTextEdit;

type
  TfFormAdjustCredit = class(TfFormNormal)
    dxLayout1Group2: TdxLayoutGroup;
    editCusNo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    editCusName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    editCredit: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListDetail: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    editValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ListDetailClick(Sender: TObject);
    procedure editValueExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCusID, FCusName, FCredit: string;
    procedure InitFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormAdjustCredit: TfFormAdjustCredit;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormBase, USysDB, UDataModule, ULibFun, USysGrid,
  IniFiles;

{ TfFormAdjustCredit }

class function TfFormAdjustCredit.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nP:PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else
    Exit;
  with TfFormAdjustCredit.Create(Application) do
  begin
    Fcusid := nP.FParamA;
    FCusName := nP.FParamB;
    FCredit := nP.FParamC;
    Caption := '信用调拨';
    ActiveControl := editValue;

    InitFormData('');
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormAdjustCredit.FormID: integer;
begin
  Result := cFI_FormAdjustCredit;
end;

procedure TfFormAdjustCredit.InitFormData(const nID: string);
var
  nStr: string;
begin
  editCusNo.Text := FCusID;
  editCusName.Text := FCusName;
  editCredit.Text := FCredit;

  nStr := 'Select * from %s where C_Parent=''%s''';
  nStr := Format(nStr,[sTable_Customer,FCusID]);
  with FDM.QueryTemp(nStr) do
  begin
    if recordcount < 1 then
    begin
      ShowDlg('客户 ['+FCusID+'] 没有下级客户.',sHint);
      Exit;
    end;
    First;
    while not Eof do
    begin
      with ListDetail.Items.Add do
      begin
        Caption := FieldByName('C_ID').AsString;
        SubItems.Add(FieldByName('C_Name').AsString);
        SubItems.Add('');
      end;
      Next;
    end;

  end;
end;

procedure TfFormAdjustCredit.BtnOKClick(Sender: TObject);
var
  I: Integer;
  nStr, nSQL, nDesc: string;
  nVal: Double;
  nList: TStrings;              
begin
  nVal := 0;
  nList := TStringList.Create;
  for I := 0 to ListDetail.Items.Count -1 do
  begin
    nStr := Trim(ListDetail.Items[i].SubItems[1]);
    if nStr <> '' then
    begin
      nSQL := 'Update %s set A_CreditLimit=A_CreditLimit+%s where A_CID=''%s''';
      nSQL := Format(nSQL,[sTable_CusAccount,nStr,ListDetail.Items[i].Caption]);
      nList.Add(nSQL);
      nDesc := nDesc + '客户:['+ListDetail.Items[i].Caption + ' - ' +
                  ListDetail.Items[i].SubItems[0] +']:['+ nStr + ']元 ';;
    end;
    nVal := nVal + StrToFloatDef(nStr,0);
  end;
  if nVal > StrToFloatDef(editCredit.Text,0) then
  begin
    ShowDlg('超出上级客户信用总额.',sHint);
    editValue.SetFocus;
    exit;
  end;
  if nList.Count >0  then
  begin
    nSQL := 'Update %s set A_CreditLimit=A_CreditLimit-%s where A_CID=''%s''';
    nSQL := Format(nSQL,[sTable_CusAccount,FloatToStr(nVal),editCusNo.Text]);
    nList.Add(nSQL);
  end;
  try
    FDM.ADOConn.BeginTrans;
    for i := 0 to nList.Count -1 do
      FDM.ExecuteSQL(nList[i]);

    FDM.WriteSysLog(sFlag_CreditItem,editCusNo.Text + ' - ' + editCusName.Text,'调拨信用,'+nDesc);

    fdm.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
    ShowDlg('调拨信用失败.',sError);
    Exit;
  end;
  ModalResult := mrOK;
end;

procedure TfFormAdjustCredit.ListDetailClick(Sender: TObject);
begin
  if ListDetail.ItemIndex < 0 then exit;
  editValue.Text := ListDetail.Selected.SubItems[1];
  editValue.SetFocus;
end;

procedure TfFormAdjustCredit.editValueExit(Sender: TObject);
begin
  if Trim(editValue.Text) = '' then Exit;
  if ListDetail.ItemIndex < 0 then exit;
  try
    StrToFloat(editValue.Text);
  except
    ShowDlg('请输入合法的调拨金额.',sHint);
    editValue.SetFocus;
    Exit;
  end;
  ListDetail.Selected.SubItems[1] := editValue.Text;
end;

procedure TfFormAdjustCredit.FormCreate(Sender: TObject);
var
  nIni: TIniFile;
begin
  inherited;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListDetail, nIni)
  finally
    nIni.Free;
  end;

end;

procedure TfFormAdjustCredit.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListDetail, nIni);
  finally
    nIni.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormAdjustCredit, TfFormAdjustCredit.FormID);
end.
