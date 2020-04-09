unit uSelectMovieFromTurkceAltyazi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, uMain, DateUtils, JSON,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  OverbyteIcsWSocket, OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TfrmTurkceAltyaziMovieSelect = class(TForm)
    lvTurkceAltyaziMovieList: TListView;
    Panel1: TPanel;
    edtMovieName: TEdit;
    btnSearch: TButton;
    SslHttpCli1: TSslHttpCli;
    SslContext1: TSslContext;
    procedure lvTurkceAltyaziMovieListDblClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure SslHttpCli1DocBegin(Sender: TObject);
    procedure SslHttpCli1DocEnd(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function parseTurkceAltyaziJSON(FJSONString: string): string;
  end;

var
  frmTurkceAltyaziMovieSelect: TfrmTurkceAltyaziMovieSelect;
  FTurkceAltyaziCount: Integer = 100;

implementation

{$R *.dfm}

uses uTurkceAltyaziSubtitleList;

function CTime: Int64;
var
    SystemTime: TSystemTime;
    NowUTC: TDateTime;
begin
    GetSystemTime(SystemTime);
    with SystemTime do
        NowUTC := EncodeDateTime(wYear, wMonth, wDay, wHour, wMinute, wSecond, wMilliseconds);
    Result := DateTimeToUnix(NowUTC);
end;

procedure TfrmTurkceAltyaziMovieSelect.btnSearchClick(Sender: TObject);
    function fixMovieName(FMovieName: string): string;
    begin
        Result := StringReplace(Trim(FMovieName), ' ', '+', [rfReplaceAll]);
    end;
begin
    if Length(Trim(edtMovieName.Text)) > 1 then
    begin
        Inc(FTurkceAltyaziCount);

        SslHttpCli1.URL := 'https://turkcealtyazi.org/things_.php?t=99&term=' +
            fixMovieName(edtMovieName.Text) + '&_=' + IntToStr(CTime) +
                IntToStr(FTurkceAltyaziCount);
        Form1.addLog(SslHttpCli1.URL);
        try
            SslContext1.InitContext;
        except
            on E:Exception do
                Exit;
        end;

        SslHttpCli1.GetASync;
    end;
end;

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

function TfrmTurkceAltyaziMovieSelect.parseTurkceAltyaziJSON(
  FJSONString: string): string;
var
    FMovies: TJSONValue;
    FMovieList: TJSONArray;
    vJSONValue: TJSONValue;
    vJSONObject: TJSONObject;
    FMovieName, FYear, FImdbId, FUrl: string;
    FItem: TListItem;
begin
    lvTurkceAltyaziMovieList.Items.Clear;
    if FJSONString = 'null' then
    begin
        Application.MessageBox('No movies found!', 'TurkceAltyazi.Org', MB_OK +
            MB_ICONINFORMATION);
        Exit;
    end;
    FMovies := TJSONObject.ParseJSONValue(FJSONString);
    Form1.addLog(FMovies.ToString);
    FMovieList := FMovies as TJSONArray;
    for vJSONValue in FMovieList do
    begin
        vJSONObject := vJSONValue as TJSONObject;
        FMovieName := Form1.cleanDoubleQutoes(vJSONObject.GetValue('isim').ToString);
        FYear := Form1.cleanDoubleQutoes(vJSONObject.GetValue('yil').ToString);
        FImdbId := Form1.cleanDoubleQutoes(vJSONObject.GetValue('imdbid').ToString);
        FUrl := Form1.cleanDoubleQutoes(vJSONObject.GetValue('url').ToString);
        FItem := lvTurkceAltyaziMovieList.Items.Add;
        FItem.Caption := IntToStr(lvTurkceAltyaziMovieList.Items.Count);
        FItem.SubItems.Add(FMovieName);
        FItem.SubItems.Add(FYear);
        FItem.SubItems.Add(FImdbId);
        FItem.SubItems.Add(FUrl);
    end;
end;

procedure TfrmTurkceAltyaziMovieSelect.SslHttpCli1DocBegin(Sender: TObject);
begin
    if FileExists(SslHttpCli1.DocName) then
        DeleteFile(SslHttpCli1.DocName);
    SslHttpCli1.RcvdStream := TFileStream.Create(SslHttpCli1.DocName, fmCreate);
end;

procedure TfrmTurkceAltyaziMovieSelect.SslHttpCli1DocEnd(Sender: TObject);
var
    FJSONObject: TJSONObject;
    FList: TStringList;
begin
    if Assigned(SslHttpCli1.RcvdStream) then begin
        SslHttpCli1.RcvdStream.Free;
        SslHttpCli1.RcvdStream := nil;
        FJSONObject := TJSONObject.Create;
        FList := TStringList.Create;
        FList.LoadFromFile(SslHttpCli1.DocName);
        parseTurkceAltyaziJSON(FList.Text);
        FList.Free;
    end;
end;

end.
