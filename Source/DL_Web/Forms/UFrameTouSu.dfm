inherited fFrameTouSu: TfFrameTouSu
  inherited PanelWork: TUniContainerPanel
    inherited UniToolBar1: TUniToolBar
      inherited BtnAdd: TUniToolButton
        OnClick = BtnAddClick
      end
      inherited BtnEdit: TUniToolButton
        OnClick = BtnEditClick
      end
      inherited BtnDel: TUniToolButton
        OnClick = BtnDelClick
      end
      object btnSH: TUniToolButton [4]
        Left = 269
        Top = 0
        Hint = ''
        ImageIndex = 8
        Caption = #23457#26680
        TabOrder = 12
        OnClick = btnSHClick
      end
      inherited BtnRefresh: TUniToolButton
        Left = 356
        ExplicitLeft = 356
      end
      inherited UniToolButton10: TUniToolButton
        Left = 443
        ExplicitLeft = 443
      end
      inherited BtnPrint: TUniToolButton
        Left = 451
        ExplicitLeft = 451
      end
      inherited BtnPreview: TUniToolButton
        Left = 538
        ExplicitLeft = 538
      end
      inherited BtnExport: TUniToolButton
        Left = 625
        ExplicitLeft = 625
      end
      inherited UniToolButton11: TUniToolButton
        Left = 712
        ExplicitLeft = 712
      end
      inherited BtnExit: TUniToolButton
        Left = 720
        ExplicitLeft = 720
      end
    end
    inherited PanelQuick: TUniSimplePanel
      object Label1: TUniLabel
        Left = 12
        Top = 17
        Width = 42
        Height = 12
        Hint = ''
        Caption = #25237#35785#20154':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditID: TUniEdit
        Left = 58
        Top = 12
        Width = 125
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        EmptyText = #26597#25214
        OnKeyPress = EditIDKeyPress
      end
      object Label2: TUniLabel
        Left = 201
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #25237#35785#26631#39064':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 3
      end
      object EditTitle: TUniEdit
        Left = 261
        Top = 12
        Width = 148
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 4
        EmptyText = #26597#25214
        OnKeyPress = EditIDKeyPress
      end
      object Label3: TUniLabel
        Left = 435
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 5
      end
      object EditDate: TUniEdit
        Left = 495
        Top = 12
        Width = 185
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 6
        EmptyText = #26597#25214
        ReadOnly = True
      end
      object BtnDateFilter: TUniBitBtn
        Left = 682
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 7
        OnClick = BtnDateFilterClick
      end
    end
    inherited DBGridMain: TUniDBGrid
      OnDblClick = DBGridMainDblClick
    end
  end
end
