object fFrameMain: TfFrameMain
  Left = 0
  Top = 0
  Width = 764
  Height = 548
  OnCreate = UniFrameCreate
  OnDestroy = UniFrameDestroy
  Font.Charset = GB2312_CHARSET
  Font.Height = -12
  Font.Name = #23435#20307
  TabOrder = 0
  ParentFont = False
  object Panel1: TUniSimplePanel
    Left = 0
    Top = 0
    Width = 764
    Height = 548
    Hint = ''
    ParentColor = False
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object PageWork: TUniPageControl
      Left = 262
      Top = 80
      Width = 502
      Height = 449
      Hint = ''
      ActivePage = SheetWelcome
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 1
      OnChange = PageWorkChange
      object SheetWelcome: TUniTabSheet
        Hint = ''
        Caption = #27426#36814#39029#38754
        object UniPanel1: TUniPanel
          Left = 0
          Top = 0
          Width = 494
          Height = 421
          Hint = ''
          Align = alClient
          Anchors = [akLeft, akTop, akRight, akBottom]
          ParentFont = False
          Font.Charset = GB2312_CHARSET
          Font.Height = -20
          Font.Name = #26999#20307
          TabOrder = 0
          BorderStyle = ubsNone
          Caption = #27426#36814#20351#29992'DL'#32593#39029#29256
        end
      end
      object SheetMemory: TUniTabSheet
        Hint = ''
        Caption = #20869#23384#29366#24577
        object MemoMemory: TUniMemo
          Left = 0
          Top = 42
          Width = 494
          Height = 379
          Hint = ''
          ScrollBars = ssBoth
          Align = alClient
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
        end
        object UniSimplePanel1: TUniSimplePanel
          Left = 0
          Top = 0
          Width = 494
          Height = 42
          Hint = ''
          ParentColor = False
          Align = alTop
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          DesignSize = (
            494
            42)
          object BtnFresh: TUniButton
            Left = 406
            Top = 8
            Width = 75
            Height = 25
            Hint = ''
            Caption = #21047#26032
            Anchors = [akTop, akRight]
            TabOrder = 1
            OnClick = BtnFreshClick
          end
          object CheckFriendly: TUniCheckBox
            Left = 304
            Top = 12
            Width = 100
            Height = 17
            Hint = ''
            Checked = True
            Caption = #21451#22909#26684#24335#26174#31034
            Anchors = [akTop, akRight]
            TabOrder = 2
          end
          object BtnUpdateMemory: TUniButton
            Left = 8
            Top = 8
            Width = 75
            Height = 25
            Hint = ''
            Caption = #26356#26032#32531#23384
            TabOrder = 3
            OnClick = BtnUpdateMemoryClick
          end
        end
      end
    end
    object PanelLeft: TUniPanel
      Left = 0
      Top = 80
      Width = 256
      Height = 449
      Hint = ''
      Align = alLeft
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 2
      BorderStyle = ubsNone
      ShowCaption = False
      TitleVisible = True
      Caption = ''
      Collapsible = True
      CollapseDirection = cdLeft
      object UniSimplePanel3: TUniSimplePanel
        Left = 0
        Top = 0
        Width = 256
        Height = 70
        Hint = ''
        ParentColor = False
        Border = True
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        DesignSize = (
          256
          70)
        object ComboFactory: TUniComboBox
          Left = 3
          Top = 30
          Width = 237
          Hint = ''
          Style = csDropDownList
          Text = ''
          Items.Strings = (
            'aa'
            'bb'
            'cc'
            'dd'
            'ee')
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          EmptyText = #24037#21378#21015#34920
          FieldLabelFont.Charset = GB2312_CHARSET
          FieldLabelFont.Height = -12
          FieldLabelFont.Name = #23435#20307
          Images = UniMainModule.ImageListSmall
          OnChange = ComboFactoryChange
        end
        object LabelFactory: TUniLabel
          Left = 7
          Top = 12
          Width = 120
          Height = 12
          Hint = ''
          Caption = #24403#21069#27491#22312#25805#20316#30340#24037#21378#65306
          ParentFont = False
          Font.Charset = GB2312_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = #23435#20307
          TabOrder = 2
        end
      end
      object TreeMenu: TUniTreeView
        Left = 0
        Top = 70
        Width = 256
        Height = 379
        Hint = ''
        Items.NodeData = {
          0303000000220000000000000000000000FFFFFFFFFFFFFFFF00000000000000
          00020000000102FB7CDF7E24000000010000000100000002000000FFFFFFFF00
          0000000000000000000000010331003100310024000000010000000100000002
          000000FFFFFFFF00000000000000000000000001033200320032002400000000
          00000000000000FFFFFFFFFFFFFFFF000000000000000000000000010316538C
          9AA45B220000000000000000000000FFFFFFFFFFFFFFFF000000000000000000
          0000000102C5783F62}
        Items.FontData = {
          0103000000FFFFFFFF02000000FFFFFFFF00000000FFFFFFFF00000000FFFFFF
          FF00000000FFFFFFFF00000000}
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 2
        Color = clWindow
        OnClick = TreeMenuClick
        OnMouseDown = TreeMenuMouseDown
      end
    end
    object PanelTop: TUniSimplePanel
      Left = 0
      Top = 0
      Width = 764
      Height = 80
      Hint = ''
      ParentColor = False
      Align = alTop
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      object ImageRight: TUniImage
        Left = 543
        Top = 0
        Width = 221
        Height = 80
        Hint = ''
        AutoSize = True
        Align = alRight
        Anchors = [akTop, akRight, akBottom]
      end
      object ImageLeft: TUniImage
        Left = 0
        Top = 0
        Width = 543
        Height = 80
        Hint = ''
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
      end
      object LabelHint: TUniLabel
        Left = 15
        Top = 40
        Width = 90
        Height = 20
        Hint = ''
        Caption = 'HintLabel'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Color = clWhite
        Font.Height = -20
        Font.Name = #26999#20307
        TabOrder = 3
      end
    end
    object StatusBar1: TUniStatusBar
      Left = 0
      Top = 529
      Width = 764
      Height = 19
      Hint = ''
      Panels = <>
      SizeGrip = False
      Align = alBottom
      Anchors = [akLeft, akRight, akBottom]
      ParentColor = False
      Color = clWindow
    end
    object UniSplitter1: TUniSplitter
      Left = 256
      Top = 80
      Width = 6
      Height = 449
      Hint = ''
      Align = alLeft
      ParentColor = False
      Color = clBtnFace
    end
  end
  object PMenu1: TUniPopupMenu
    Left = 48
    Top = 248
    object N1: TUniMenuItem
      Caption = #20840#37096#23637#24320
      OnClick = N1Click
    end
    object N2: TUniMenuItem
      Caption = '-'
    end
    object N3: TUniMenuItem
      Caption = #20840#37096#25910#36215
      OnClick = N3Click
    end
  end
end
