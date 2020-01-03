unit UFrameZKRechargeLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFrameZKRechargeLog = class(TfFrameNormal)
    editID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    editName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure editIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*基类函数*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
     class function FrameID: integer; override;
  end;

var
  fFrameZKRechargeLog: TfFrameZKRechargeLog;

implementation

{$R *.dfm}

uses
  USysConst, UFormDateFilter, USysDB, ULibFun, UMgrControl;

{ TfFrameZKRechargeLog }

class function TfFrameZKRechargeLog.FrameID: integer;
begin
  Result := cFI_FrameZKRechargeLog;
end;

function TfFrameZKRechargeLog.InitFormDataSQL(
  const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'select * from $T ';

  if nWhere = '' then
    Result := Result + ' where (R_Date>=''$ST'' and R_Date <''$End'')'
  else
    Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$T', sTable_ZKReChargeLog),
            MI('$ST', Date2Str(FStart)),MI('$End', Date2Str(Fend+1))]);
end;

procedure TfFrameZKRechargeLog.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameZKRechargeLog.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameZKRechargeLog.editIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'R_ZhiKa like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else
  if Sender = editName then
  begin
    editName.Text := Trim(editName.Text);
    if editName.Text = '' then Exit;

    FWhere := 'R_ZKName like ''%' + editName.Text + '%''';
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameZKRechargeLog, TfFrameZKRechargeLog.FrameID);

end.
