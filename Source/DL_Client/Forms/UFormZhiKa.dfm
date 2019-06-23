inherited fFormZhiKa: TfFormZhiKa
  Left = 488
  Top = 166
  Width = 476
  Height = 501
  BorderStyle = bsSizeable
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 460
    Height = 463
    inherited BtnOK: TButton
      Left = 314
      Top = 430
      TabOrder = 21
    end
    inherited BtnExit: TButton
      Left = 384
      Top = 430
      TabOrder = 22
    end
    object ListDetail: TcxListView [2]
      Left = 23
      Top = 269
      Width = 400
      Height = 149
      Checkboxes = True
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 120
        end
        item
          Caption = #21333#20215'('#20803'/'#21544')'
          Width = 100
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 100
        end>
      HideSelection = False
      ParentFont = False
      PopupMenu = PMenu1
      ReadOnly = True
      RowSelect = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 15
      ViewStyle = vsReport
      OnClick = ListDetailClick
    end
    object EditStock: TcxTextEdit [3]
      Left = 81
      Top = 398
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 16
      Width = 149
    end
    object EditPrice: TcxTextEdit [4]
      Left = 229
      Top = 398
      ParentFont = False
      Properties.OnEditValueChanged = EditPricePropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 17
      Width = 56
    end
    object EditValue: TcxTextEdit [5]
      Left = 336
      Top = 398
      ParentFont = False
      Properties.OnEditValueChanged = EditPricePropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 18
      Width = 45
    end
    object EditCID: TcxButtonEdit [6]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnExit = EditCIDExit
      OnKeyPress = EditCIDKeyPress
      Width = 121
    end
    object EditPName: TcxTextEdit [7]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 121
    end
    object EditSMan: TcxComboBox [8]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditSManPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      Width = 121
    end
    object EditCustom: TcxComboBox [9]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 4
      OnKeyPress = EditCustomKeyPress
      Width = 121
    end
    object EditLading: TcxComboBox [10]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      Properties.MaxLength = 20
      Properties.OnChange = EditLadingPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 5
      Width = 125
    end
    object EditPayment: TcxComboBox [11]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 20
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 7
      Width = 125
    end
    object EditMoney: TcxTextEdit [12]
      Left = 269
      Top = 161
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Text = '0'
      Width = 121
    end
    object cxLabel2: TcxLabel [13]
      Left = 417
      Top = 161
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 20
      AnchorY = 171
    end
    object Check1: TcxCheckBox [14]
      Left = 11
      Top = 430
      Caption = #23436#25104#21518#25171#24320#38480#25552#31383#21475
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 20
      Transparent = True
      Width = 142
    end
    object EditDays: TcxDateEdit [15]
      Left = 269
      Top = 136
      ParentFont = False
      Properties.SaveTime = False
      Properties.ShowTime = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 6
      Width = 121
    end
    object EditName: TcxTextEdit [16]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 125
    end
    object EditFPType: TcxComboBox [17]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.Items.Strings = (
        '1'#12289#19968#31080#21046
        '2'#12289#20004#31080#21046)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 10
      Text = '1'#12289#19968#31080#21046
      Width = 125
    end
    object EditFreight: TcxCurrencyEdit [18]
      Left = 269
      Top = 186
      ParentFont = False
      Properties.DisplayFormat = #65509',0.00;'#65509'-,0.00'
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 11
      Width = 128
    end
    object cxLabel1: TcxLabel [19]
      Left = 402
      Top = 186
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Style.HotTrack = False
      Transparent = True
      Height = 19
      Width = 19
    end
    object ckPrintHy: TcxCheckBox [20]
      Left = 23
      Top = 211
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 13
      Transparent = True
      Width = 180
    end
    object ckSeal: TcxCheckBox [21]
      Left = 208
      Top = 211
      Caption = #24405#20837#23553#31614#21495
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 14
      Transparent = True
      Width = 195
    end
    object btnBackCash: TButton [22]
      Left = 386
      Top = 398
      Width = 51
      Height = 20
      Caption = #35774#32622#36820#29616
      Enabled = False
      TabOrder = 19
      OnClick = btnBackCashClick
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item13: TdxLayoutItem
            Caption = #35746#21333#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21512#21516#32534#21495':'
            Control = EditCID
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #39033#30446#21517#31216':'
          Control = EditPName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #19994#21153#20154#21592':'
          Control = EditSMan
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCustom
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item11: TdxLayoutItem
            Caption = #25552#36135#26041#24335':'
            Control = EditLading
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item18: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#26102#38271':'
            Control = EditDays
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #20184#27454#26041#24335':'
            Control = EditPayment
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item15: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #39044#20184#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item16: TdxLayoutItem
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item14: TdxLayoutItem
            Caption = #36816#36153#31080#21046':'
            Control = EditFPType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item19: TdxLayoutItem
            Caption = #27599#21544#36816#36153':'
            Control = EditFreight
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item20: TdxLayoutItem
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group7: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item21: TdxLayoutItem
            Control = ckPrintHy
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item22: TdxLayoutItem
            Control = ckSeal
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #21150#29702#26126#32454
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #31867#22411':'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = #21333#20215':'
            Control = EditPrice
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            Caption = #21150#29702#37327':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group8: TdxLayoutGroup
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item23: TdxLayoutItem
              Enabled = False
              Control = btnBackCash
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item17: TdxLayoutItem [0]
          Control = Check1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 36
    Top = 268
    object N1: TMenuItem
      Tag = 10
      Caption = #20840#37096#36873#20013
      OnClick = N3Click
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #20840#37096#21462#28040
      OnClick = N3Click
    end
    object N3: TMenuItem
      Tag = 30
      Caption = #21453#30456#36873#25321
      OnClick = N3Click
    end
  end
end
