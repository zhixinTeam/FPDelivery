inherited fFormStockItem: TfFormStockItem
  Left = 288
  Top = 142
  Width = 630
  Height = 547
  Caption = #29289#26009#31649#29702
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayout1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 614
    Height = 509
    Align = alClient
    TabOrder = 0
    TabStop = False
    LayoutLookAndFeel = FDM.dxLayoutWeb1
    OptionsItem.AutoControlAreaAlignment = False
    object BtnEdit: TButton
      Left = 453
      Top = 469
      Width = 65
      Height = 22
      Caption = #20462#25913
      TabOrder = 2
      OnClick = BtnEditClick
    end
    object BtnDel: TButton
      Left = 523
      Top = 469
      Width = 65
      Height = 22
      Caption = #21024#38500
      TabOrder = 3
      OnClick = BtnDelClick
    end
    object cxPG1: TcxPageControl
      Left = 35
      Top = 43
      Width = 541
      Height = 414
      ActivePage = cxTabSheet1
      Align = alClient
      ParentColor = False
      TabOrder = 0
      OnChange = cxPG1Change
      ClientRectBottom = 414
      ClientRectRight = 541
      ClientRectTop = 23
      object cxTabSheet1: TcxTabSheet
        Caption = #29289#26009#31649#29702
        ImageIndex = 0
        object cxGrid2: TcxGrid
          Left = 0
          Top = 0
          Width = 541
          Height = 341
          Align = alClient
          BorderStyle = cxcbsNone
          TabOrder = 0
          object cxView1: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            OnCellClick = cxView1CellClick
            DataController.DataSource = DataSource1
            DataController.KeyFieldNames = 'D_ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Editing = False
            object cxView1Column2: TcxGridDBColumn
              Caption = #29289#26009#32534#21495
              DataBinding.FieldName = 'd_paramb'
              HeaderAlignmentHorz = taCenter
              Width = 165
            end
            object cxView1Column1: TcxGridDBColumn
              Caption = #29289#26009#21517#31216
              DataBinding.FieldName = 'd_value'
              HeaderAlignmentHorz = taCenter
              Width = 185
            end
            object cxView1Column3: TcxGridDBColumn
              Caption = #31867#22411
              DataBinding.FieldName = 'd_memo'
              HeaderAlignmentHorz = taCenter
              Width = 148
            end
          end
          object cxLevel1: TcxGridLevel
            GridView = cxView1
          end
        end
        object Panel1: TPanel
          Left = 0
          Top = 341
          Width = 541
          Height = 50
          Align = alBottom
          TabOrder = 1
          object cbxType: TcxComboBox
            Left = 441
            Top = 15
            ParentFont = False
            Properties.DropDownListStyle = lsEditFixedList
            Properties.Items.Strings = (
              #34955#35013
              #25955#35013)
            Properties.MaxLength = 0
            TabOrder = 0
            Text = #34955#35013
            Width = 87
          end
          object EditStockNo: TcxTextEdit
            Left = 68
            Top = 15
            ParentFont = False
            TabOrder = 1
            Width = 103
          end
          object EditStockName: TcxTextEdit
            Left = 244
            Top = 15
            ParentFont = False
            TabOrder = 2
            Width = 141
          end
          object cxLabel1: TcxLabel
            Left = 8
            Top = 17
            Caption = #29289#26009#32534#21495#65306
            ParentFont = False
          end
          object cxLabel2: TcxLabel
            Left = 185
            Top = 17
            Caption = #29289#26009#21517#31216#65306
            ParentFont = False
          end
          object cxLabel3: TcxLabel
            Left = 402
            Top = 17
            Caption = #31867#22411#65306
            ParentFont = False
          end
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = #26085#21457#36135#37327
        ImageIndex = 1
        object cxGrid3: TcxGrid
          Left = 0
          Top = 0
          Width = 541
          Height = 341
          Align = alClient
          BorderStyle = cxcbsNone
          TabOrder = 0
          object cxGridDBTableView1: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            OnCellClick = cxView1CellClick
            DataController.DataSource = DataSource1
            DataController.KeyFieldNames = 'D_ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Editing = False
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = #29289#26009#32534#21495
              DataBinding.FieldName = 'd_value'
              HeaderAlignmentHorz = taCenter
              Width = 165
            end
            object cxGridDBColumn1: TcxGridDBColumn
              Caption = #29289#26009#21517#31216
              DataBinding.FieldName = 'd_memo'
              HeaderAlignmentHorz = taCenter
              Width = 185
            end
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = #38480#39069
              DataBinding.FieldName = 'd_ParamA'
              HeaderAlignmentHorz = taCenter
              Width = 148
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = cxGridDBTableView1
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 341
          Width = 541
          Height = 50
          Align = alBottom
          TabOrder = 1
          object cbStock: TcxComboBox
            Left = 65
            Top = 15
            ParentFont = False
            Properties.DropDownListStyle = lsEditFixedList
            Properties.MaxLength = 0
            TabOrder = 0
            Width = 192
          end
          object cxLabel4: TcxLabel
            Left = 8
            Top = 17
            Caption = #29289#26009#32534#21495#65306
            ParentFont = False
          end
          object cxLabel5: TcxLabel
            Left = 297
            Top = 17
            Caption = #38480#25552#25968#37327#65306
            ParentFont = False
          end
          object EditValue: TcxCurrencyEdit
            Left = 358
            Top = 14
            ParentFont = False
            Properties.DisplayFormat = '0.00;-0.00'
            Style.BorderColor = clWindowFrame
            Style.BorderStyle = ebsSingle
            Style.HotTrack = False
            TabOrder = 3
            Width = 136
          end
        end
      end
      object cxTabSheet3: TcxTabSheet
        Caption = #26816#39564#20869#25511#26631#20934
        ImageIndex = 2
        object cxGrid4: TcxGrid
          Left = 0
          Top = 0
          Width = 541
          Height = 341
          Align = alClient
          BorderStyle = cxcbsNone
          TabOrder = 0
          object cxGridDBTableView2: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            OnCellClick = cxView1CellClick
            DataController.DataSource = DataSource1
            DataController.KeyFieldNames = 'D_ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Editing = False
            object cxGridDBColumn4: TcxGridDBColumn
              Caption = #29289#26009#32534#21495
              DataBinding.FieldName = 'd_value'
              HeaderAlignmentHorz = taCenter
              Width = 142
            end
            object cxGridDBColumn5: TcxGridDBColumn
              Caption = #29289#26009#21517#31216
              DataBinding.FieldName = 'd_memo'
              HeaderAlignmentHorz = taCenter
              Width = 140
            end
            object cxGridDBColumn6: TcxGridDBColumn
              Caption = #26631#20934'1'
              DataBinding.FieldName = 'd_ParamA'
              HeaderAlignmentHorz = taCenter
              Width = 127
            end
            object cxGridDBTableView2Column1: TcxGridDBColumn
              Caption = #26631#20934'2'
              DataBinding.FieldName = 'd_ParamB'
              HeaderAlignmentHorz = taCenter
              Width = 118
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = cxGridDBTableView2
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 341
          Width = 541
          Height = 50
          Align = alBottom
          TabOrder = 1
          object cbCtrlStand: TcxComboBox
            Left = 80
            Top = 15
            ParentFont = False
            Properties.DropDownListStyle = lsEditFixedList
            Properties.MaxLength = 0
            TabOrder = 0
            Width = 166
          end
          object cxLabel6: TcxLabel
            Left = 5
            Top = 17
            Caption = #21407#26448#26009#21517#31216#65306
            ParentFont = False
          end
          object cxLabel7: TcxLabel
            Left = 265
            Top = 17
            Caption = #26631#20934'1'#65306
            ParentFont = False
          end
          object EditCtrlStandValue: TcxCurrencyEdit
            Left = 311
            Top = 14
            ParentFont = False
            Properties.DisplayFormat = '0.00;-0.00'
            Style.BorderColor = clWindowFrame
            Style.BorderStyle = ebsSingle
            Style.HotTrack = False
            TabOrder = 3
            Width = 67
          end
          object EditCtrlStandValue2: TcxCurrencyEdit
            Left = 440
            Top = 14
            ParentFont = False
            Properties.DisplayFormat = '0.00;-0.00'
            Style.BorderColor = clWindowFrame
            Style.BorderStyle = ebsSingle
            Style.HotTrack = False
            TabOrder = 4
            Width = 67
          end
          object cxLabel10: TcxLabel
            Left = 393
            Top = 17
            Caption = #26631#20934'2:'
            ParentFont = False
          end
        end
      end
      object cxTabSheet4: TcxTabSheet
        Caption = #26816#39564#35268#21017
        ImageIndex = 3
        object cxGrid5: TcxGrid
          Left = 0
          Top = 0
          Width = 541
          Height = 341
          Align = alClient
          BorderStyle = cxcbsNone
          TabOrder = 0
          object cxGridDBTableView3: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            OnCellClick = cxView1CellClick
            DataController.DataSource = DataSource1
            DataController.KeyFieldNames = 'D_ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Editing = False
            object cxGridDBColumn7: TcxGridDBColumn
              Caption = #29289#26009#32534#21495
              DataBinding.FieldName = 'd_value'
              HeaderAlignmentHorz = taCenter
              Width = 165
            end
            object cxGridDBColumn8: TcxGridDBColumn
              Caption = #29289#26009#21517#31216
              DataBinding.FieldName = 'd_memo'
              HeaderAlignmentHorz = taCenter
              Width = 185
            end
            object cxGridDBColumn9: TcxGridDBColumn
              Caption = #26816#39564#35268#21017
              DataBinding.FieldName = 'd_ParamA'
              HeaderAlignmentHorz = taCenter
              Width = 148
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = cxGridDBTableView3
          end
        end
        object Panel4: TPanel
          Left = 0
          Top = 341
          Width = 541
          Height = 50
          Align = alBottom
          TabOrder = 1
          object cbTestRules: TcxComboBox
            Left = 74
            Top = 15
            ParentFont = False
            Properties.DropDownListStyle = lsEditFixedList
            Properties.MaxLength = 0
            TabOrder = 0
            Width = 144
          end
          object cxLabel8: TcxLabel
            Left = 8
            Top = 17
            Caption = #29289#26009#32534#21495#65306
            ParentFont = False
          end
          object cxLabel9: TcxLabel
            Left = 265
            Top = 17
            Caption = #26816#39564#35268#21017#65306
            ParentFont = False
          end
          object EditTestRulesValue: TcxCurrencyEdit
            Left = 326
            Top = 14
            ParentFont = False
            Properties.DisplayFormat = '0.00;-0.00'
            Style.BorderColor = clWindowFrame
            Style.BorderStyle = ebsSingle
            Style.HotTrack = False
            TabOrder = 3
            Width = 136
          end
        end
      end
    end
    object BtnAdd: TButton
      Left = 383
      Top = 469
      Width = 65
      Height = 22
      Caption = #28155#21152
      TabOrder = 1
      OnClick = BtnAddClick
    end
    object dxLayoutGroup1: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      object dxLayout1Group5: TdxLayoutGroup
        ButtonOptions.Buttons = <>
        Hidden = True
        ShowBorder = False
        object dxLayout1Group1: TdxLayoutGroup
          AlignVert = avClient
          CaptionOptions.Text = #39033#30446#31867#22411
          ButtonOptions.Buttons = <>
          object dxLayout1Group3: TdxLayoutGroup
            AlignHorz = ahClient
            AlignVert = avClient
            ButtonOptions.Buttons = <>
            LayoutDirection = ldHorizontal
            object dxLayout1Item1: TdxLayoutItem
              AlignHorz = ahClient
              AlignVert = avClient
              Control = cxPG1
              ControlOptions.AutoColor = True
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutGroup2: TdxLayoutGroup
            AlignVert = avBottom
            CaptionOptions.Visible = False
            ButtonOptions.Buttons = <>
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item4: TdxLayoutItem
              AlignHorz = ahRight
              CaptionOptions.Text = 'Button1'
              CaptionOptions.Visible = False
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
            object dxLayoutItem1: TdxLayoutItem
              AlignHorz = ahRight
              CaptionOptions.Text = 'Button1'
              CaptionOptions.Visible = False
              Control = BtnEdit
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item2: TdxLayoutItem
              AlignHorz = ahRight
              CaptionOptions.Text = 'Button2'
              CaptionOptions.Visible = False
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
    end
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery
    Left = 48
    Top = 120
  end
  object ADOQuery: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 80
    Top = 120
  end
end
