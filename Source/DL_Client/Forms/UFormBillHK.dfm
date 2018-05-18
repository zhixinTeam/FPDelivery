inherited fFormBillHK: TfFormBillHK
  Left = 607
  Top = 231
  ClientHeight = 465
  ClientWidth = 394
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 394
    Height = 465
    inherited BtnOK: TButton
      Left = 248
      Top = 432
      Caption = #30830#23450
      TabOrder = 13
    end
    inherited BtnExit: TButton
      Left = 318
      Top = 432
      TabOrder = 14
    end
    object EditLID: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 32
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 174
    end
    object EditZhiKa: TcxButtonEdit [3]
      Left = 81
      Top = 260
      HelpType = htKeyword
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditZhiKaPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 7
      Width = 165
    end
    object EditCusID: TcxTextEdit [4]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 403
    end
    object EditCusName: TcxTextEdit [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 403
    end
    object EditSID: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 3
      Width = 121
    end
    object EditSName: TcxTextEdit [7]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Width = 121
    end
    object EditValue: TcxTextEdit [8]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 121
    end
    object EditNCusID: TcxTextEdit [9]
      Left = 81
      Top = 335
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 10
      Width = 121
    end
    object EditNCusName: TcxTextEdit [10]
      Left = 81
      Top = 360
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 11
      Width = 121
    end
    object EditZName: TcxTextEdit [11]
      Left = 81
      Top = 285
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Width = 121
    end
    object EditProject: TcxTextEdit [12]
      Left = 81
      Top = 310
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 9
      Width = 121
    end
    object EditTruck: TcxTextEdit [13]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Width = 121
    end
    object EditMoney: TcxTextEdit [14]
      Left = 81
      Top = 385
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 12
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = #25552#36135#21333#20449#24687
        object dxLayout1Item4: TdxLayoutItem
          AlignHorz = ahClient
          CaptionOptions.Text = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #27700#27877#32534#21495':'
          Control = EditSID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          CaptionOptions.Text = #27700#27877#21517#31216':'
          Control = EditSName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          CaptionOptions.Text = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          CaptionOptions.Text = #25552' '#36135' '#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AlignVert = avClient
        CaptionOptions.Text = #24453#21512#21345#35746#21333
        ButtonOptions.Buttons = <>
        object dxLayout1Item6: TdxLayoutItem
          CaptionOptions.Text = #35746#21333#32534#21495':'
          Control = EditZhiKa
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          CaptionOptions.Text = #35746#21333#21517#31216':'
          Control = EditZName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          CaptionOptions.Text = #39033#30446#21517#31216':'
          Control = EditProject
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#32534#21495':'
          Control = EditNCusID
          ControlOptions.ShowBorder = False
        end
        object dxlytmNCusName: TdxLayoutItem
          CaptionOptions.Text = #23458#25143#21517#31216':'
          Control = EditNCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          CaptionOptions.Text = #21487#29992#37329#39069':'
          Control = EditMoney
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
