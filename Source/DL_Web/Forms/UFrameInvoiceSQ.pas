unit UFrameInvoiceSQ;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar,
  uniGUIBaseClasses, uniButton, uniBitBtn, uniEdit, uniLabel;

type
  TfFrameInvoiceSQ = class(TfFrameBase)
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFrameInvoiceSQ: TfFrameInvoiceSQ;

implementation

{$R *.dfm}

end.
