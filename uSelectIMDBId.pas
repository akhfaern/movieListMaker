unit uSelectIMDBId;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
    TIMDBItem = record
        FIMDBMovieName: string;
        FIMDBId: string;
        FIMDBYear: string;
    end;

type
    TIMDBList = array of TIMDBItem;

type
  TfrmSelectIMDBId = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    lvIMDB: TListView;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure lvIMDBItemChecked(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSelectIMDBId: TfrmSelectIMDBId;
  FLastCheckedIndex: Integer;
  FIMDBList: TIMDBList;

implementation

{$R *.dfm}

procedure TfrmSelectIMDBId.Button1Click(Sender: TObject);
begin
    ModalResult := 1;
end;

procedure TfrmSelectIMDBId.Button2Click(Sender: TObject);
begin
    ModalResult := -1;
end;

procedure TfrmSelectIMDBId.FormShow(Sender: TObject);
var
    I: Integer;
    FItem: TListItem;
begin
    FLastCheckedIndex := -1;
    (**)
    lvIMDB.Items.Clear;
    for I := 0 to High(FIMDBList) do
    begin
        FItem := lvIMDB.Items.Add;
        FItem.Caption := IntToStr(lvIMDB.Items.Count);
        FItem.SubItems.Add(FIMDBList[I].FIMDBMovieName);
        FItem.SubItems.Add(FIMDBList[I].FIMDBYear);
        FItem.SubItems.Add(FIMDBList[I].FIMDBId);
    end;
    (**)
end;

procedure TfrmSelectIMDBId.lvIMDBItemChecked(Sender: TObject; Item: TListItem);
var
    I: Integer;
begin
    if (Item <> nil) and (Item.Checked) then
    begin
        FLastCheckedIndex := Item.Index;
        for I := 0 to lvIMDB.Items.Count - 1 do
            if I <> FLastCheckedIndex then
                lvIMDB.Items[I].Checked := False;
    end;
end;

end.
