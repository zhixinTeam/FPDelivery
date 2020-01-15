unit UFrameFangHuiQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFrameFangHuiQuery = class(TfFrameNormal)
    dxLayout1Item1: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
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
  fFrameFangHuiQuery: TfFrameFangHuiQuery;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, USysConst, USysDB, USysBusiness, UDataModule,
  UFormDateFilter, UFormInvoiceK, UFormBase;

class function TfFrameFangHuiQuery.FrameID: integer;
begin
  Result := cFI_FrameQueryFH;
end;

procedure TfFrameFangHuiQuery.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameFangHuiQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//------------------------------------------------------------------------------
//Desc: 数据查询SQL
function TfFrameFangHuiQuery.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $FHLog Left Join S_Bill On L_ID=F_ID ' +
            'Where (F_Date>=''$S'' And F_Date<''$E'') ';

  if nWhere <> '' then
    Result := Result + 'And ( ' + nWhere + ' )';

  Result := MacroValue(Result, [MI('$FHLog', sTable_FHLog),
                                MI('$S', Date2Str(FStart)), MI('$E', Date2Str(FEnd+1))]);
  //xxxxx
end;

procedure TfFrameFangHuiQuery.EditDatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameFangHuiQuery.EditTruckPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then exit;

  FWhere := 'L_Truck like ''%' + EditTruck.Text + '%''';
  InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameFangHuiQuery, TfFrameFangHuiQuery.FrameID);


end.
