unit uSelectMovieFromTurkceAltyazi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TfrmTurkceAltyaziMovieSelect = class(TForm)
    lvTurkceAltyaziMovieList: TListView;
    Panel1: TPanel;
    procedure lvTurkceAltyaziMovieListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTurkceAltyaziMovieSelect: TfrmTurkceAltyaziMovieSelect;

implementation

{$R *.dfm}

uses uTurkceAltyaziSubtitleList;

procedure TfrmTurkceAltyaziMovieSelect.lvTurkceAltyaziMovieListDblClick(
  Sender: TObject);
begin
    if lvTurkceAltyaziMovieList.Selected <> nil then
    begin
        frmTurkceAltyaziSubtitleList.retrieveSubtitleList(
            lvTurkceAltyaziMovieList.Selected.SubItems[3]
        );
        frmTurkceAltyaziSubtitleList.ShowModal;
    end;
end;

end.
