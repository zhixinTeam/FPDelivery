inherited fFormBackCashRule: TfFormBackCashRule
  Left = 502
  Top = 213
  Caption = #35774#32622#36820#29616#35268#21017
  ClientHeight = 394
  ClientWidth = 480
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 480
    Height = 394
    inherited BtnOK: TButton
      Left = 334
      Top = 361
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 404
      Top = 361
      TabOrder = 9
    end
    object editZhika: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object editStockNo: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      Width = 121
    end
    object GroupBox1: TGroupBox [4]
      Left = 23
      Top = 86
      Width = 463
      Height = 208
      Caption = #36820#29616#35268#21017
      ParentColor = False
      TabOrder = 2
      object ListDetail: TcxListView
        Left = 2
        Top = 14
        Width = 459
        Height = 192
        Align = alClient
        Columns = <
          item
            Caption = #36215#22987#20540
            Width = 120
          end
          item
            Caption = #32467#26463#20540
            Width = 100
          end
          item
            Caption = #36820#29616'('#20803'/'#21544')'
            Width = 100
          end>
        HideSelection = False
        ParentFont = False
        ReadOnly = True
        RowSelect = True
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object btnDel: TButton [5]
      Left = 392
      Top = 324
      Width = 65
      Height = 22
      Caption = #21024#38500
      TabOrder = 7
      OnClick = btnDelClick
    end
    object btnAdd: TButton [6]
      Left = 322
      Top = 324
      Width = 65
      Height = 22
      Caption = #28155#21152
      TabOrder = 6
      OnClick = btnAddClick
    end
    object EditStart: TcxTextEdit [7]
      Left = 81
      Top = 299
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 100
    end
    object EditEnd: TcxTextEdit [8]
      Left = 232
      Top = 299
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 100
    end
    object editValue: TcxTextEdit [9]
      Left = 365
      Top = 299
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      Width = 90
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #32440#21345#32534#21495':'
          Control = editZhika
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #29289#26009#32534#21495':'
          Control = editStockNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = 'GroupBox1'
          CaptionOptions.Visible = False
          Control = GroupBox1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            CaptionOptions.Text = #36215#22987#20540':'
            Control = EditStart
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            CaptionOptions.Text = #32467#26463#20540':'
            Control = EditEnd
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            CaptionOptions.Text = #37329#39069
            Control = editValue
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group3: TdxLayoutGroup
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            AlignHorz = ahRight
            CaptionOptions.AlignHorz = taRightJustify
            CaptionOptions.Text = 'Button2'
            CaptionOptions.Visible = False
            Control = btnAdd
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AlignHorz = ahRight
            CaptionOptions.Text = 'Button1'
            CaptionOptions.Visible = False
            Control = btnDel
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
