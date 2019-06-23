inherited fFormSealNum: TfFormSealNum
  Caption = #23553#31614#21495#24405#20837
  ClientHeight = 138
  ClientWidth = 282
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 282
    Height = 138
    inherited BtnOK: TButton
      Left = 136
      Top = 105
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 206
      Top = 105
      TabOrder = 3
    end
    object EditCard: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object EditSealNum: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 1
      OnKeyPress = EditSealNumKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #30913#21345#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23553#31614#32534#21495':'
          Control = EditSealNum
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalMultiplier = 10
    Timeouts.ReadTotalConstant = 100
    OnRxChar = ComPort1RxChar
    Left = 22
    Top = 84
  end
end
