inherited fFrameFP: TfFrameFP
  inherited PanelWork: TUniContainerPanel
    inherited UniToolBar1: TUniToolBar
      inherited BtnAdd: TUniToolButton
        Caption = #28155#21152#30003#35831
        OnClick = BtnAddClick
      end
      inherited BtnEdit: TUniToolButton
        Visible = False
        ExplicitLeft = 81
        ExplicitTop = 1
      end
      inherited BtnDel: TUniToolButton
        Visible = False
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
