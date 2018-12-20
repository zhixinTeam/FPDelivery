unit UFrameQryHuaYan;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar,Data.Win.ADODB,
  uniGUIBaseClasses, System.IniFiles;

type
  TfFrameQryHuaYan = class(TfFrameBase)
  private
    { Private declarations }
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame(const nIni: TIniFile); override;
  end;

var
  fFrameQryHuaYan: TfFrameQryHuaYan;

implementation

{$R *.dfm}
{ TfFrameQryHuaYan }
uses
  UFormDateFilter, USysDB, ULibFun, MainModule, USysBusiness;

function TfFrameQryHuaYan.InitFormDataSQL(const nWhere: string): string;
var
  nStr: string;
begin
  nStr := 'select * from S_StockRecord where R_SerialNo in ( '+
          ' select distinct(L_HYDan) from S_Bill where L_CusID in '+
          ' (select C_ID from S_Customer where C_Admin=''%s''))';
  Result := Format(nStr,[UniMainModule.FUserConfig.FUserID]);
end;

procedure TfFrameQryHuaYan.OnCreateFrame(const nIni: TIniFile);
var
  nStr: string;
  nQuery: TADOQuery;
begin
  nStr := 'select C_ID from S_Customer where C_Admin=''%s''';
  nStr := Format(nStr,[UniMainModule.FUserConfig.FUserID]);
  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
      if RecordCount <1 then
      begin
        ShowMessage('ÉÐÎ´ÊÚÈ¨.');
        exit;
      end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFrameQryHuaYan);
end.
