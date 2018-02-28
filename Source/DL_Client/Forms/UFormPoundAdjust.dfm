inherited fFormPoundAdjust: TfFormPoundAdjust
  Left = 669
  Top = 339
  ClientHeight = 358
  ClientWidth = 513
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 513
    Height = 358
    inherited BtnOK: TButton
      Left = 367
      Top = 325
      TabOrder = 14
    end
    inherited BtnExit: TButton
      Left = 437
      Top = 325
      TabOrder = 15
    end
    object EditCusName: TcxTextEdit [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 1
      Width = 300
    end
    object EditTruck: TcxTextEdit [3]
      Left = 279
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = False
      TabOrder = 3
      Width = 165
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 111
      AutoSize = False
      Caption = #30382#37325':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 125
    end
    object EditPValue: TcxTextEdit [5]
      Left = 81
      Top = 144
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 5
      Width = 135
    end
    object cxLabel2: TcxLabel [6]
      Left = 23
      Top = 169
      AutoSize = False
      Caption = #27611#37325':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 183
    end
    object EditMValue: TcxTextEdit [7]
      Left = 81
      Top = 202
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 8
      Width = 135
    end
    object cxLabel3: TcxLabel [8]
      Left = 23
      Top = 227
      AutoSize = False
      Caption = #29366#24577':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 633
      AnchorY = 241
    end
    object EditID: TcxTextEdit [9]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxTextEdit [10]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 2
      Width = 135
    end
    object EditStatus: TcxComboBox [11]
      Left = 81
      Top = 260
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        'I=I'#12289#36827#21378
        'O=O'#12289#20986#21378
        'P=P'#12289#31216#30382#37325
        'M=M'#12289#31216#27611#37325
        'S=S'#12289#36865#36135#20013
        'F=F'#12289#25918#28784#22788
        'Z=Z'#12289#26632#21488
        'X=X'#12289#29616#22330#39564#25910)
      TabOrder = 11
      Width = 135
    end
    object EditNext: TcxComboBox [12]
      Left = 279
      Top = 260
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        'I=I'#12289#36827#21378
        'O=O'#12289#20986#21378
        'P=P'#12289#31216#30382#37325
        'M=M'#12289#31216#27611#37325
        'S=S'#12289#36865#36135#20013
        'F=F'#12289#25918#28784#22788
        'Z=Z'#12289#26632#21488
        'X=X'#12289#29616#22330#39564#25910)
      TabOrder = 12
      Width = 165
    end
    object EditMDate: TcxDateEdit [13]
      Left = 279
      Top = 202
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 9
      Width = 165
    end
    object EditPDate: TcxDateEdit [14]
      Left = 279
      Top = 144
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 6
      Width = 165
    end
    object EditMemo: TcxTextEdit [15]
      Left = 81
      Top = 285
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 13
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group10: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item21: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #30917#21333#32534#21495':'
              Control = EditID
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #23458#25143#21517#31216':'
              Control = EditCusName
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item22: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #29289#26009#21517#31216':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item5: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #36710#33337#21495#30721':'
              Control = EditTruck
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item10: TdxLayoutItem
              Caption = #37325#37327'('#21544'):'
              Control = EditPValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item15: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #36807#30917#26102#38388':'
              Control = EditPDate
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Item13: TdxLayoutItem
            ShowCaption = False
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group5: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group6: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item14: TdxLayoutItem
                Caption = #37325#37327'('#21544'):'
                Control = EditMValue
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item7: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #36807#30917#26102#38388':'
                Control = EditMDate
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item20: TdxLayoutItem
                ShowCaption = False
                Control = cxLabel3
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Group3: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayout1Item4: TdxLayoutItem
                  Caption = #24403#21069#29366#24577':'
                  Control = EditStatus
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item23: TdxLayoutItem
                  AutoAligns = [aaVertical]
                  AlignHorz = ahClient
                  Caption = #19979#19968#29366#24577':'
                  Control = EditNext
                  ControlOptions.ShowBorder = False
                end
              end
            end
          end
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25551#36848#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
