program movies;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  uSelectIMDBId in 'uSelectIMDBId.pas' {frmSelectIMDBId},
  uSelectMovieFromTurkceAltyazi in 'uSelectMovieFromTurkceAltyazi.pas' {frmTurkceAltyaziMovieSelect},
  uTurkceAltyaziSubtitleList in 'uTurkceAltyaziSubtitleList.pas' {frmTurkceAltyaziSubtitleList};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmSelectIMDBId, frmSelectIMDBId);
  Application.CreateForm(TfrmTurkceAltyaziMovieSelect, frmTurkceAltyaziMovieSelect);
  Application.CreateForm(TfrmTurkceAltyaziSubtitleList, frmTurkceAltyaziSubtitleList);
  Application.Run;
end.
