object Prova: TProva
  Left = 0
  Top = 0
  Caption = 'Prova'
  ClientHeight = 320
  ClientWidth = 576
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object edtTotal: TEdit
    Left = 8
    Top = 35
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'total'
  end
  object btnDVDs: TButton
    Left = 24
    Top = 62
    Width = 75
    Height = 25
    Caption = 'DVDs'
    TabOrder = 1
    OnClick = btnDVDsClick
  end
  object edtNdvds: TEdit
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'n dvds'
  end
  object nomeProduto: TEdit
    Left = 8
    Top = 192
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'nome'
  end
  object valorProduto: TEdit
    Left = 8
    Top = 219
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'valor'
  end
  object btnCproduto: TButton
    Left = 24
    Top = 246
    Width = 75
    Height = 25
    Caption = 'C.produto'
    TabOrder = 5
    OnClick = btnCprodutoClick
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=testes'
      'User_Name=sa'
      'Password=admin22'
      'Server=XPS-L502X\SQLEXPRESS'
      'DriverID=MSSQL')
    Left = 544
    Top = 8
  end
  object SQLQuery: TFDQuery
    Connection = FDConnection
    Left = 544
    Top = 56
  end
end
