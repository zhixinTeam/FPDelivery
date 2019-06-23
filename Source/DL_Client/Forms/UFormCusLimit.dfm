inherited fFormCusLimit: TfFormCusLimit
  Left = 254
  Top = 127
  Caption = #38480#21046#25552#36135#35774#32622
  ClientHeight = 539
  ClientWidth = 533
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 533
    Height = 539
    inherited BtnOK: TButton
      Left = 387
      Top = 506
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 457
      Top = 506
      TabOrder = 7
    end
    object cbbStockNo: TcxComboBox [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.OnChange = cbbStockNoPropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 264
    end
    object cxCheckBox1: TcxCheckBox [3]
      Left = 350
      Top = 36
      Caption = #21551#29992#23458#25143#21457#36135#26085#38480#39069
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      Transparent = True
      OnClick = cxCheckBox1Click
      Width = 150
    end
    object ListDetail: TcxListView [4]
      Left = 23
      Top = 152
      Width = 487
      Height = 342
      Columns = <
        item
          Caption = #23458#25143#32534#21495
          Width = 100
        end
        item
          Alignment = taCenter
          Caption = #23458#25143#21517#31216
          Width = 200
        end
        item
          Alignment = taCenter
          Caption = #26085#38480#39069'('#21544')'
          Width = 90
        end>
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 5
      ViewStyle = vsReport
      OnClick = ListDetailClick
    end
    object editCusNo: TcxTextEdit [5]
      Left = 81
      Top = 95
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 2
      Width = 152
    end
    object editCusName: TcxTextEdit [6]
      Left = 296
      Top = 95
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 214
    end
    object editValue: TcxTextEdit [7]
      Left = 81
      Top = 120
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      OnExit = editValueExit
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #29289#26009#21517#31216':'
            Control = cbbStockNo
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            Control = cxCheckBox1
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxlytgrpLayout1Group2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        object dxlytgrpLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            Caption = #23458#25143#32534#21495':'
            Control = editCusNo
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item7: TdxLayoutItem
            Caption = #23458#25143#21517#31216':'
            Control = editCusName
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #38480#25552#21544#25968':'
          Control = editValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Control = ListDetail
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
