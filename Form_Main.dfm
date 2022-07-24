object FrMain: TFrMain
  Left = 0
  Top = 0
  Caption = 'FrMain'
  ClientHeight = 280
  ClientWidth = 750
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object BTNSTART: TSpeedButton
    Left = 16
    Top = 120
    Width = 145
    Height = 22
    Caption = 'Iniciar Download'
    OnClick = BTNSTARTClick
  end
  object BTNMSG: TSpeedButton
    Left = 16
    Top = 148
    Width = 145
    Height = 22
    Caption = 'Exibir mensagem'
    OnClick = BTNMSGClick
  end
  object BTNSTOP: TSpeedButton
    Left = 16
    Top = 176
    Width = 145
    Height = 22
    Caption = 'Parar download'
    OnClick = BTNSTOPClick
  end
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 21
    Height = 15
    Caption = 'URL'
  end
  object Label2: TLabel
    Left = 16
    Top = 67
    Width = 49
    Height = 15
    Caption = 'Local File'
  end
  object BTNHISTORY: TSpeedButton
    Left = 552
    Top = 232
    Width = 177
    Height = 22
    Caption = 'Exibir hist'#243'rico de downloads'
    OnClick = BTNHISTORYClick
  end
  object URL: TEdit
    Left = 16
    Top = 23
    Width = 713
    Height = 23
    TabOrder = 0
    Text = 
      'https://az764295.vo.msecnd.net/stable/78a4c91400152c0f27ba4d363e' +
      'b56d2835f9903a/VSCodeUserSetup-x64-1.43.0.exe'
  end
  object LOCAL_FILE: TEdit
    Left = 16
    Top = 80
    Width = 713
    Height = 23
    TabOrder = 1
    Text = 'd:\test.exe'
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 204
    Width = 713
    Height = 17
    TabOrder = 2
  end
  object lbMessage: TListBox
    Left = 176
    Top = 120
    Width = 553
    Height = 78
    ItemHeight = 15
    TabOrder = 3
  end
end
