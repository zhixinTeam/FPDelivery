unit UQryBills;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, system.inifiles,
  uniGUIBaseClasses, uniButton, uniBitBtn, uniLabel, uniEdit, uniCheckBox,
  uniFileUpload, Data.Win.ADODB;

type
  TfFrameQryBills = class(TfFrameBase)
    EditCus: TUniEdit;
    EditID: TUniEdit;
    Label1: TUniLabel;
    Label2: TUniLabel;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    checkStatus: TUniCheckBox;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure checkStatusClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
  end;

var
  fFrameQryBills: TfFrameQryBills;

implementation

{$R *.dfm}

uses
  UFormDateFilter, USysDB, ULibFun, MainModule, USysBusiness;

procedure TfFrameQryBills.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameQryBills.checkStatusClick(Sender: TObject);
begin
  InitFormData('');
end;

procedure TfFrameQryBills.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'L_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusName like ''%%%s%%'' Or L_CusPY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

function TfFrameQryBills.InitFormDataSQL(const nWhere: string): string;
begin
  with TDateTimeHelper do
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  //xxxxx

  Result := 'Select * From $Bill Where l_CusId in( select C_ID from S_Customer where C_Admin=''$User'')';
  //纸卡

  if nWhere = '' then
       Result := Result + ' and (L_Date>=''$ST'' and L_Date <''$End'')'
  else Result := Result + ' and (' + nWhere + ')';

  if checkStatus.Checked then
    Result :=  Result +' and (L_OutFact is null) ';


  with TStringHelper,TDateTimeHelper do
  Result := MacroValue(Result, [MI('$Bill', sTable_Bill), MI('$User', UniMainModule.FUserConfig.FUserID),
             MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameQryBills.OnCreateFrame(const nIni: TIniFile);
var
  nStr: string;
  nQuery: TADOQuery;
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);
  nStr := 'select C_ID from S_Customer where C_Admin=''%s''';
  nStr := Format(nStr,[UniMainModule.FUserConfig.FUserID]);
  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
      if RecordCount <1 then
        ShowMessage('尚未授权.');
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFrameQryBills.OnDateFilter(const nStart, nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

procedure TfFrameQryBills.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

initialization
  RegisterClass(TfFrameQryBills);
end.
