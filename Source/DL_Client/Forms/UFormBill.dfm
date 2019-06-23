inherited fFormBill: TfFormBill
  Left = 439
  Top = 57
  ClientHeight = 583
  ClientWidth = 419
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 419
    Height = 583
    inherited BtnOK: TButton
      Left = 273
      Top = 550
      Caption = #24320#21333
      TabOrder = 17
    end
    inherited BtnExit: TButton
      Left = 343
      Top = 550
      TabOrder = 18
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 351
      Height = 116
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 273
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object ListBill: TcxListView [3]
      Left = 23
      Top = 446
      Width = 372
      Height = 113
      Columns = <
        item
          Caption = #27700#27877#31867#22411
          Width = 80
        end
        item
          Caption = #25552#36135#36710#36742
          Width = 70
        end
        item
          Caption = #21150#29702#37327'('#21544')'
          Width = 100
        end>
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 14
      ViewStyle = vsReport
    end
    object EditValue: TcxTextEdit [4]
      Left = 81
      Top = 421
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 12
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditTruck: TcxTextEdit [5]
      Left = 264
      Top = 182
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      OnExit = EditTruckExit
      OnKeyPress = EditLadingKeyPress
      Width = 116
    end
    object EditStock: TcxComboBox [6]
      Left = 81
      Top = 396
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 15
      Properties.ItemHeight = 18
      Properties.OnChange = EditStockPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 10
      OnKeyPress = EditLadingKeyPress
      Width = 115
    end
    object BtnAdd: TButton [7]
      Left = 357
      Top = 396
      Width = 39
      Height = 17
      Caption = #28155#21152
      TabOrder = 11
      OnClick = BtnAddClick
    end
    object BtnDel: TButton [8]
      Left = 357
      Top = 421
      Width = 39
      Height = 18
      Caption = #21024#38500
      TabOrder = 13
      OnClick = BtnDelClick
    end
    object EditLading: TcxComboBox [9]
      Left = 81
      Top = 182
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditFQ: TcxTextEdit [10]
      Left = 264
      Top = 157
      ParentFont = False
      Properties.MaxLength = 100
      Properties.OnEditValueChanged = EditFQPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 120
    end
    object EditType: TcxComboBox [11]
      Left = 81
      Top = 157
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object PrintGLF: TcxCheckBox [12]
      Left = 11
      Top = 550
      Caption = #25171#21360#36807#36335#36153
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 15
      Transparent = True
      Width = 95
    end
    object PrintHY: TcxCheckBox [13]
      Left = 111
      Top = 550
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 16
      Transparent = True
      Width = 95
    end
    object EditCarModel: TcxTextEdit [14]
      Left = 105
      Top = 232
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clScrollBar
      Style.HotTrack = False
      TabOrder = 5
      Width = 121
    end
    object EditXZValue: TcxTextEdit [15]
      Left = 105
      Top = 257
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clScrollBar
      Style.HotTrack = False
      TabOrder = 6
      Width = 121
    end
    object EditSBTare: TcxTextEdit [16]
      Left = 105
      Top = 282
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clScrollBar
      Style.HotTrack = False
      TabOrder = 7
      Width = 121
    end
    object EditMaxValue: TcxTextEdit [17]
      Left = 105
      Top = 307
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clScrollBar
      Style.HotTrack = False
      TabOrder = 8
      Width = 121
    end
    object editCard: TcxTextEdit [18]
      Left = 105
      Top = 332
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clScrollBar
      Style.HotTrack = False
      TabOrder = 9
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            Caption = #25552#36135#36890#36947':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #23553#31614#32534#21495':'
            Control = EditFQ
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item12: TdxLayoutItem
            Caption = #25552#36135#26041#24335':'
            Control = EditLading
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          object dxLayout1Item15: TdxLayoutItem
            Caption = #36710'    '#22411':'
            Control = EditCarModel
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item16: TdxLayoutItem
            Caption = #38480#36733#21544#25968':'
            Control = EditXZValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item17: TdxLayoutItem
            Caption = #30003#25253#30382#37325':'
            Control = EditSBTare
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item18: TdxLayoutItem
            Caption = #26368#22823#24320#21333#37327':'
            Control = EditMaxValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item19: TdxLayoutItem
            Caption = #32465#23450#21345#21495':'
            Control = editCard
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #27700#27877#31867#22411':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item10: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21150#29702#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListBill
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item13: TdxLayoutItem [0]
          Visible = False
          Control = PrintGLF
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem [1]
          Control = PrintHY
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
