unit uMain;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, JSON, DateUtils,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,
    Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, OverbyteIcsWndControl,
    OverbyteIcsHttpProt, OverbyteIcsWSocket;

type
    TForm1 = class(TForm)
        ListView1: TListView;
        Panel1: TPanel;
        StatusBar1: TStatusBar;
        PopupMenu1: TPopupMenu;
        btnDeleteFile: TMenuItem;
        N1: TMenuItem;
        SslHttpCli1: TSslHttpCli;
        SslContext1: TSslContext;
        btnGetIMDB: TMenuItem;
        memLogs: TMemo;
        Panel2: TPanel;
        btnFindMovies: TButton;
        DriveComboBox1: TDriveComboBox;
        DirectoryListBox1: TDirectoryListBox;
        N2: TMenuItem;
        GetSubtitle1: TMenuItem;
        SslContext2: TSslContext;
        SslHttpCli2: TSslHttpCli;
        procedure btnFindMoviesClick(Sender: TObject);
        procedure btnDeleteFileClick(Sender: TObject);
        procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
        procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
          Data: Integer; var Compare: Integer);
        procedure SslHttpCli1DocBegin(Sender: TObject);
        procedure SslHttpCli1DocEnd(Sender: TObject);
        procedure btnGetIMDBClick(Sender: TObject);
    procedure GetSubtitle1Click(Sender: TObject);
    procedure SslHttpCli2DocBegin(Sender: TObject);
    procedure SslHttpCli2DocEnd(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
        procedure findMovies(FStartDir: string);
        procedure showStatus(FStatus: string);
        procedure addLog(FLog: string);

        function getMovieName(FFileName: string): string;
        function getYear(FFileName: string): string;
        function getQuality(FFileName: string): string;
        function getSRTName(FFileName: string): string;
        function isMovie(FFileName: string): Boolean;
        function getIMDB(FMovieName: string): string;
        function parseIMDBJSON(FJSON: TJSONObject): string;
        function parseTurkceAltyaziJSON(FJSONString: string): string;
        function cleanDoubleQutoes(FStr: string): string;
    end;

var
    Form1: TForm1;
    FQualityArray: array [0 .. 2] of string = (
        '480p',
        '720p',
        '1080p'
    );
    FMovieExts: array [0 .. 2] of string = (
        '.mkv',
        '.avi',
        '.mp4'
    );
    Descending: Boolean;
    SortedColumn: Integer;
    FIMDBMovieName: string;
    FIMDBMovieListIndex: Integer;
    FTurkceAltyaziCount: Integer = 100;
    FDownloadFolder: string;

implementation

{$R *.dfm}

uses uSelectIMDBId, uSelectMovieFromTurkceAltyazi;
{ TForm1 }

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

procedure TForm1.addLog(FLog: string);
begin
    memLogs.Lines.Add(FLog);
end;

procedure TForm1.btnDeleteFileClick(Sender: TObject);
var
    I: Integer;
    FList: TStringList;
    FItem: TListItem;
begin
    if ListView1.SelCount > 0 then
    begin
        case Application.MessageBox('Are you sure to delete this file?',
          'Warning', MB_OKCANCEL + MB_ICONWARNING) of
            IDOK:
                begin
                    FList := TStringList.Create;
                    for I := 0 to ListView1.Items.Count - 1 do
                        if ListView1.Items[I].Selected then
                            FList.Add(ListView1.Items[I].Caption);
                    for I := 0 to FList.Count - 1 do
                    begin
                        FItem := ListView1.FindCaption(0, FList[I], False,
                            False, False);
                        if FItem <> nil then
                        begin
                            addLog('Deleting file "' + FItem.SubItems[6] + '"');
                            DeleteFile(FItem.SubItems[6]);
                            FItem.Delete;
                        end;
                    end;
                    FList.Free;
                end;
        end;
    end;
end;

procedure TForm1.btnFindMoviesClick(Sender: TObject);
begin
    ListView1.Items.Clear;
    findMovies(DirectoryListBox1.Directory);
end;

procedure TForm1.btnGetIMDBClick(Sender: TObject);
var
    I: Integer;
begin
    if ListView1.SelCount > 0 then
        for I := 0 to ListView1.Items.Count - 1 do
            if ListView1.Items[I].Selected then
            begin
                FIMDBMovieListIndex := I;
                addLog('Get IMDB: "' + ListView1.Items[I].SubItems[0] + '"');
                getIMDB(ListView1.Items[I].SubItems[0]);
            end;
end;

function TForm1.cleanDoubleQutoes(FStr: string): string;
begin
    FStr := StringReplace(FStr, '\/', '/', [rfReplaceAll]);
    Result := Trim(StringReplace(FStr, '"', '', [rfReplaceAll]));
end;

procedure TForm1.findMovies(FStartDir: string);
var
    SR: TSearchRec;
    IsFound: Boolean;
    FDirList: TStringList;
    FItem: TListItem;
    I: Integer;
begin
    if FStartDir[Length(FStartDir)] <> '\' then
        FStartDir := FStartDir + '\';

    IsFound := FindFirst(FStartDir + '*.*', faAnyFile - faDirectory, SR) = 0;
    while IsFound do
    begin
        if isMovie(SR.Name) then
        begin
            FItem := ListView1.Items.Add;
            FItem.Caption := IntToStr(ListView1.Items.Count);
            FItem.SubItems.Add(getMovieName(SR.Name));
            FItem.SubItems.Add(SR.Name);
            FItem.SubItems.Add(getYear(SR.Name));
            FItem.SubItems.Add(getQuality(SR.Name));
            if FileExists(FStartDir + getSRTName(SR.Name)) then
                FItem.SubItems.Add('OK')
            else
                FItem.SubItems.Add('NO');
            FItem.SubItems.Add('');
            FItem.SubItems.Add(FStartDir + SR.Name);
            Application.ProcessMessages;
            showStatus(IntToStr(ListView1.Items.Count) + ' movies found');
        end;
        IsFound := FindNext(SR) = 0;
    end;
    FindClose(SR);
    FDirList := TStringList.Create;
    IsFound := FindFirst(FStartDir + '*.*', faAnyFile, SR) = 0;
    while IsFound do
    begin
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name[1] <> '.') then
            FDirList.Add(FStartDir + SR.Name);
        IsFound := FindNext(SR) = 0;
    end;
    FindClose(SR);

    for I := 0 to FDirList.Count - 1 do
        findMovies(FDirList[i]);

    FDirList.Free;
end;

function TForm1.isMovie(FFileName: string): Boolean;
var
    FExtension: string;
    I: Integer;
begin
    Result := False;
    FExtension := ExtractFileExt(FFileName);
    for I := 0 to High(FMovieExts) do
        if FMovieExts[I] = FExtension then
        begin
            Result := True;
            Break;
        end;
end;

procedure TForm1.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
    TListView(Sender).SortType := stNone;
    if Column.Index <> SortedColumn then
    begin
        SortedColumn := Column.Index;
        Descending := False;
    end
    else
        Descending := not Descending;
    TListView(Sender).SortType := stText;
end;

procedure TForm1.ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
    if SortedColumn = 0 then
        Compare := CompareText(Item1.Caption, Item2.Caption)
    else if SortedColumn <> 0 then
        Compare := CompareText(Item1.SubItems[SortedColumn - 1],
          Item2.SubItems[SortedColumn - 1]);
    if Descending then
        Compare := -Compare;
end;

function TForm1.parseIMDBJSON(FJSON: TJSONObject): string;
var
    FMovies: TJSONArray;
    vJSONValue: TJSONValue;
    vJSONObject: TJSONObject;
    FMovieName, FId: string;
    FIdFound: Boolean;
    FItem: TListItem;
begin
    FMovies := FJSON.Values['d'] as TJSONArray;
    FIdFound := False;
    SetLength(FIMDBList, 0);
    for vJSONValue in FMovies do
    begin
        vJSONObject := vJSONValue as TJSONObject;
        FId := cleanDoubleQutoes(vJSONObject.GetValue('id').ToString);
        if Copy(FId, 1, 2) = 'tt' then
        begin
            FMovieName := cleanDoubleQutoes(vJSONObject.GetValue('l').ToString);
            addLog('Found Movie Name: "' + FMovieName + '"');
            if LowerCase(FMovieName) = LowerCase(FIMDBMovieName) then
            begin
                addLog('IMDB Id Found: ' + FId);
                ListView1.Items[FIMDBMovieListIndex].SubItems[5] := FId;
                FIdFound := True;
                Break;
            end;

            SetLength(FIMDBList, Length(FIMDBList) + 1);
            with FIMDBList[High(FIMDBList)] do
            begin
                FIMDBMovieName := FMovieName;
                FIMDBId := FId;
                FIMDBYear := cleanDoubleQutoes(vJSONObject.GetValue('y')
                    .ToString);
            end;
        end;
    end;
    if (not FIdFound) and (frmSelectIMDBId.ShowModal = 1) then
        ListView1.Items[FIMDBMovieListIndex].SubItems[5] :=
            frmSelectIMDBId.lvIMDB.Items[FLastCheckedIndex].SubItems[2];
end;

function TForm1.parseTurkceAltyaziJSON(FJSONString: string): string;
var
    FMovies: TJSONValue;
    FMovieList: TJSONArray;
    vJSONValue: TJSONValue;
    vJSONObject: TJSONObject;
    FMovieName, FYear, FImdbId, FUrl: string;
    FItem: TListItem;
begin
    FMovies := TJSONObject.ParseJSONValue(FJSONString);
    addLog(FMovies.ToString);
    FMovieList := FMovies as TJSONArray;
    for vJSONValue in FMovieList do
    begin
        vJSONObject := vJSONValue as TJSONObject;
        FMovieName := cleanDoubleQutoes(vJSONObject.GetValue('isim').ToString);
        FYear := cleanDoubleQutoes(vJSONObject.GetValue('yil').ToString);
        FImdbId := cleanDoubleQutoes(vJSONObject.GetValue('imdbid').ToString);
        FUrl := cleanDoubleQutoes(vJSONObject.GetValue('url').ToString);
        FItem := frmTurkceAltyaziMovieSelect.lvTurkceAltyaziMovieList.Items.Add;
        FItem.Caption := IntToStr(frmTurkceAltyaziMovieSelect.
            lvTurkceAltyaziMovieList.Items.Count);
        FItem.SubItems.Add(FMovieName);
        FItem.SubItems.Add(FYear);
        FItem.SubItems.Add(FImdbId);
        FItem.SubItems.Add(FUrl);
    end;
    frmTurkceAltyaziMovieSelect.ShowModal;
end;

procedure TForm1.showStatus(FStatus: string);
begin
    StatusBar1.Panels[0].Text := FStatus;
end;

procedure TForm1.SslHttpCli1DocBegin(Sender: TObject);
begin
    if FileExists(SslHttpCli1.DocName) then
        DeleteFile(SslHttpCli1.DocName);
    SslHttpCli1.RcvdStream := TFileStream.Create(SslHttpCli1.DocName, fmCreate);
end;

procedure TForm1.SslHttpCli1DocEnd(Sender: TObject);
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
        FJSONObject.Parse(BytesOf(FList.Text), 0);
        parseIMDBJSON(FJSONObject);
        FList.Free;
    end;
end;

procedure TForm1.SslHttpCli2DocBegin(Sender: TObject);
begin
    if FileExists(SslHttpCli2.DocName) then
        DeleteFile(SslHttpCli2.DocName);
    SslHttpCli2.RcvdStream := TFileStream.Create(SslHttpCli2.DocName, fmCreate);
end;

procedure TForm1.SslHttpCli2DocEnd(Sender: TObject);
var
    FJSONObject: TJSONObject;
    FList: TStringList;
begin
    if Assigned(SslHttpCli2.RcvdStream) then begin
        SslHttpCli2.RcvdStream.Free;
        SslHttpCli2.RcvdStream := nil;
        FJSONObject := TJSONObject.Create;
        FList := TStringList.Create;
        FList.LoadFromFile(SslHttpCli2.DocName);
        parseTurkceAltyaziJSON(FList.Text);
        FList.Free;
    end;
end;

function TForm1.getIMDB(FMovieName: string): string;
begin
    Result := '';
    FIMDBMovieName := Trim(FMovieName);
    FMovieName := LowerCase(Trim(FMovieName));
    FMovieName := StringReplace(FMovieName, ' ', '_', [rfReplaceAll]);
    SslHttpCli1.URL := 'https://v2.sg.media-imdb.com/suggestion/' +
        Copy(FMovieName, 1, 1) + '/' + FMovieName + '.json';
    try
        SslContext1.InitContext;
    except
        on E:Exception do
            Exit;
    end;

    SslHttpCli1.GetASync;
end;

function TForm1.getMovieName(FFileName: string): string;
var
    FYear: string;
begin
    Result := FFileName;
    FYear := getYear(Result);
    if FYear <> '' then
        Result := Copy(Result, 1, Pos(FYear, Result) - 1);
    Result := StringReplace(Result, '.', ' ', [rfReplaceAll]);
end;

function TForm1.getQuality(FFileName: string): string;
var
    I: Integer;
begin
    Result := '';
    for I := 0 to High(FQualityArray) do
        if Pos(FQualityArray[I], FFileName) > 0 then
        begin
            Result := FQualityArray[I];
            Break;
        end;
end;

function TForm1.getSRTName(FFileName: string): string;
var
    FExtension: string;
begin
    FExtension := ExtractFileExt(FFileName);
    Result := StringReplace(FFileName, FExtension, '.srt', [rfReplaceAll]);
end;

procedure TForm1.GetSubtitle1Click(Sender: TObject);
function fixMovieName(FMovieName: string): string;
begin
    Result := StringReplace(Trim(FMovieName), ' ', '+', [rfReplaceAll]);
end;
begin
    if ListView1.Selected <> nil then
    begin
        Inc(FTurkceAltyaziCount);
        FDownloadFolder := ExtractFilePath(ListView1.Selected.SubItems[6]);
        SslHttpCli2.URL := 'https://turkcealtyazi.org/things_.php?t=99&term=' +
            fixMovieName(ListView1.Selected.SubItems[0]) + '&_=' + IntToStr(CTime) +
                IntToStr(FTurkceAltyaziCount);
        addLog(SslHttpCli2.URL);
        try
            SslContext2.InitContext;
        except
            on E:Exception do
                Exit;
        end;

        SslHttpCli2.GetASync;
    end;
end;

function TForm1.getYear(FFileName: string): string;
var
    I: Integer;
begin
    Result := '';
    for I := 1950 to 2020 do
        if Pos(IntToStr(I), FFileName) > 0 then
        begin
            Result := IntToStr(I);
            Break;
        end;
end;

end.
