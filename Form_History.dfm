object FrHistory: TFrHistory
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FrHistory'
  ClientHeight = 308
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 536
    Height = 265
    Align = alTop
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object BitBtn1: TBitBtn
    Left = 224
    Top = 275
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object DataSource1: TDataSource
    Left = 136
    Top = 8
  end
end
