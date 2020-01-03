inherited fFrameZKRechargeLog: TfFrameZKRechargeLog
  Width = 780
  Height = 410
  inherited ToolBar1: TToolBar
    Width = 780
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 199
    Width = 780
    Height = 211
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 780
    Height = 132
    object editID: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = editIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object editName: TcxButtonEdit [1]
      Left = 265
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = editIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditDate: TcxButtonEdit [2]
      Left = 449
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
      TabOrder = 2
      Width = 190
    end
    object cxTextEdit1: TcxTextEdit [3]
      Left = 81
      Top = 93
      Hint = 'T.R_ZhiKa'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [4]
      Left = 265
      Top = 93
      Hint = 'T.R_ZKName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 184
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 512
      Top = 93
      Hint = 'T.R_Value'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = editID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #35746#21333#21517#31216':'
          Control = editName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #35746#21333#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #20805#20540#37329#39069':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 191
    Width = 780
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 780
    inherited TitleBar: TcxLabel
      Caption = #35746#21333#20805#20540#35760#24405
      Style.IsFontAssigned = True
      Width = 780
      AnchorX = 390
      AnchorY = 11
    end
  end
end
