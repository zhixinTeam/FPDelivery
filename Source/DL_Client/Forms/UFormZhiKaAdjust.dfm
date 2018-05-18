inherited fFormZhiKaAdjust: TfFormZhiKaAdjust
  Left = 574
  Top = 233
  ClientHeight = 428
  ClientWidth = 412
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 412
    Height = 428
    OptionsItem.AutoControlAreaAlignment = False
    inherited BtnOK: TButton
      Left = 266
      Top = 395
      Caption = #30830#23450
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 336
      Top = 395
      TabOrder = 9
    end
    object Radio3: TcxRadioButton [2]
      Left = 23
      Top = 336
      Width = 113
      Height = 17
      Caption = #26032#35746#21333#26367#25442#21407#26377#35746#21333
      Checked = True
      ParentColor = False
      TabOrder = 6
      TabStop = True
    end
    object Radio1: TcxRadioButton [3]
      Left = 23
      Top = 217
      Width = 113
      Height = 18
      Caption = #21407#26377#35746#21333#20445#25345#19981#21464
      ParentColor = False
      TabOrder = 2
    end
    object Radio2: TcxRadioButton [4]
      Left = 23
      Top = 277
      Width = 113
      Height = 17
      Caption = #21407#26377#35746#21333#38480#21046#25552#36135#37327
      ParentColor = False
      TabOrder = 4
    end
    object cxLabel1: TcxLabel [5]
      Left = 23
      Top = 240
      AutoSize = False
      Caption = '  '#23458#25143#23558#20351#29992#26032#35746#21333#21644#21407#26377#35746#21333#27491#24120#25552#36135','#33509#26032#26087#35746#21333#27700#27877#21517#31216#30456#21516','#21017#20250#20986#29616#21516#21697#31181#19981#21516#21333#20215#30340#24773#20917','#35831#24910#37325#36873#25321#35813#39033'.'
      ParentFont = False
      Properties.WordWrap = True
      Transparent = True
      Height = 32
      Width = 380
    end
    object cxLabel2: TcxLabel [6]
      Left = 23
      Top = 299
      AutoSize = False
      Caption = '  '#23458#25143#21407#26377#35746#21333#19981#21464','#21487#25552#36135#24635#37329#39069#31561#20110#24403#21069#30340#36134#25143#36164#37329#20313#39069'('#21487#29992#37329#39069'),'#36164#37329#20351#29992#23436#27605#21518#33258#21160#20316#24223'.'
      ParentFont = False
      Properties.WordWrap = True
      Transparent = True
      Height = 32
      Width = 380
    end
    object cxLabel3: TcxLabel [7]
      Left = 23
      Top = 358
      AutoSize = False
      Caption = '  '#23458#25143#21407#26377#35746#21333#20316#24223','#20351#29992#26032#30340#35746#21333#21333#20215#25552#36135'.'
      ParentFont = False
      Properties.WordWrap = True
      Transparent = True
      Height = 25
      Width = 372
    end
    object cxLabel4: TcxLabel [8]
      Left = 23
      Top = 36
      AutoSize = False
      Caption = #20197#19979#26159#24403#21069#27491#22312#20351#29992#30340#35746#21333#21015#34920','#35831#24744#20570#20986#36866#24403#30340#35843#25972','#20197#20415#26032#35746#21333#21487#20197#27491#24120#20351#29992':'
      ParentFont = False
      Properties.WordWrap = True
      Transparent = True
      Height = 32
      Width = 380
    end
    object ListZK: TcxListView [9]
      Left = 23
      Top = 73
      Width = 355
      Height = 95
      Columns = <
        item
          Caption = #35746#21333#32534#21495
          Width = 75
        end
        item
          Caption = #25552#36135#26041#24335
          Width = 75
        end
        item
          Caption = #21150#29702#20154
          Width = 75
        end
        item
          Caption = #21150#29702#26102#38388
          Width = 75
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = ListZKDblClick
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = #32440#21345#21015#34920
        object dxLayout1Item9: TdxLayoutItem
          AlignHorz = ahClient
          CaptionOptions.Text = 'cxLabel4'
          CaptionOptions.Visible = False
          Control = cxLabel4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          AlignVert = avClient
          CaptionOptions.Text = 'cxListView1'
          CaptionOptions.Visible = False
          Control = ListZK
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AlignVert = avBottom
        CaptionOptions.Text = #22788#29702#26041#27861
        ButtonOptions.Buttons = <>
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = 'cxRadioButton2'
          CaptionOptions.Visible = False
          Control = Radio1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          CaptionOptions.Text = 'cxLabel1'
          CaptionOptions.Visible = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = 'cxRadioButton3'
          CaptionOptions.Visible = False
          Control = Radio2
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = 'cxLabel2'
          CaptionOptions.Visible = False
          Control = cxLabel2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = 'cxRadioButton1'
          CaptionOptions.Visible = False
          Control = Radio3
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          CaptionOptions.Text = 'cxLabel3'
          CaptionOptions.Visible = False
          Control = cxLabel3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
