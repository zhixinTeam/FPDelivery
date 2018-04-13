object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 368
  Height = 655
  TabOrder = 0
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 353
    Height = 542
    TabOrder = 0
    object lblUpdown: TLabel
      Left = 14
      Top = 166
      Width = 63
      Height = 18
      AutoSize = False
      Caption = #19978#19979
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblAdd: TLabel
      Left = 88
      Top = 152
      Width = 36
      Height = 18
      AutoSize = False
      Caption = #21152#26009
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblReady: TLabel
      Left = 137
      Top = 152
      Width = 37
      Height = 18
      AutoSize = False
      Caption = #22791#22949
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblOpenValue: TLabel
      Left = 293
      Top = 151
      Width = 48
      Height = 18
      AutoSize = False
      Caption = #38400#24230
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object shpAdd: TShape
      Left = 88
      Top = 123
      Width = 27
      Height = 22
      Brush.Color = clRed
      Shape = stCircle
    end
    object shpReady: TShape
      Left = 138
      Top = 123
      Width = 27
      Height = 22
      Brush.Color = clRed
      Shape = stCircle
    end
    object shpFan: TShape
      Left = 188
      Top = 123
      Width = 27
      Height = 22
      Brush.Color = clRed
      Shape = stCircle
    end
    object lblFan: TLabel
      Left = 189
      Top = 152
      Width = 37
      Height = 18
      AutoSize = False
      Caption = #39118#26426
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object shpKw: TShape
      Left = 238
      Top = 123
      Width = 27
      Height = 22
      Brush.Color = clRed
      Shape = stCircle
    end
    object lblKW: TLabel
      Left = 234
      Top = 152
      Width = 37
      Height = 18
      AutoSize = False
      Caption = #26009#20301
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 334
      Top = 176
      Width = 60
      Height = 18
      AutoSize = False
      Caption = #19978#19979
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object ToolBar1: TToolBar
      Left = 8
      Top = 509
      Width = 155
      Height = 23
      Align = alNone
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 37
      Caption = 'ToolBar1'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 0
      object btnStart: TToolButton
        Left = 0
        Top = 2
        Caption = #24320'  '#22987
        ImageIndex = 0
        OnClick = btnStartClick
      end
      object ToolButton2: TToolButton
        Left = 37
        Top = 2
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnPause: TToolButton
        Left = 45
        Top = 2
        Width = 4
        Caption = #26242'  '#20572
        Enabled = False
        ImageIndex = 4
        Style = tbsSeparator
        Visible = False
        OnClick = btnPauseClick
      end
      object ToolButton9: TToolButton
        Left = 49
        Top = 2
        Width = 8
        Caption = 'ToolButton9'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object btnStop: TToolButton
        Left = 57
        Top = 2
        Caption = #20572'  '#27490
        Enabled = False
        ImageIndex = 2
        OnClick = btnStopClick
      end
      object ToolButton6: TToolButton
        Left = 94
        Top = 2
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton10: TToolButton
        Left = 102
        Top = 2
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object btnReset: TToolButton
        Left = 110
        Top = 2
        Caption = #22797'  '#20301
        ImageIndex = 3
        OnClick = btnResetClick
        OnMouseDown = btnResetMouseDown
        OnMouseUp = btnResetMouseUp
      end
      object ToolButton1: TToolButton
        Left = 147
        Top = 2
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 4
        Style = tbsSeparator
      end
    end
    object ToolBar2: TToolBar
      Left = 193
      Top = 510
      Width = 43
      Height = 23
      Align = alNone
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 43
      Caption = 'ToolBar2'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 1
      object btnUp: TToolButton
        Left = 0
        Top = 2
        Caption = #8593#19978#31227
        ImageIndex = 0
        OnClick = btnUpClick
        OnMouseDown = btnUpMouseDown
        OnMouseUp = btnUpMouseUp
      end
    end
    object ToolBar3: TToolBar
      Left = 241
      Top = 509
      Width = 43
      Height = 23
      Align = alNone
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 43
      Caption = 'ToolBar3'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 2
      object btnDown: TToolButton
        Left = 0
        Top = 2
        Caption = #8595#19979#31227
        ImageIndex = 0
        OnClick = btnDownClick
        OnMouseDown = btnDownMouseDown
        OnMouseUp = btnDownMouseUp
      end
    end
    object GroupBox2: TGroupBox
      Left = 7
      Top = 13
      Width = 337
      Height = 106
      Caption = #21333#20301': '#21544
      TabOrder = 3
      object EditValue: TLEDFontNum
        Left = 6
        Top = 20
        Width = 325
        Height = 75
        OffSetX = 8
        OffSetY = 6
        WordWidth = 36
        WordHeight = 61
        Thick = 5
        Space = 5
        Text = '12345678'
        AutoSize = False
        DrawDarkColor = False
      end
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 216
      Width = 337
      Height = 253
      Caption = #25552#36135#21333#20449#24687
      TabOrder = 4
      object cxLabel4: TcxLabel
        Left = 11
        Top = 116
        Caption = #20132#36135#21333#21495':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object EditBill: TcxComboBox
        Left = 126
        Top = 116
        ParentFont = False
        Properties.ItemHeight = 22
        Properties.MaxLength = 15
        Properties.ReadOnly = True
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 1
        Width = 196
      end
      object cxLabel5: TcxLabel
        Left = 11
        Top = 148
        Caption = #36710#29260#21495#30721':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object EditTruck: TcxComboBox
        Left = 126
        Top = 148
        ParentFont = False
        Properties.ItemHeight = 22
        Properties.MaxLength = 15
        Properties.ReadOnly = True
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 3
        Width = 196
      end
      object cxLabel7: TcxLabel
        Left = 11
        Top = 180
        Caption = #23458#25143#21517#31216':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object EditCusID: TcxComboBox
        Left = 126
        Top = 180
        ParentFont = False
        Properties.DropDownRows = 20
        Properties.ImmediateDropDown = False
        Properties.IncrementalSearch = False
        Properties.ItemHeight = 22
        Properties.ReadOnly = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 5
        Width = 196
      end
      object cxLabel8: TcxLabel
        Left = 11
        Top = 212
        Caption = #29289#26009#21517#31216':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object EditStockID: TcxComboBox
        Left = 126
        Top = 212
        ParentFont = False
        Properties.DropDownRows = 20
        Properties.ImmediateDropDown = False
        Properties.IncrementalSearch = False
        Properties.ItemHeight = 22
        Properties.ReadOnly = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 7
        Width = 196
      end
      object cxLabel6: TcxLabel
        Left = 11
        Top = 19
        Caption = #38480' '#36733' '#37327':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object EditMaxValue: TcxTextEdit
        Left = 126
        Top = 18
        ParentFont = False
        Properties.ReadOnly = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 9
        Text = '0'
        Width = 196
      end
      object cxLabel1: TcxLabel
        Left = 11
        Top = 51
        Caption = #30382'    '#37325':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object editPValue: TcxTextEdit
        Left = 126
        Top = 50
        ParentFont = False
        Properties.ReadOnly = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 11
        Text = '0'
        Width = 196
      end
      object cxLabel2: TcxLabel
        Left = 11
        Top = 83
        Caption = #24320' '#21333' '#37327':'
        ParentFont = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -23
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
      end
      object editZValue: TcxTextEdit
        Left = 126
        Top = 82
        ParentFont = False
        Properties.ReadOnly = False
        Style.Font.Charset = GB2312_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -20
        Style.Font.Name = #24188#22278
        Style.Font.Style = []
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 13
        Text = '0'
        Width = 196
      end
    end
    object editNetValue: TLEDFontNum
      Left = 66
      Top = 180
      Width = 98
      Height = 33
      OffSetX = 3
      OffSetY = 6
      WordWidth = 14
      WordHeight = 21
      Thick = 2
      Space = 5
      Text = '12345'
      AutoSize = False
      DrawDarkColor = False
    end
    object editBiLi: TLEDFontNum
      Left = 238
      Top = 180
      Width = 98
      Height = 33
      OffSetX = 3
      OffSetY = 6
      WordWidth = 14
      WordHeight = 21
      Thick = 2
      Space = 5
      Text = '12345'
      AutoSize = False
      DrawDarkColor = False
    end
    object cxLabel3: TcxLabel
      Left = 8
      Top = 184
      Caption = #20928#37325':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object cxLabel9: TcxLabel
      Left = 179
      Top = 184
      Caption = #27604#20363':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object btnSetOpen: TButton
      Left = 112
      Top = 476
      Width = 63
      Height = 25
      Caption = #38400#24230
      TabOrder = 9
      OnClick = btnSetOpenClick
    end
    object editOpenValue: TcxCurrencyEdit
      Left = 21
      Top = 478
      EditValue = 80.000000000000000000
      Properties.DisplayFormat = '0;-0'
      Properties.MaxValue = 100.000000000000000000
      TabOrder = 10
      Width = 83
    end
    object editFD: TcxTextEdit
      Left = 291
      Top = 125
      TabOrder = 11
      Text = '0'
      Width = 51
    end
    object Button1: TButton
      Left = 290
      Top = 475
      Width = 53
      Height = 25
      Caption = #35835#30917
      TabOrder = 12
      OnClick = Button1Click
    end
    object btnHandCtrl: TButton
      Left = 192
      Top = 477
      Width = 75
      Height = 25
      Caption = #20999#25442#25163#21160
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 13
      OnClick = btnHandCtrlClick
    end
    object pnlAction: TPanel
      Left = 16
      Top = 126
      Width = 33
      Height = 39
      TabOrder = 14
      object lblAction: TLabel
        Left = 1
        Top = 1
        Width = 30
        Height = 37
        AutoSize = False
        Caption = '='
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -32
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object Button2: TButton
      Left = 296
      Top = 512
      Width = 41
      Height = 22
      Caption = #28165#23631
      TabOrder = 15
      OnClick = Button2Click
    end
  end
  object pnlError: TPanel
    Left = 0
    Top = 547
    Width = 368
    Height = 108
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlFanErr: TPanel
      Left = 0
      Top = 84
      Width = 368
      Height = 21
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = #39118#26426#26410#22791#22949
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      Visible = False
    end
    object pnlTotle: TPanel
      Left = 0
      Top = 63
      Width = 368
      Height = 21
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = #31995#32479#24635#25925#38556
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Visible = False
    end
    object pnlSignalErr: TPanel
      Left = 0
      Top = 42
      Width = 368
      Height = 21
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = #36890#20449#25925#38556
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Visible = False
    end
    object pnlMoveErr: TPanel
      Left = 0
      Top = 21
      Width = 368
      Height = 21
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = #31227#21160#26426#25925#38556
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      Visible = False
    end
    object pnlUpErr: TPanel
      Left = 0
      Top = 0
      Width = 368
      Height = 21
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = #25552#21319#26426#25925#38556
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      Visible = False
    end
  end
  object tmrUp: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrUpTimer
    Left = 128
    Top = 64
  end
  object tmrDown: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrDownTimer
    Left = 160
    Top = 72
  end
end
