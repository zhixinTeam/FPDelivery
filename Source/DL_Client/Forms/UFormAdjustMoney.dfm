inherited fFormAdjustMoney: TfFormAdjustMoney
  Left = 508
  Top = 262
  Caption = #36134#25143#35843#25320
  ClientHeight = 332
  ClientWidth = 318
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 318
    Height = 332
    inherited BtnOK: TButton
      Left = 172
      Top = 299
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 242
      Top = 299
      TabOrder = 5
    end
    object cxGroupBox1: TcxGroupBox [2]
      Left = 23
      Top = 36
      Caption = #35843#20986#36134#25143
      Ctl3D = True
      ParentColor = False
      ParentCtl3D = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clWindow
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      Transparent = True
      Height = 84
      Width = 268
      object eEditOutNo: TcxTextEdit
        Left = 81
        Top = 22
        ParentFont = False
        Properties.ReadOnly = True
        TabOrder = 0
        Width = 177
      end
      object cxLabel1: TcxLabel
        Left = 16
        Top = 23
        Caption = #36134#25143#32534#21495#65306
        ParentFont = False
        Transparent = True
      end
      object cxlabel2: TcxLabel
        Left = 16
        Top = 52
        Caption = #36134#25143#21517#31216#65306
        ParentFont = False
        Transparent = True
      end
      object eEditOutName: TcxComboBox
        Left = 82
        Top = 50
        ParentFont = False
        Properties.OnChange = eEditOutNamePropertiesChange
        TabOrder = 3
        Width = 177
      end
    end
    object cxGroupBox2: TcxGroupBox [3]
      Left = 23
      Top = 208
      Caption = #35843#25320#37329#39069
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clWindow
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      Transparent = True
      Height = 51
      Width = 315
      object EditMoney: TcxCurrencyEdit
        Left = 81
        Top = 20
        ParentFont = False
        TabOrder = 0
        Width = 177
      end
      object cxLabel5: TcxLabel
        Left = 16
        Top = 22
        Caption = #35843#25320#37329#39069#65306
        ParentFont = False
        Transparent = True
      end
    end
    object cxGroupBox3: TcxGroupBox [4]
      Left = 23
      Top = 125
      Caption = #35843#20837#36134#25143
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Color = clWindow
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 1
      Transparent = True
      Height = 78
      Width = 268
      object eEditInName: TcxComboBox
        Left = 80
        Top = 45
        ParentFont = False
        Properties.OnChange = eEditInNamePropertiesChange
        TabOrder = 0
        Width = 177
      end
      object eEditInNo: TcxTextEdit
        Left = 80
        Top = 16
        ParentFont = False
        Properties.ReadOnly = True
        TabOrder = 1
        Width = 177
      end
      object cxLabel3: TcxLabel
        Left = 16
        Top = 19
        Caption = #23458#25143#32534#21495#65306
        ParentFont = False
        Transparent = True
      end
      object cxLabel4: TcxLabel
        Left = 16
        Top = 48
        Caption = #36134#25143#21517#31216#65306
        ParentFont = False
        Transparent = True
      end
    end
    object editMemo: TcxTextEdit [5]
      Left = 63
      Top = 264
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = 'cxGroupBox1'
          CaptionOptions.Visible = False
          Control = cxGroupBox1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          CaptionOptions.Text = 'cxGroupBox3'
          CaptionOptions.Visible = False
          Control = cxGroupBox3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = 'cxGroupBox2'
          CaptionOptions.Visible = False
          Control = cxGroupBox2
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          CaptionOptions.Text = #22791#27880#65306
          Control = editMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
