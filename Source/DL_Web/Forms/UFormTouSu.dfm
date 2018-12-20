inherited fFormTouSu: TfFormTouSu
  ClientHeight = 295
  ClientWidth = 422
  Caption = #25237#35785#31649#29702
  ExplicitWidth = 428
  ExplicitHeight = 323
  PixelsPerInch = 96
  TextHeight = 12
  inherited BtnOK: TUniButton
    Left = 256
    Top = 261
    ExplicitLeft = 256
    ExplicitTop = 261
  end
  inherited BtnExit: TUniButton
    Left = 339
    Top = 261
    ExplicitLeft = 339
    ExplicitTop = 261
  end
  inherited PanelWork: TUniSimplePanel
    Width = 406
    Height = 245
    ExplicitWidth = 406
    ExplicitHeight = 245
    object UniLabel1: TUniLabel
      Left = 7
      Top = 20
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25237#35785#26631#39064':'
      TabOrder = 1
    end
    object EditTitle: TUniEdit
      Left = 65
      Top = 15
      Width = 328
      Hint = ''
      MaxLength = 32
      Text = ''
      TabOrder = 2
    end
    object UniLabel2: TUniLabel
      Left = 5
      Top = 43
      Width = 54
      Height = 12
      Hint = ''
      Caption = #25237#35785#20869#23481':'
      TabOrder = 3
    end
    object editText: TUniMemo
      Left = 65
      Top = 44
      Width = 328
      Height = 141
      Hint = ''
      TabOrder = 4
    end
    object lblSH: TUniLabel
      Left = 7
      Top = 212
      Width = 54
      Height = 12
      Hint = ''
      Visible = False
      Caption = #23457#26680#24847#35265':'
      TabOrder = 5
    end
    object editSH: TUniEdit
      Left = 65
      Top = 207
      Width = 328
      Hint = ''
      Visible = False
      MaxLength = 32
      Text = ''
      TabOrder = 6
    end
  end
end
