unit UFrameTestResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, UMgrControl, dxLayoutcxEditAdapters, cxTextEdit,
  cxMaskEdit, cxButtonEdit, cxDropDownEdit, cxCalendar;

type
  TfFrameTestResult = class(TfFrameNormal)
    cxButtonEdit1: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxButtonEdit2: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    dateBegin: TcxDateEdit;
    dxLayout1Item3: TdxLayoutItem;
    dateEnd: TcxDateEdit;
    dxLayout1Item7: TdxLayoutItem;
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    procedure OnCreateFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameTestResult: TfFrameTestResult;

implementation

{$R *.dfm}

uses
  USysConst, USysDB, ULibFun, UFormDateFilter;

{ TfFrameTestResult }

class function TfFrameTestResult.FrameID: integer;
begin
  Result := cFI_FrameTestResult;
end;

function TfFrameTestResult.InitFormDataSQL(const nWhere: string): string;
begin
  dateBegin.Date := FStart;
  dateEnd.Date := FEnd;
  
  Result := 'select * from $SR ';

  if nWhere = '' then
       Result := Result + 'Where (D_InTime>=''$Start'' and D_InTime<''$End'')'
  else Result := Result + 'Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$SR', sTable_OrderDtl),
            MI('$Start', DateTime2Str(FStart)),
            MI('$End', DateTime2Str(FEnd + 1))]);
end;

procedure TfFrameTestResult.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

initialization
  gControlManager.RegCtrl(TfFrameTestResult, TfFrameTestResult.FrameID);
end.
