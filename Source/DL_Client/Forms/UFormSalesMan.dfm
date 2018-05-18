inherited fFormSalesMan: TfFormSalesMan
  Left = 316
  Top = 166
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 405
  ClientWidth = 403
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 403
    Height = 405
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    object EditName: TcxTextEdit
      Left = 81
      Top = 36
      Hint = 'T.S_Name'
      ParentFont = False
      Properties.MaxLength = 30
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      OnKeyDown = FormKeyDown
      Width = 138
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 111
      Hint = 'T.S_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Edges = [bBottom]
      TabOrder = 3
      Height = 50
      Width = 368
    end
    object InfoList1: TcxMCListBox
      Left = 23
      Top = 248
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
      Left = 81
      Top = 198
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
      Left = 81
      Top = 223
      ParentFont = False
      Properties.MaxLength = 50
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 89
    end
    object BtnAdd: TButton
      Left = 335
      Top = 198
      Width = 45
      Height = 17
      Caption = #28155#21152
      TabOrder = 5
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 335
      Top = 223
      Width = 45
      Height = 18
      Caption = #21024#38500
      TabOrder = 7
      OnClick = BtnDelClick
    end
    object BtnOK: TButton
      Left = 246
      Top = 372
      Width = 70
      Height = 21
      Caption = #20445#23384
      TabOrder = 10
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 321
      Top = 372
      Width = 71
      Height = 21
      Caption = #21462#28040
      TabOrder = 11
      OnClick = BtnExitClick
    end
    object cxTextEdit3: TcxTextEdit
      Left = 81
      Top = 61
      Hint = 'T.S_Phone'
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      OnKeyDown = FormKeyDown
      Width = 159
    end
    object EditArea: TcxButtonEdit
      Left = 81
      Top = 86
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
      Width = 121
    end
    object Check1: TcxCheckBox
      Left = 11
      Top = 372
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
      AlignHorz = ahParentManaged
      AlignVert = avParentManaged
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        CaptionOptions.Text = #22522#26412#20449#24687
        ButtonOptions.Buttons = <>
        object dxLayoutControl1Group9: TdxLayoutGroup
          CaptionOptions.Visible = False
          ButtonOptions.Buttons = <>
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            AlignHorz = ahClient
            CaptionOptions.Text = #20154#21592#21517#31216':'
            Control = EditName
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item14: TdxLayoutItem
            AlignHorz = ahClient
            CaptionOptions.Text = #32852#31995#26041#24335':'
            Control = cxTextEdit3
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          CaptionOptions.Text = #25152#22312#21306#22495':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          CaptionOptions.Text = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AlignVert = avClient
        CaptionOptions.Text = #38468#21152#20449#24687
        ButtonOptions.Buttons = <>
        object dxLayoutControl1Group4: TdxLayoutGroup
          CaptionOptions.Visible = False
          ButtonOptions.Buttons = <>
          Hidden = True
          ShowBorder = False
          object dxlytgrpLayoutControl1Group6: TdxLayoutGroup
            CaptionOptions.Visible = False
            ButtonOptions.Buttons = <>
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item6: TdxLayoutItem
              AlignHorz = ahClient
              CaptionOptions.Text = #20449' '#24687' '#39033':'
              Control = InfoItems
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item8: TdxLayoutItem
              AlignHorz = ahRight
              CaptionOptions.Text = 'Button1'
              CaptionOptions.Visible = False
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group6: TdxLayoutGroup
            CaptionOptions.Visible = False
            ButtonOptions.Buttons = <>
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item7: TdxLayoutItem
              AlignHorz = ahClient
              CaptionOptions.Text = #20449#24687#20869#23481':'
              Control = EditInfo
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item9: TdxLayoutItem
              AlignHorz = ahRight
              CaptionOptions.Text = 'Button2'
              CaptionOptions.Visible = False
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          AlignVert = avClient
          Control = InfoList1
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AlignVert = avClient
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item1: TdxLayoutItem
          CaptionOptions.Text = 'cxCheckBox1'
          CaptionOptions.Visible = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item10: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button3'
          CaptionOptions.Visible = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button4'
          CaptionOptions.Visible = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
