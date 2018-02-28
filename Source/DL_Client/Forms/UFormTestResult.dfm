inherited fFormTestResult: TfFormTestResult
  Left = 519
  Top = 261
  Height = 221
  Caption = #26816#39564#32467#26524#24405#20837
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 329
    Height = 183
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    object Label1: TLabel
      Left = 11
      Top = 121
      Width = 276
      Height = 24
      Caption = #27880#65306#33509#26679#21697#20026#29028#65292#21017#28909#20540#24405#20837#32467#26524'1'#65292#27700#20998#24405#20837#32467#26524'2'#13#10'    '#20854#20182#26679#21697#21482#38656#24405#20837#32467#26524'1'#21363#21487
      Color = clWindow
      ParentColor = False
      Transparent = True
    end
    object EditTestNo: TcxTextEdit
      Left = 87
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 219
    end
    object BtnExit: TButton
      Left = 243
      Top = 150
      Width = 75
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 4
    end
    object BtnOK: TButton
      Left = 163
      Top = 150
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 3
      OnClick = BtnOKClick
    end
    object EditResult1: TcxCurrencyEdit
      Left = 87
      Top = 61
      ParentFont = False
      Properties.DisplayFormat = '0.00;-0.00'
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditResult2: TcxCurrencyEdit
      Left = 87
      Top = 86
      ParentFont = False
      Properties.DisplayFormat = '0.00;-0.00'
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object dxLayoutGroup1: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      object dxLayoutGroup2: TdxLayoutGroup
        AlignHorz = ahClient
        AlignVert = avClient
        CaptionOptions.Text = #26816#39564#32467#26524
        ButtonOptions.Buttons = <>
        object dxLayoutItem1: TdxLayoutItem
          CaptionOptions.Text = #21270#39564#32534#21495':'
          Control = EditTestNo
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          CaptionOptions.Text = #32467'    '#26524'1:'
          Control = EditResult1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          CaptionOptions.Text = #32467'    '#26524'2:'
          Control = EditResult2
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Item3: TdxLayoutItem
        CaptionOptions.Visible = False
        Control = Label1
        ControlOptions.AutoColor = True
        ControlOptions.ShowBorder = False
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AlignHorz = ahRight
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item8: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button2'
          CaptionOptions.Visible = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AlignHorz = ahRight
          AlignVert = avBottom
          CaptionOptions.Text = 'Button1'
          CaptionOptions.Visible = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
