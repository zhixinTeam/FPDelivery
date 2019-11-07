object fFrameCounter: TfFrameCounter
  Left = 0
  Top = 0
  Width = 284
  Height = 353
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = #23435#20307
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object GroupBox1: TGroupBox
    Tag = 1
    Left = 10
    Top = 10
    Width = 265
    Height = 335
    Caption = #35013#36710'1'#36947
    TabOrder = 0
    object lbl_Info: TLabel
      Left = 15
      Top = 265
      Width = 45
      Height = 19
      Caption = 'lbl_Info'
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object LabelHint: TcxLabel
      Left = 2
      Top = 26
      Align = alTop
      AutoSize = False
      Caption = '0'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -48
      Style.Font.Name = #23435#20307
      Style.Font.Style = [fsBold]
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Properties.LabelStyle = cxlsRaised
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.Orientation = cxoBottom
      Height = 50
      Width = 261
      AnchorX = 133
      AnchorY = 51
    end
    object EditTruck: TLabeledEdit
      Left = 10
      Top = 100
      Width = 245
      Height = 37
      EditLabel.Width = 84
      EditLabel.Height = 24
      EditLabel.Caption = #36710#29260#21495':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = #23435#20307
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
    object EditDai: TLabeledEdit
      Left = 10
      Top = 165
      Width = 120
      Height = 37
      EditLabel.Width = 60
      EditLabel.Height = 24
      EditLabel.Caption = #34955#25968':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object BtnStart: TButton
      Left = 10
      Top = 284
      Width = 85
      Height = 42
      Caption = #21551#21160
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = BtnStartClick
    end
    object BtnClear: TButton
      Left = 170
      Top = 284
      Width = 85
      Height = 42
      Caption = #28165#38646
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = BtnClearClick
    end
    object EditTon: TLabeledEdit
      Left = 135
      Top = 165
      Width = 120
      Height = 37
      EditLabel.Width = 60
      EditLabel.Height = 24
      EditLabel.Caption = #21544#20301':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = #23435#20307
      Font.Style = []
      MaxLength = 5
      ParentFont = False
      TabOrder = 5
      OnChange = EditTonChange
      OnDblClick = EditTonDblClick
    end
    object BtnPause: TButton
      Left = 102
      Top = 284
      Width = 60
      Height = 42
      Caption = #26242#20572
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = BtnPauseClick
    end
    object EditCode: TLabeledEdit
      Left = 10
      Top = 228
      Width = 245
      Height = 37
      EditLabel.Width = 60
      EditLabel.Height = 24
      EditLabel.Caption = #21943#30721':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = #23435#20307
      Font.Style = []
      MaxLength = 200
      ParentFont = False
      TabOrder = 7
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 18
    Top = 42
  end
  object tmr_ClearJS: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tmr_ClearJSTimer
    Left = 53
    Top = 43
  end
end
