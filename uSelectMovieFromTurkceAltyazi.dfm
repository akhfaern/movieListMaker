object frmTurkceAltyaziMovieSelect: TfrmTurkceAltyaziMovieSelect
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select Movie From TurkceAltyazi.Org'
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
  PixelsPerInch = 96
  TextHeight = 13
  object lvTurkceAltyaziMovieList: TListView
    Left = 0
    Top = 0
    Width = 645
    Height = 268
    Align = alClient
    Columns = <
      item
        Caption = '#'
      end
      item
        Caption = 'Movie Name'
        Width = 200
      end
      item
        AutoSize = True
        Caption = 'Year'
      end
      item
        AutoSize = True
        Caption = 'IMDB Id'
      end
      item
        AutoSize = True
        Caption = 'URL'
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvTurkceAltyaziMovieListDblClick
    ExplicitTop = -6
  end
  object Panel1: TPanel
    Left = 0
    Top = 268
    Width = 645
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 56
    ExplicitTop = 208
    ExplicitWidth = 185
  end
end
