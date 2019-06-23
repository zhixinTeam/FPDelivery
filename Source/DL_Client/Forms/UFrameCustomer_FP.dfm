inherited fFrameCustomer_FP: TfFrameCustomer_FP
  Width = 966
  Height = 531
  inherited ToolBar1: TToolBar
    Width = 966
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 198
    Width = 966
    Height = 333
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 966
    Height = 131
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.C_ID'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 2
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [1]
      Left = 265
      Top = 93
      Hint = 'T.C_Name'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit [2]
      Left = 437
      Top = 93
      Hint = 'T.C_LiXiRen'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 121
    end
    object EditID: TcxButtonEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object EditName: TcxButtonEdit [4]
      Left = 265
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object cxTextEdit4: TcxTextEdit [5]
      Left = 621
      Top = 93
      Hint = 'T.C_Phone'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32852#31995#20154':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #32852#31995#30005#35805':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 190
    Width = 966
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 966
    inherited TitleBar: TcxLabel
      Caption = #23458#25143#31649#29702
      Style.IsFontAssigned = True
      Width = 966
      AnchorX = 483
      AnchorY = 11
    end
  end
  object cxTreeList1: TcxTreeList [5]
    Left = 0
    Top = 198
    Width = 966
    Height = 333
    Align = alClient
    Bands = <
      item
      end>
    BufferedPaint = False
    OptionsData.Editing = False
    OptionsView.GridLineColor = clBtnShadow
    OptionsView.GridLines = tlglBoth
    OptionsView.PaintStyle = tlpsCategorized
    OptionsView.TreeLineStyle = tllsSolid
    PopupMenu = PMenu1
    TabOrder = 5
    OnClick = cxTreeList1Click
    OnDblClick = cxTreeList1DblClick
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 36
    Top = 264
    object N1: TMenuItem
      Tag = 10
      Caption = #38750#27491#24335#23458#25143
      OnClick = N1Click
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #26597#35810#20840#37096#23458#25143
      OnClick = N1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object m_bindWechartAccount: TMenuItem
      Caption = #20851#32852#24494#20449#21830#22478#36134#25143
      OnClick = m_bindWechartAccountClick
    end
    object N6: TMenuItem
      Caption = #21462#28040#21830#22478#36134#21495#20851#32852
      OnClick = N6Click
    end
  end
end
