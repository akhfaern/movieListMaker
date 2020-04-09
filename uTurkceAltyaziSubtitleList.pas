unit uTurkceAltyaziSubtitleList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  OverbyteIcsWSocket, OverbyteIcsWndControl, OverbyteIcsHttpProt, uMain,
  Vcl.OleCtrls, SHDocVw;

type
    THttpActions = (haSubtitleList, haSubtitleMainPage, haDownloadSubtitle);

type
  TfrmTurkceAltyaziSubtitleList = class(TForm)
    lvSubtitleList: TListView;
    pnStatus: TPanel;
    SslHttpCli1: TSslHttpCli;
    SslContext1: TSslContext;
    Panel1: TPanel;
    WebBrowser1: TWebBrowser;
    procedure SslHttpCli1DocBegin(Sender: TObject);
    procedure SslHttpCli1DocEnd(Sender: TObject);
    procedure lvSubtitleListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure retrieveSubtitleList(FURL: string);
    procedure setStatus(FStatus: string);
    procedure parseHTML(FHtml: string);
    procedure downloadSubtitle(FUrl: string);
    procedure parseSubtitleMainPage(html: string);

    function getRipType(FCaption: string): string;
  end;

var
  frmTurkceAltyaziSubtitleList: TfrmTurkceAltyaziSubtitleList;
  FRipTypes: array [0..9] of string = (
    'HD', 'DVDRip', 'DVDScr', 'R5', 'CAM', 'WEBRip', 'BDRip',
    'WEB-DL', 'HDRip', 'HDTS');
  FLastHttpAction: THttpActions;

implementation

{$R *.dfm}

{ TfrmTurkceAltyaziSubtitleList }

procedure TfrmTurkceAltyaziSubtitleList.downloadSubtitle(FUrl: string);
begin
    FLastHttpAction := haSubtitleMainPage;
    SslHttpCli1.URL := 'https://turkcealtyazi.org' + FURL;
    SslContext1.InitContext;
    setStatus('Downloading subtitle...');
    SslHttpCli1.GetASync;
end;

function TfrmTurkceAltyaziSubtitleList.getRipType(FCaption: string): string;
var
    I: Integer;
begin
    for I := 1 to 10 do
        FCaption := StringReplace(FCaption, '<span class="rps r' + IntToStr(I) +
            '"></span>', FRipTypes[I - 1], [rfReplaceAll]);
    Result := FCaption;
end;

procedure TfrmTurkceAltyaziSubtitleList.lvSubtitleListDblClick(Sender: TObject);
begin
    if lvSubtitleList.Selected <> nil then
        case Application.MessageBox('Are you sure to download this subtitle?',
            'Download Subtitle', MB_OKCANCEL + MB_ICONINFORMATION) of
            IDOK:
                downloadSubtitle(lvSubtitleList.Selected.SubItems[6]);
        end;
end;

procedure TfrmTurkceAltyaziSubtitleList.parseHTML(FHtml: string);
var
    FLanguage, FPart, FCaption, FFps, FDownloaded, FId, FDownloadURL: string;
    FItem: TListItem;
begin
    setStatus('Parsing...');
    lvSubtitleList.Items.Clear;
    if Pos('id="altyazilar"', FHtml) < 1 then
    begin
        setStatus('No subtitle Found');
        Exit;
    end;
    FHtml := Copy(FHtml, Pos('id="altyazilar"', FHtml) + 16, Length(FHtml));
    while Pos('<div class="altsonsez2', FHtml) > 0 do
    begin
        Delete(FHtml, 1, Pos('<div class="altsonsez2', FHtml) - 1);
        Delete(FHtml, 1, Pos('id="', FHtml) + 3);
        FId := Copy(FHtml, 1, Pos('"', FHtml) - 1);
        Delete(FHtml, 1, Pos('href="', FHtml) + 5);
        FDownloadURL := Copy(FHtml, 1, Pos('"', FHtml) - 1);
        Delete(FHtml, 1, Pos('<div class="aldil">', FHtml) - 1);
        FLanguage := Copy(FHtml, Pos('class="flag', FHtml) + 11, 3);
        FLanguage := Copy(FLanguage, 1, Pos('"', FLanguage) - 1);
        Delete(FHtml, 1, Pos('<div class="alcd"', FHtml) - 1);
        Delete(FHtml, 1, Pos('>', FHtml));
        FPart := Trim(Copy(FHtml, 1, Pos('<', FHtml) - 1));
        Delete(FHtml, 1, Pos('<div class="alfps"', FHtml) - 1);
        Delete(FHtml, 1, Pos('>', FHtml));
        FFps := Trim(Copy(FHtml, 1, Pos('<', FHtml) - 1));
        Delete(FHtml, 1, Pos('<div class="alindirme"', FHtml) - 1);
        Delete(FHtml, 1, Pos('>', FHtml));
        FDownloaded := Trim(Copy(FHtml, 1, Pos('<', FHtml) - 1));
        Delete(FHtml, 1, Pos('<div class="ta-container"', FHtml) - 1);
        Delete(FHtml, 1, Pos('<div class="ripdiv"', FHtml) - 1);
        Delete(FHtml, 1, Pos('>', FHtml));
        FCaption := Copy(Fhtml, 1, Pos('</div>', FHtml) - 1);


        FItem := lvSubtitleList.Items.Add;
        FItem.Caption := IntToStr(lvSubtitleList.Items.Count);
        FItem.SubItems.Add(getRipType(FCaption));
        FItem.SubItems.Add(FLanguage);
        FItem.SubItems.Add(FPart);
        FItem.SubItems.Add(FFps);
        FItem.SubItems.Add(FDownloaded);
        FItem.SubItems.Add(FId);
        FItem.SubItems.Add(FDownloadURL);
    end;
    setStatus('');
end;

procedure TfrmTurkceAltyaziSubtitleList.parseSubtitleMainPage(html: string);
var
    FId, FAlt, FSid, FBuffer: string;
    PostData: OleVariant;
    Headers: OleVariant;
    I: Integer;

    function getInputValue(FInputName: string): string;
    var
        FInput, FBuffer: string;
    begin
        FInput := Format('<input type="hidden" name="%s" value="', [FInputName]);
        FBuffer := html;
        Delete(FBuffer, 1, Pos(FInput, FBuffer) + (Length(FInput) - 1));
        Result := Copy(FBuffer, 1, Pos('"', FBuffer) - 1);
    end;
begin
    FId := getInputValue('idid');
    FAlt := getInputValue('altid');
    FSid := getInputValue('sidid');
    FBuffer := 'idid=' + FId + '&altid=' + FAlt + '&sidid=' + FSid;
    form1.addLog(FBuffer);
    PostData := VarArrayCreate([0, Length(FBuffer) - 1], varByte);
    for I := 1 to Length(FBuffer) do
        PostData[i-1] := Ord(FBuffer[i]);
    Headers := 'Content-Type: application/x-www-form-urlencoded' + #10#13;
    WebBrowser1.Navigate('https://turkcealtyazi.org/ind',
        EmptyParam, EmptyParam, PostData, Headers);
end;

procedure TfrmTurkceAltyaziSubtitleList.retrieveSubtitleList(FURL: string);
begin
    SslHttpCli1.URL := 'https://turkcealtyazi.org' + FURL;
    SslContext1.InitContext;
    setStatus('Retrieving List...');
    FLastHttpAction := haSubtitleList;
    SslHttpCli1.GetASync;
end;

procedure TfrmTurkceAltyaziSubtitleList.setStatus(FStatus: string);
begin
    if FStatus = '' then
        pnStatus.Visible := False
    else
    begin
        pnStatus.Visible := True;
        pnStatus.Caption := FStatus;
    end;
end;

procedure TfrmTurkceAltyaziSubtitleList.SslHttpCli1DocBegin(Sender: TObject);
var
    HttpCli: TSslHttpCli;
begin
    HttpCli := Sender as TSslHttpCli;
    Form1.addLog(HttpCli.Name);
    setStatus('Downloading content...');
    if FileExists(HttpCli.DocName) then
        DeleteFile(HttpCli.DocName);
    HttpCli.RcvdStream := TFileStream.Create(HttpCli.DocName, fmCreate);
end;

procedure TfrmTurkceAltyaziSubtitleList.SslHttpCli1DocEnd(Sender: TObject);
var
    FList: TStringList;
    HttpCli: TSslHttpCli;
begin
    HttpCli := Sender as TSslHttpCli;
    setStatus('Download complete. ');
    Form1.addLog('File downloaded: FileName: ' + HttpCli.DocName + ' Size: ' +
        IntToStr(HttpCli.RcvdStream.Size));
    if Assigned(HttpCli.RcvdStream) then begin
        HttpCli.RcvdStream.Free;
        HttpCli.RcvdStream := nil;
        FList := TStringList.Create;
        FList.LoadFromFile(HttpCli.DocName);
        case FLastHttpAction of
            haSubtitleList:
                begin
                    Form1.addLog('Parse Subtitle List');
                    parseHTML(FList.Text);
                end;
            haSubtitleMainPage:
                begin
                    Form1.addLog('Parse Subtitle Main Page');
                    parseSubtitleMainPage(FList.Text);
                end;
            haDownloadSubtitle:
                begin
                    
                end;
        end;
        FList.Free;
    end;
    setStatus('');
end;

end.
