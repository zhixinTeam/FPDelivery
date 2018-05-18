inherited fFormAdjustCredit: TfFormAdjustCredit
  Left = 448
  Top = 225
  Caption = 'fFormAdjustCredit'
  ClientHeight = 375
  ClientWidth = 437
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 437
    Height = 375
    inherited BtnOK: TButton
      Left = 291
      Top = 342
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 361
      Top = 342
      TabOrder = 4
    end
    object editCusNo: TcxTextEdit [2]
      Left = 81
      Top = 36
      Enabled = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object editCusName: TcxTextEdit [3]
      Left = 81
      Top = 61
      Enabled = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      Width = 121
    end
    object editCredit: TcxTextEdit [4]
      Left = 81
      Top = 86
      Enabled = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 2
      Width = 121
    end
    object ListDetail: TcxListView [5]
      Left = 23
      Top = 168
      Width = 391
      Height = 72
      Align = alClient
      Columns = <
        item
          Caption = #23458#25143#32534#21495
          Width = 60
        end
        item
          Alignment = taCenter
          Caption = #23458#25143#21517#31216
          Width = 160
        end
        item
          Alignment = taCenter
          Caption = #35843#25320#37329#39069
          Width = 100
        end>
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      Style.BorderStyle = cbsFlat
      Style.LookAndFeel.Kind = lfUltraFlat
      StyleDisabled.BorderStyle = cbsUltraFlat
      StyleDisabled.Color = clMenuText
      StyleDisabled.LookAndFeel.Kind = lfUltraFlat
      StyleFocused.LookAndFeel.Kind = lfUltraFlat
      StyleHot.BorderStyle = cbsThick
      StyleHot.LookAndFeel.Kind = lfUltraFlat
      TabOrder = 6
      ViewStyle = vsReport
      OnClick = ListDetailClick
    end
    object editValue: TcxTextEdit [6]
      Left = 81
      Top = 143
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      OnExit = editValueExit
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#32534#21495':'
          Enabled = False
          Control = editCusNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#21517#31216':'
          Enabled = False
          Control = editCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = #20449#29992#37329#39069':'
          Enabled = False
          Control = editCredit
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group2: TdxLayoutGroup
        AlignVert = avClient
        CaptionOptions.Text = #35843#25320#26126#32454
        ButtonOptions.Buttons = <>
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = #35843#25320#37329#39069
          Control = editValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
