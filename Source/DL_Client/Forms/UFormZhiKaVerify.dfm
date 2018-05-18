inherited fFormZhiKaVerify: TfFormZhiKaVerify
  Left = 457
  Top = 240
  ClientHeight = 360
  ClientWidth = 352
  OnClick = FormClick
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 352
    Height = 360
    OptionsItem.AutoControlAreaAlignment = False
    inherited BtnOK: TButton
      Left = 206
      Top = 327
      Caption = #30830#23450
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 276
      Top = 327
      TabOrder = 8
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 330
      Height = 115
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 252
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditMoney: TcxTextEdit [3]
      Left = 234
      Top = 241
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Text = '0'
      Width = 121
    end
    object EditDesc: TcxMemo [4]
      Left = 81
      Top = 266
      ParentFont = False
      Properties.MaxLength = 200
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Height = 49
      Width = 284
    end
    object EditZID: TcxTextEdit [5]
      Left = 81
      Top = 159
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 121
    end
    object EditType: TcxComboBox [6]
      Left = 81
      Top = 241
      ParentFont = False
      Properties.MaxLength = 20
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      Width = 90
    end
    object cxLabel1: TcxLabel [7]
      Left = 304
      Top = 241
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 251
    end
    object EditInfo: TcxTextEdit [8]
      Left = 81
      Top = 216
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = #35746#21333#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          AlignVert = avClient
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = #35746#21333#32534#21495':'
          Control = EditZID
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        CaptionOptions.Text = #23457#26680#22238#27454
        ButtonOptions.Buttons = <>
        object dxLayout1Item9: TdxLayoutItem
          CaptionOptions.Text = #24453#32564#37329#39069':'
          Control = EditInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          CaptionOptions.Visible = False
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            CaptionOptions.Text = #20184#27454#26041#24335':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AlignHorz = ahClient
            CaptionOptions.Text = #32564#32435#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            CaptionOptions.Text = 'cxLabel1'
            CaptionOptions.Visible = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #22791#27880#20449#24687':'
          Control = EditDesc
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
