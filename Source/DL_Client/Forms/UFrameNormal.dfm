inherited fFrameNormal: TfFrameNormal
  Width = 652
  Height = 376
  Font.Height = -13
  Font.Name = #24494#36719#38597#40657
  ParentBackground = False
  object ToolBar1: TToolBar
    Left = 0
    Top = 22
    Width = 652
    Height = 42
    ButtonHeight = 42
    ButtonWidth = 59
    EdgeBorders = []
    Flat = True
    Images = FDM.ImageBar
    ShowCaptions = True
    TabOrder = 0
    OnAdvancedCustomDraw = ToolBar1AdvancedCustomDraw
    object BtnAdd: TToolButton
      Left = 0
      Top = 0
      Caption = #28155#21152
      ImageIndex = 0
    end
    object BtnEdit: TToolButton
      Left = 59
      Top = 0
      Caption = #20462#25913
      ImageIndex = 1
    end
    object BtnDel: TToolButton
      Left = 118
      Top = 0
      Caption = #21024#38500
      ImageIndex = 2
    end
    object S1: TToolButton
      Left = 177
      Top = 0
      Width = 8
      Caption = 'S1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object BtnRefresh: TToolButton
      Left = 185
      Top = 0
      Caption = #21047#26032
      ImageIndex = 14
      OnClick = BtnRefreshClick
    end
    object S2: TToolButton
      Left = 244
      Top = 0
      Width = 8
      Caption = 'S2'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object BtnPrint: TToolButton
      Left = 252
      Top = 0
      Caption = #25171#21360
      ImageIndex = 3
      OnClick = BtnPrintClick
    end
    object BtnPreview: TToolButton
      Left = 311
      Top = 0
      Caption = #25171#21360#39044#35272
      ImageIndex = 4
      OnClick = BtnPreviewClick
    end
    object BtnExport: TToolButton
      Left = 370
      Top = 0
      Caption = #23548#20986
      ImageIndex = 5
      OnClick = BtnExportClick
    end
    object S3: TToolButton
      Left = 429
      Top = 0
      Width = 8
      Caption = 'S3'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object BtnExit: TToolButton
      Left = 437
      Top = 0
      Caption = '   '#20851#38381'   '
      ImageIndex = 7
      OnClick = BtnExitClick
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 195
    Width = 652
    Height = 181
    Align = alClient
    BorderStyle = cxcbsNone
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #24494#36719#38597#40657
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object cxView1: TcxGridDBTableView
      OnKeyPress = cxView1KeyPress
      NavigatorButtons.ConfirmDelete = False
      OnCustomDrawCell = cxView1CustomDrawCell
      OnFocusedRecordChanged = cxView1FocusedRecordChanged
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      DataController.OnGroupingChanged = cxView1DataControllerGroupingChanged
      OptionsView.DataRowHeight = 22
      OptionsView.GridLineColor = 15395562
    end
    object cxLevel1: TcxGridLevel
      GridView = cxView1
    end
  end
  object dxLayout1: TdxLayoutControl
    Left = 0
    Top = 64
    Width = 652
    Height = 123
    Align = alTop
    BevelEdges = [beLeft, beRight, beBottom]
    TabOrder = 2
    TabStop = False
    AutoContentSizes = [acsWidth]
    AutoControlAlignment = False
    LookAndFeel = FDM.dxLayoutWeb1
    object dxGroup1: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object GroupSearch1: TdxLayoutGroup
        Caption = #24555#36895#26597#35810
        LayoutDirection = ldHorizontal
      end
      object GroupDetail1: TdxLayoutGroup
        Caption = #31616#26126#20449#24687
        LayoutDirection = ldHorizontal
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 187
    Width = 652
    Height = 8
    HotZoneClassName = 'TcxXPTaskBarStyle'
    AlignSplitter = salTop
    Control = dxLayout1
  end
  object TitlePanel1: TZnBitmapPanel
    Left = 0
    Top = 0
    Width = 652
    Height = 22
    Align = alTop
    object TitleBar: TcxLabel
      Left = 0
      Top = 0
      Align = alClient
      AutoSize = False
      Caption = 'title'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Edges = [bBottom]
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -12
      Style.Font.Name = #23435#20307
      Style.Font.Style = []
      Style.TextColor = clGray
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Properties.LabelEffect = cxleExtrude
      Properties.LabelStyle = cxlsLowered
      Properties.ShadowedColor = clBlack
      Transparent = True
      Height = 22
      Width = 652
      AnchorX = 326
      AnchorY = 11
    end
  end
  object SQLQuery: TADOQuery
    Connection = FDM.ADOConn
    Parameters = <>
    Left = 6
    Top = 202
  end
  object DataSource1: TDataSource
    DataSet = SQLQuery
    Left = 33
    Top = 202
  end
end
