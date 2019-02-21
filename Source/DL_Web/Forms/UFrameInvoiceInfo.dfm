inherited fFrameInvoiceInfo: TfFrameInvoiceInfo
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
    end
    inherited PanelQuick: TUniSimplePanel
      Height = 0
      ExplicitHeight = 0
    end
    inherited DBGridMain: TUniDBGrid
      Top = 46
      Height = 544
    end
  end
end
