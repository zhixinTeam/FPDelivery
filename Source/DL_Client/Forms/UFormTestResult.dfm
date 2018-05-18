inherited fFormTestResult: TfFormTestResult
  Left = 519
  Top = 261
  Width = 379
  Height = 316
  Caption = #29028#26816#39564#32467#26524#24405#20837
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 363
    Height = 278
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    object EditTestNo: TcxTextEdit
      Left = 81
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 202
    end
    object BtnExit: TButton
      Left = 277
      Top = 245
      Width = 75
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 5
    end
    object BtnOK: TButton
      Left = 197
      Top = 245
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 4
      OnClick = BtnOKClick
    end
    object EditResult1: TcxCurrencyEdit
      Left = 81
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
      Left = 81
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
    object Memo1: TMemo
      Left = 82
      Top = 112
      Width = 257
      Height = 119
      BorderStyle = bsNone
      TabOrder = 3
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
          CaptionOptions.Text = #28909'    '#20540':'
          Control = EditResult1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          CaptionOptions.Text = #27700'    '#20998':'
          Control = EditResult2
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          CaptionOptions.Text = #22791'    '#27880':'
          Control = Memo1
        end
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
