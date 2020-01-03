unit UFrameCusInMoneyException;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin;

type
  TfFrameCusInMoneyExceptio = class(TfFrameNormal)
  private
    function InitFormDataSQL(const nWhere: string): string; override;
  public
    class function FrameID: integer; override;
  end;

var
  fFrameCusInMoneyExceptio: TfFrameCusInMoneyExceptio;

implementation

{$R *.dfm}


uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameCusInMoneyExceptio.FrameID: integer;
begin
  Result := cFI_FrameCusInMoneyExceptio;
end;

//Desc: Êý¾Ý²éÑ¯SQL
function TfFrameCusInMoneyExceptio.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  Result:= ' Select A_InMoney, IsNull(M_Money, 0) M_Money, A_InMoney-IsNull(M_Money, 0) CMoney, * From %s Left Join S_Customer On A_CID=C_ID '+
           ' Left Join ( '+
              ' Select M_CusID, SUM( ISNULL(M_Money,0)) M_Money From %s Group by M_CusID ) x On A_CID=x.M_CusID '+
              ' Where  A_InMoney- IsNull(M_Money, 0)<>0  ';
  Result:= Format(Result, [sTable_CusAccount, sTable_InOutMoney]);
end;


initialization
  gControlManager.RegCtrl(TfFrameCusInMoneyExceptio, TfFrameCusInMoneyExceptio.FrameID);


end.
