{*******************************************************************************
  作者: dmzn@163.com 2018-03-15
  描述: 主窗口,调度其它模块
*******************************************************************************}
unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms, Vcl.Controls,
  uniGUIForm;

type
  TfFormMain = class(TUniForm)
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure LoadFormConfig;
    procedure SaveFormConfig;
  public
    { Public declarations }
  end;

function fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  uniGUIVars, uniGUIFrame, MainModule, UManagerGroup, System.IniFiles, USysDB,
  USysBusiness, USysConst;

function fFormMain: TfFormMain;
begin
  Result := TfFormMain(UniMainModule.GetFormInstance(TfFormMain));
end;

procedure TfFormMain.LoadFormConfig;
var nMethod,nName: string;
    nFrame: TUniFrame;
    nClass: TClass;
begin
  UniMainModule.FMainForm := Self;
  nName := 'TfFrameMain'; //main default
  nMethod := GetUserFixParameter('method');

  if CompareText(nMethod, sMethod_FactoryStatus) = 0 then
  begin
    nName := 'TfFrameFactoryStatus';
  end;

  if nName <> '' then
  begin
    nClass := GetClass(nName);
    if not Assigned(nClass) then
      raise Exception.Create(Format('类[ %s ]不存在', [nName]));
    //xxxxx

    nFrame := TUniFrameClass(nClass).Create(Self);
    nFrame.Parent := Self;
    nFrame.Align := alClient;
  end;
end;

procedure TfFormMain.SaveFormConfig;
begin

end;

procedure TfFormMain.UniFormCreate(Sender: TObject);
begin
  LoadFormConfig;
end;

procedure TfFormMain.UniFormDestroy(Sender: TObject);
begin
  SaveFormConfig;
end;

initialization
  RegisterAppFormClass(TfFormMain);
end.
