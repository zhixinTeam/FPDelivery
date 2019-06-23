inherited fFormTestResult: TfFormTestResult
  Left = 519
  Top = 261
  Width = 393
  Height = 322
  Caption = #29028#26816#39564#32467#26524#24405#20837
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 377
    Height = 284
    Align = alClient
    TabOrder = 0
    TabStop = False
    object EditTestNo: TcxTextEdit
      Left = 90
      Top = 29
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 259
    end
    object BtnExit: TButton
      Left = 289
      Top = 249
      Width = 75
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 5
    end
    object BtnOK: TButton
      Left = 208
      Top = 249
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 4
      OnClick = BtnOKClick
    end
    object EditResult1: TcxCurrencyEdit
      Left = 90
      Top = 55
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
      Left = 90
      Top = 81
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
      Left = 92
      Top = 109
      Width = 257
      Height = 119
      BorderStyle = bsNone
      TabOrder = 3
    end
    object dxLayoutGroup1: TdxLayoutGroup
      AutoAligns = []
      AlignHorz = ahClient
      AlignVert = avClient
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutGroup2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26816#39564#32467#26524
        object dxLayoutItem1: TdxLayoutItem
          Caption = #21270#39564#32534#21495':'
          Control = EditTestNo
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #28909'    '#20540':'
          Control = EditResult1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #27700'    '#20998':'
          Control = EditResult2
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791'     '#27880':'
          Control = Memo1
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaVertical]
        AlignHorz = ahRight
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item8: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AutoAligns = []
          AlignHorz = ahRight
          AlignVert = avBottom
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
