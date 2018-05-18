inherited fFrameTestResult: TfFrameTestResult
  Width = 829
  Height = 465
  inherited ToolBar1: TToolBar
    Width = 829
  end
  inherited cxGrid1: TcxGrid
    Top = 198
    Width = 829
    Height = 267
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 829
    Height = 131
    object cxButtonEdit1: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      Width = 88
    end
    object cxButtonEdit2: TcxButtonEdit [1]
      Left = 220
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      Width = 92
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 81
      Top = 93
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [3]
      Left = 265
      Top = 93
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit [4]
      Left = 449
      Top = 93
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 6
      Width = 121
    end
    object cxTextEdit4: TcxTextEdit [5]
      Left = 621
      Top = 93
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 7
      Width = 121
    end
    object dateBegin: TcxDateEdit [6]
      Left = 375
      Top = 36
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      Width = 170
    end
    object dateEnd: TcxDateEdit [7]
      Left = 608
      Top = 36
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 3
      Width = 170
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          CaptionOptions.Text = #29289#26009#20449#24687':'
          Control = cxButtonEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          CaptionOptions.Text = #25805#20316#21592':'
          Control = cxButtonEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #24320#22987#26102#38388':'
          Control = dateBegin
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = #32467#26463#26102#38388':'
          Control = dateEnd
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #29289#26009#21517#31216':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = #26816#39564#32467#26524':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          CaptionOptions.Text = #25187#37325#20449#24687':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          CaptionOptions.Text = #25805#20316#21592':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 190
    Width = 829
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 829
    inherited TitleBar: TcxLabel
      Caption = #26816#39564#32467#26524#26597#35810
      Style.IsFontAssigned = True
      Width = 829
      AnchorX = 415
      AnchorY = 11
    end
  end
end
