inherited fFormBackCash: TfFormBackCash
  Left = 659
  Top = 318
  Caption = 'fFormBackCash'
  ClientHeight = 267
  ClientWidth = 368
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 368
    Height = 267
    inherited BtnOK: TButton
      Left = 222
      Top = 234
      Caption = #24320#22987
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 292
      Top = 234
      TabOrder = 3
    end
    object EditWeek: TcxButtonEdit [2]
      Left = 23
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditWeekPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      Width = 121
    end
    object EditMemo: TcxMemo [3]
      Left = 23
      Top = 61
      ParentFont = False
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      Style.HotTrack = False
      TabOrder = 1
      Height = 156
      Width = 264
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Control = EditWeek
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.AlignVert = tavTop
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
