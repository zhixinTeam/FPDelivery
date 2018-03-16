inherited fFormAuditTruck: TfFormAuditTruck
  Left = 381
  Top = 62
  Width = 609
  Height = 553
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #36710#36742#23457#26680
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object lblwebid: TLabel
    Left = 80
    Top = 14
    Width = 48
    Height = 12
    Caption = 'lblwebid'
    Color = clWindow
    ParentColor = False
    Visible = False
  end
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 593
    Height = 515
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    object EditType: TcxTextEdit
      Left = 81
      Top = 354
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 3
      Width = 213
    end
    object EditTruck: TcxTextEdit
      Left = 81
      Top = 329
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 213
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 429
      Align = alClient
      ParentFont = False
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Height = 40
      Width = 252
    end
    object BtnExit: TButton
      Left = 507
      Top = 481
      Width = 75
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 10
    end
    object BtnOK: TButton
      Left = 427
      Top = 481
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 9
      OnClick = BtnOKClick
    end
    object ImageTruck: TcxImage
      Left = 81
      Top = 36
      Align = alTop
      AutoSize = True
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Height = 288
      Width = 489
    end
    object EditResult: TcxComboBox
      Left = 81
      Top = 404
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        #36890#36807
        #39539#22238)
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 7
      Text = #36890#36807
      Width = 121
    end
    object editTypeName: TcxTextEdit
      Left = 357
      Top = 354
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 4
      Width = 213
    end
    object editSB: TcxTextEdit
      Left = 357
      Top = 379
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 6
      Width = 213
    end
    object editHZ: TcxTextEdit
      Left = 81
      Top = 379
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 5
      Width = 213
    end
    object eeditPhone: TcxTextEdit
      Left = 357
      Top = 329
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 2
      Width = 213
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahParentManaged
      AlignVert = avParentManaged
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group5: TdxLayoutGroup
        AlignVert = avTop
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Group6: TdxLayoutGroup
          AlignHorz = ahClient
          ButtonOptions.Buttons = <>
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Group1: TdxLayoutGroup
            AlignHorz = ahClient
            AlignVert = avTop
            CaptionOptions.Text = #36710#36742#20449#24687
            ButtonOptions.Buttons = <>
            object dxLayoutControl1Item9: TdxLayoutItem
              CaptionOptions.Text = #36710#36742#22270#29255
              Control = ImageTruck
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Group3: TdxLayoutGroup
              ButtonOptions.Buttons = <>
              Hidden = True
              ShowBorder = False
              object dxLayoutControl1Group8: TdxLayoutGroup
                ButtonOptions.Buttons = <>
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayoutControl1Item2: TdxLayoutItem
                  CaptionOptions.Text = #36710#29260#21495#30721':'
                  Control = EditTruck
                  ControlOptions.ShowBorder = False
                end
                object dxLayoutControl1Item11: TdxLayoutItem
                  CaptionOptions.Text = #32852#31995#30005#35805':'
                  Control = eeditPhone
                  ControlOptions.ShowBorder = False
                end
              end
              object dxLayoutControl1Group7: TdxLayoutGroup
                ButtonOptions.Buttons = <>
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayoutControl1Item1: TdxLayoutItem
                  CaptionOptions.Text = #36710#36742#31867#22411':'
                  Control = EditType
                  ControlOptions.ShowBorder = False
                end
                object dxLayoutControl1Item4: TdxLayoutItem
                  CaptionOptions.Text = #36710#22411#21517#31216':'
                  Control = editTypeName
                  ControlOptions.ShowBorder = False
                end
              end
            end
            object dxLayoutControl1Group4: TdxLayoutGroup
              ButtonOptions.Buttons = <>
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayoutControl1Item10: TdxLayoutItem
                CaptionOptions.Text = #33655#36733#37325#37327':'
                Control = editHZ
                ControlOptions.ShowBorder = False
              end
              object dxLayoutControl1Item5: TdxLayoutItem
                CaptionOptions.Text = #30003#25253#30382#37325':'
                Control = editSB
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayoutControl1Item3: TdxLayoutItem
              CaptionOptions.Text = #23457#26680#32467#26524':'
              Control = EditResult
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item6: TdxLayoutItem
              CaptionOptions.Text = #23457#26680#22791#27880':'
              Control = EditMemo
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AlignHorz = ahRight
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item8: TdxLayoutItem
          AlignHorz = ahRight
          CaptionOptions.Text = 'Button2'
          CaptionOptions.Visible = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AlignHorz = ahRight
          AlignVert = avBottom
          CaptionOptions.Text = 'Button1'
          CaptionOptions.Visible = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
