inherited fFormTestRecOther: TfFormTestRecOther
  Left = 432
  Top = 279
  Caption = #20854#20182#21407#26448#26009#26816#39564#32467#26524#24405#20837
  ClientHeight = 307
  ClientWidth = 368
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 368
    Height = 307
    inherited BtnOK: TButton
      Left = 222
      Top = 274
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 292
      Top = 274
      TabOrder = 7
    end
    object cbStockNo: TcxComboBox [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.OnChange = cbStockNoPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 121
    end
    object editStockName: TcxTextEdit [3]
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
    object editDateBegin: TcxDateEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      Width = 121
    end
    object editDateEnd: TcxDateEdit [5]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      Width = 121
    end
    object editResult: TcxCurrencyEdit [6]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.DisplayFormat = ',0.00;-,0.00'
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 121
    end
    object Memo1: TMemo [7]
      Left = 82
      Top = 162
      Width = 305
      Height = 85
      BorderStyle = bsNone
      TabOrder = 5
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #29289#26009#32534#21495':'
          Control = cbStockNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #29289#26009#21517#31216':'
          Enabled = False
          Control = editStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          CaptionOptions.Text = #36215#22987#26102#38388':'
          Control = editDateBegin
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = #32467#26463#26102#38388':'
          Control = editDateEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          CaptionOptions.Text = #26816#39564#32467#26524':'
          Control = editResult
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          CaptionOptions.Text = #22791'    '#27880':'
          Control = Memo1
        end
      end
    end
  end
end
