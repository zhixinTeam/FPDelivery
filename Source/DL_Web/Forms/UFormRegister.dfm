inherited fFormRegister: TfFormRegister
  ClientHeight = 405
  ClientWidth = 444
  Caption = 'fFormRegister'
  ExplicitWidth = 450
  ExplicitHeight = 433
  PixelsPerInch = 96
  TextHeight = 12
  inherited BtnOK: TUniButton
    Left = 278
    Top = 371
    ExplicitLeft = 278
    ExplicitTop = 371
  end
  inherited BtnExit: TUniButton
    Left = 361
    Top = 371
    ExplicitLeft = 361
    ExplicitTop = 371
  end
  inherited PanelWork: TUniSimplePanel
    Top = 10
    Width = 428
    Height = 355
    ExplicitTop = 10
    ExplicitWidth = 428
    ExplicitHeight = 355
    object UniLabel1: TUniLabel
      Left = 13
      Top = 19
      Width = 60
      Height = 12
      Hint = ''
      Caption = #30331' '#24405' '#21517#65306
      TabOrder = 1
    end
    object editName: TUniEdit
      Left = 79
      Top = 15
      Width = 147
      Hint = ''
      Text = ''
      TabOrder = 2
    end
    object UniLabel2: TUniLabel
      Left = 12
      Top = 44
      Width = 60
      Height = 12
      Hint = ''
      Caption = #23494#12288#12288#30721#65306
      TabOrder = 3
    end
    object editPsd: TUniEdit
      Left = 79
      Top = 44
      Width = 147
      Hint = ''
      PasswordChar = '*'
      Text = ''
      TabOrder = 4
    end
    object UniLabel3: TUniLabel
      Left = 12
      Top = 73
      Width = 60
      Height = 12
      Hint = ''
      Caption = #30830#35748#23494#30721#65306
      TabOrder = 5
    end
    object editPsd2: TUniEdit
      Left = 79
      Top = 73
      Width = 147
      Hint = ''
      PasswordChar = '*'
      CharEOL = '*'
      Text = ''
      TabOrder = 6
    end
    object UniLabel4: TUniLabel
      Left = 232
      Top = 19
      Width = 186
      Height = 12
      Hint = ''
      Caption = #33521#25991#23383#27597#25110#27721#23383','#19981#21487#21253#21547#29305#27530#23383#31526
      TabOrder = 7
    end
    object UniLabel5: TUniLabel
      Left = 13
      Top = 106
      Width = 60
      Height = 12
      Hint = ''
      Caption = #32852' '#31995' '#20154#65306
      TabOrder = 8
    end
    object editLxr: TUniEdit
      Left = 79
      Top = 102
      Width = 147
      Hint = ''
      Text = ''
      TabOrder = 9
    end
    object UniLabel6: TUniLabel
      Left = 12
      Top = 131
      Width = 60
      Height = 12
      Hint = ''
      Caption = #32852#31995#30005#35805#65306
      TabOrder = 10
    end
    object editTel: TUniEdit
      Left = 79
      Top = 131
      Width = 147
      Hint = ''
      Text = ''
      TabOrder = 11
    end
    object UniLabel7: TUniLabel
      Left = 13
      Top = 164
      Width = 60
      Height = 12
      Hint = ''
      Caption = #20844#21496#21517#31216#65306
      TabOrder = 12
    end
    object editCompany: TUniEdit
      Left = 79
      Top = 160
      Width = 339
      Hint = ''
      Text = ''
      TabOrder = 13
    end
    object UniLabel8: TUniLabel
      Left = 12
      Top = 189
      Width = 60
      Height = 12
      Hint = ''
      Caption = #22791#27880#20449#24687#65306
      TabOrder = 14
    end
    object Memo: TUniMemo
      Left = 80
      Top = 188
      Width = 338
      Height = 97
      Hint = ''
      TabOrder = 15
    end
    object UniCheckBox1: TUniCheckBox
      Left = 13
      Top = 292
      Width = 76
      Height = 17
      Hint = ''
      Caption = #25552#36135#23458#25143
      TabOrder = 16
    end
    object UniLabel9: TUniLabel
      Left = 13
      Top = 318
      Width = 60
      Height = 12
      Hint = ''
      Caption = #33829#19994#25191#29031#65306
      TabOrder = 17
    end
    object UniButton1: TUniButton
      Left = 79
      Top = 313
      Width = 98
      Height = 25
      Hint = ''
      Caption = #19978#20256#33829#19994#25191#29031
      TabOrder = 18
      OnClick = UniButton1Click
    end
    object UniButton2: TUniButton
      Left = 199
      Top = 313
      Width = 98
      Height = 25
      Hint = ''
      Visible = False
      Caption = #19978#20256#36523#20221#35777#29031#29255
      TabOrder = 19
      OnClick = UniButton1Click
    end
  end
  object UniFileUpload1: TUniFileUpload
    OnCompleted = UniFileUpload1Completed
    Title = #19978#20256#25991#20214
    Messages.Uploading = #19978#20256#20013'...'
    Messages.PleaseWait = #35831#31561#24453'.'
    Messages.Cancel = #21462#28040
    Messages.Processing = 'Processing...'
    Messages.UploadError = #19978#20256#38169#35823','#35831#37325#35797'.'
    Messages.Upload = #19978#20256
    Messages.NoFileError = #35831#36873#25321#38656#35201#19978#20256#30340#25991#20214'.'
    Messages.BrowseText = #27983#35272'...'
    Left = 120
    Top = 242
  end
end
