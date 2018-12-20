unit UFrameTouSu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, system.inifiles,
  uniGUIBaseClasses, uniButton, uniBitBtn, uniEdit, uniLabel, Data.Win.ADODB,
  Vcl.Menus, uniMainMenu;

type
  TfFrameTouSu = class(TfFrameBase)
    Label1: TUniLabel;
    EditID: TUniEdit;
    Label2: TUniLabel;
    EditTitle: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    btnSH: TUniToolButton;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure btnSHClick(Sender: TObject);
    procedure DBGridMainDblClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    FIsCus:Boolean;
    procedure OnDateFilter(const nStart,nEnd: TDate);
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
  end;

var
  fFrameTouSu: TfFrameTouSu;

implementation

{$R *.dfm}

{ TfFrameTouSu }

uses
  UFormDateFilter, USysDB, ULibFun, MainModule, USysBusiness, uniGUIForm,
  USysConst, UFormBase;

procedure TfFrameTouSu.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
    //nIsCus: Boolean;
begin
  //nIsCus := UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
  if not FIsCus then
  begin
    ShowMessage('无投诉权限.');
    exit;
  end;

  nForm := SystemGetForm('TfFormTouSu', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameTouSu.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameTouSu.BtnDelClick(Sender: TObject);
var
  //nIsCus:Boolean;
  nStr, nId:string;
  nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  //nIsCus := UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
  nStr := ClientDS.FieldByName('T_Status').AsString;
  if (nStr = sFlag_TSS) and FIsCus then      //N：新的 S：已审核
  begin
    ShowMessage('该投诉内容已经批复,无法删除.');
    Exit;
  end;

  nId := ClientDS.FieldByName('R_Id').AsString;
  try
    nQuery := nil;

    nStr := 'delete from %s where R_Id=''%s''';
    nStr := Format(nStr,[sTable_TouSu, nId]);
    DBExecute(nStr, nQuery);
  finally
    ReleaseDBQuery(nQuery);
  end;

  InitFormData(FWhere);
end;

procedure TfFrameTouSu.BtnEditClick(Sender: TObject);
var
  //nIsCus:Boolean;
  nStr:string;
  nForm: TUniForm;
  nParam: TFormCommandParam;
begin
  //nIsCus := UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
  if not FIsCus then
  begin
    ShowMessage('无投诉权限.');
    exit;
  end;

  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nStr := ClientDS.FieldByName('T_Status').AsString;
  if nStr = sFlag_TSS then      //N：新的 S：已审核
  begin
    ShowMessage('该投诉内容已经批复,无法修改.');
    Exit;
  end;

  nForm := SystemGetForm('TfFormTouSu', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameTouSu.btnSHClick(Sender: TObject);
var
  nForm: TUniForm;
  nParam: TFormCommandParam;
begin
  if FIsCus then
  begin
    ShowMessage('没有审核权限');
    Exit;
  end;

  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

//  if ClientDS.FieldByName('T_Status').AsString = sFlag_TSS then      //N：新的 S：已审核
//  begin
//    ShowMessage('该投诉内容已经批复,不能重复审核.');
//    Exit;
//  end;

  nForm := SystemGetForm('TfFormTouSu', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_ShenHe;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameTouSu.DBGridMainDblClick(Sender: TObject);
var
  nForm: TUniForm;
  nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then Exit;
  nForm := SystemGetForm('TfFormTouSu', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_ViewData;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal;
end;

procedure TfFrameTouSu.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'T_TSMan like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditTitle then
  begin
    EditTitle.Text := Trim(EditTitle.Text);
    if EditTitle.Text = '' then Exit;

    FWhere := 'T_Title like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTitle.Text]);
    InitFormData(FWhere);
  end;
end;

function TfFrameTouSu.InitFormDataSQL(const nWhere: string): string;
var
  nStr: string;
begin
  //所属用户组
  if FIsCus then
    nStr := 'select * from $Bill where T_TSMan=''$User'''
  else
    nStr := 'select * from $Bill';


  with TDateTimeHelper do
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  //xxxxx

  if nWhere = '' then
  begin
    if FIsCus then
      nStr := nStr + ' and (T_TSTime>=''$ST'' and T_TSTime <''$End'')'
    else
      nStr := nStr + ' where (T_TSTime>=''$ST'' and T_TSTime <''$End'')'
  end
  else
  begin
    if FIsCus then
      nStr := nStr + ' and (' + nWhere + ')'
    else
      nStr := nStr + ' where (' + nWhere + ')';
  end;

  with TStringHelper,TDateTimeHelper do
  Result := MacroValue(nStr, [MI('$Bill', sTable_TouSu), MI('$User', UniMainModule.FUserConfig.FUserID),
             MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
end;

procedure TfFrameTouSu.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);
  FIsCus :=  UniMainModule.FUserConfig.FGroupID = sFlag_WebCusGroup;
end;

procedure TfFrameTouSu.OnDateFilter(const nStart, nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

procedure TfFrameTouSu.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;


initialization
  RegisterClass(TfFrameTouSu);
end.
