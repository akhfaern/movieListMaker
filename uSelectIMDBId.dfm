object frmSelectIMDBId: TfrmSelectIMDBId
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select IMDB Id'
  ClientHeight = 309
  ClientWidth = 645
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 274
    Width = 645
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 273
    object Button1: TButton
      Left = 560
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 479
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object lvIMDB: TListView
    Left = 0
    Top = 0
    Width = 645
    Height = 274
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = '#'
      end
      item
        Caption = 'IMDB Movie Name'
        Width = 250
      end
      item
        Caption = 'Year'
        Width = 75
      end
      item
        Caption = 'IMDB Id'
        Width = 100
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnItemChecked = lvIMDBItemChecked
    ExplicitLeft = 32
    ExplicitTop = 24
    ExplicitWidth = 250
    ExplicitHeight = 150
  end
end
