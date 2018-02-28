object FormMain: TFormMain
  Left = 130
  Top = 129
  Width = 578
  Height = 403
  Caption = 'FormMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 562
    Height = 316
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 0
    Top = 316
    Width = 562
    Height = 49
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Top = 8
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 5051
    OnExecute = IdTCPServer1Execute
    Left = 40
    Top = 8
  end
  object tmrGetStatus: TTimer
    Enabled = False
    OnTimer = tmrGetStatusTimer
    Left = 80
    Top = 8
  end
  object tmrStartGetStatus: TTimer
    Enabled = False
    OnTimer = tmrStartGetStatusTimer
    Left = 120
    Top = 8
  end
end
