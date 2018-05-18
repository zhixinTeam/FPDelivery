inherited fFormGetContract: TfFormGetContract
  Left = 401
  Top = 134
  Width = 445
  Height = 300
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 429
    Height = 262
    inherited BtnOK: TButton
      Left = 283
      Top = 229
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 353
      Top = 229
      TabOrder = 6
    end
    object EditSMan: TcxComboBox [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditSManPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Width = 121
    end
    object EditCustom: TcxComboBox [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditCustomPropertiesEditValueChanged
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      OnKeyPress = EditCustomKeyPress
      Width = 121
    end
    object EditCID: TcxButtonEdit [4]
      Left = 81
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
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListContract: TcxListView [5]
      Left = 23
      Top = 132
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #21512#21516#32534#21495
        end
        item
          Caption = #19994#21153#21592
        end
        item
          Caption = #23458#25143#21517#31216
        end
        item
          Caption = #39033#30446#21517#31216
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 4
      ViewStyle = vsReport
      OnDblClick = ListContractDblClick
      OnKeyPress = ListContractKeyPress
    end
    object cxLabel1: TcxLabel [6]
      Left = 23
      Top = 111
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = #21512#21516#32534#21495':'
          Control = EditCID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          CaptionOptions.Visible = False
          ButtonOptions.Buttons = <>
          Hidden = True
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            CaptionOptions.Text = #19994#21153#20154#21592':'
            Control = EditSMan
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            CaptionOptions.Text = #23458#25143#21517#31216':'
            Control = EditCustom
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = 'cxLabel1'
          CaptionOptions.Visible = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AlignVert = avClient
          CaptionOptions.Text = #26597#35810#32467#26524':'
          CaptionOptions.Visible = False
          Control = ListContract
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
