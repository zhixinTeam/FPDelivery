program DLWeb;

uses
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  UFormMain in 'UFormMain.pas' {fFormMain: TUniForm},
  UFormBase in 'Forms\UFormBase.pas' {fFormBase: TUniForm},
  UFrameBlank in 'Forms\UFrameBlank.pas' {fFrameBlank: TUniFrame},
  UFrameBase in 'Forms\UFrameBase.pas' {fFrameBase: TUniFrame},
  USysModule in 'Common\USysModule.pas',
  USysBusiness in 'Common\USysBusiness.pas',
  USysConst in 'Common\USysConst.pas',
  USysFun in 'Common\USysFun.pas',
  USysRemote in 'Common\USysRemote.pas',
  UFrameMain in 'UFrameMain.pas' {fFrameMain: TUniFrame},
  UFormLogin in 'Forms\UFormLogin.pas' {fFormLogin: TUniLoginForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
