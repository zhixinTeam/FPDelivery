inherited fFormSalesMan: TfFormSalesMan
  Left = 316
  Top = 166
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 409
  ClientWidth = 447
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 447
    Height = 409
    Align = alClient
    TabOrder = 0
    TabStop = False
    object EditName: TcxTextEdit
      Left = 84
      Top = 29
      Hint = 'T.S_Name'
      ParentFont = False
      Properties.MaxLength = 30
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyDown = FormKeyDown
      Width = 336
    end
    object EditMemo: TcxMemo
      Left = 84
      Top = 107
      Hint = 'T.S_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Edges = [bBottom]
      TabOrder = 3
      Height = 50
      Width = 336
    end
    object InfoList1: TcxMCListBox
      Left = 24
      Top = 246
      Width = 397
      Height = 105
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 105
        end
        item
          AutoSize = True
          Text = #20869#23481
          Width = 288
        end>
      ParentFont = False
      Style.BorderStyle = cbsOffice11
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 8
    end
    object InfoItems: TcxComboBox
      Left = 84
      Top = 194
      ParentFont = False
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.MaxLength = 30
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 4
      Width = 75
    end
    object EditInfo: TcxTextEdit
      Left = 84
      Top = 220
      ParentFont = False
      Properties.MaxLength = 50
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 89
    end
    object BtnAdd: TButton
      Left = 376
      Top = 194
      Width = 45
      Height = 17
      Caption = #28155#21152
      TabOrder = 5
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 376
      Top = 220
      Width = 45
      Height = 18
      Caption = #21024#38500
      TabOrder = 7
      OnClick = BtnDelClick
    end
    object BtnOK: TButton
      Left = 287
      Top = 370
      Width = 70
      Height = 21
      Caption = #20445#23384
      TabOrder = 10
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 363
      Top = 370
      Width = 71
      Height = 21
      Caption = #21462#28040
      TabOrder = 11
      OnClick = BtnExitClick
    end
    object cxTextEdit3: TcxTextEdit
      Left = 84
      Top = 55
      Hint = 'T.S_Phone'
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      OnKeyDown = FormKeyDown
      Width = 336
    end
    object EditArea: TcxButtonEdit
      Left = 84
      Top = 81
      Hint = 'T.S_Area'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 50
      Properties.OnButtonClick = EditAreaPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 2
      OnKeyDown = FormKeyDown
      Width = 336
    end
    object Check1: TcxCheckBox
      Left = 11
      Top = 370
      Hint = 'T.S_InValid'
      Caption = #26080#25928#20154#21592': '#27491#24120#26597#35810#26102#19981#20104#26174#31034'.'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 9
      Transparent = True
      Width = 220
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #20154#21592#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item14: TdxLayoutItem
            Caption = #32852#31995#26041#24335':'
            Control = cxTextEdit3
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          Caption = #25152#22312#21306#22495':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #38468#21152#20449#24687
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxlytgrpLayoutControl1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449' '#24687' '#39033':'
              Control = InfoItems
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449#24687#20869#23481':'
              Control = EditInfo
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = InfoList1
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item1: TdxLayoutItem
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
