inherited fFrameFangHuiQuery: TfFrameFangHuiQuery
  inherited dxLayout1: TdxLayoutControl
    object EditDate: TcxButtonEdit [0]
      Left = 256
      Top = 50
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 1
      Width = 186
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 69
      Top = 50
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 0
      Width = 142
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#21495#65306
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#65306
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #25955#35013#35013#36710#25918#28784#35760#24405
      Style.IsFontAssigned = True
      AnchorX = 326
      AnchorY = 11
    end
  end
end
