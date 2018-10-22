{*******************************************************************************
  作者: dmzn@163.com 2018-06-15
  描述: Frame基类
*******************************************************************************}
unit UFrameBlank;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  uniGUIFrame, USysBusiness, USysConst;

type
  TFrameBlankNeedIni = reference to function (): Boolean;
  //询问是否需要Ini配置

  TfFrameBlank = class(TUniFrame)
    procedure UniFrameCreate(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
  private
    { Private declarations }
  protected
    FDBType: TAdoConnectionType;
    {*数据连接*}
    procedure OnCreateFrame(const nIni: TIniFile;
      var nNeedIni: TFrameBlankNeedIni); virtual;
    procedure OnDestroyFrame(const nIni: TIniFile;
      var nNeedIni: TFrameBlankNeedIni); virtual;
    {*基类函数*}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfFrameBlank.UniFrameCreate(Sender: TObject);
var nIni: TIniFile;
    nNeedIni: TFrameBlankNeedIni;
begin
  FDBType := ctWork;
  //work mode

  nNeedIni := nil;
  OnCreateFrame(nil, nNeedIni);

  if Assigned(nNeedIni) and nNeedIni() then
  begin
    nIni := nil;
    try
      nIni := UserConfigFile;
      OnCreateFrame(nIni, nNeedIni);
      //子类处理
    finally
      nIni.Free;
    end;
  end;
end;

procedure TfFrameBlank.UniFrameDestroy(Sender: TObject);
var nIni: TIniFile;
    nNeedIni: TFrameBlankNeedIni;
begin
  nNeedIni := nil;
  OnDestroyFrame(nil, nNeedIni);

  if Assigned(nNeedIni) and nNeedIni() then
  begin
    nIni := nil;
    try
      nIni := UserConfigFile;
      OnDestroyFrame(nIni, nNeedIni);
      //子类处理
    finally
      nIni.Free;
    end;
  end;
end;

procedure TfFrameBlank.OnCreateFrame(const nIni: TIniFile;
  var nNeedIni: TFrameBlankNeedIni);
begin

end;

procedure TfFrameBlank.OnDestroyFrame(const nIni: TIniFile;
  var nNeedIni: TFrameBlankNeedIni);
begin

end;

end.
