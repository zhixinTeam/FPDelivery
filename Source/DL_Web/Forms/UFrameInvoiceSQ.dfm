inherited fFrameInvoiceSQ: TfFrameInvoiceSQ
  inherited PanelWork: TUniContainerPanel
    inherited PanelQuick: TUniSimplePanel
      object Label3: TUniLabel
        Left = 27
        Top = 17
        Width = 54
        Height = 12
        Hint = ''
        Caption = #26085#26399#31579#36873':'
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 1
      end
      object EditDate: TUniEdit
        Left = 87
        Top = 12
        Width = 185
        Hint = ''
        Text = ''
        ParentFont = False
        Font.Charset = GB2312_CHARSET
        Font.Height = -12
        Font.Name = #23435#20307
        TabOrder = 2
        EmptyText = #26597#25214
        ReadOnly = True
      end
      object BtnDateFilter: TUniBitBtn
        Left = 274
        Top = 12
        Width = 25
        Height = 22
        Hint = ''
        Caption = '...'
        TabOrder = 3
      end
    end
  end
  inherited DataSource1: TDataSource
    Left = 128
  end
end
