unit UFrameQryMoney;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, Data.Win.ADODB,
  uniGUIBaseClasses;

type
  TfFrameQryMoney = class(TfFrameBase)
  private
    { Private declarations }
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
  end;

var
  fFrameQryMoney: TfFrameQryMoney;

implementation

{$R *.dfm}

uses
  UFormDateFilter, USysDB, ULibFun, MainModule, USysBusiness;


{ TfFrameQryMoney }

function TfFrameQryMoney.InitFormDataSQL(const nWhere: string): string;
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
        Exit;
      end;

  finally
    ReleaseDBQuery(nQuery);
  end;

  Result := 'select b.C_Name,A_InitMoney+A_InMoney-A_OutMoney-A_Compensation as yue,'+
            'A_FreezeMoney,A_CreditLimit from Sys_CustomerAccount '+
            'a left join S_Customer b on a.A_CID=b.C_ID where A_CID in '+
            '( select C_ID from S_Customer where C_Admin=''%s'')';
  Result := Format(Result,[UniMainModule.FUserConfig.FUserID]);
end;

initialization
  RegisterClass(TfFrameQryMoney);
end.
