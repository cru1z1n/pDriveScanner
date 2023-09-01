unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.IOUtils,
  FMX.Memo.Types, FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.TabControl, Winapi.ShellAPI,Winapi.Windows,
  System.Math.Vectors, FMX.Controls3D, FMX.Layers3D, FMX.Objects;


type
  TForm2 = class(TForm)
    Memo1: TMemo;
    ListBox1: TListBox;
    TabControl1: TTabControl;
    Current: TTabItem;
    History: TTabItem;
    HistoryListBox: TListBox;
    OpenFile: TButton;
    Button1: TButton;
    Edit1: TEdit;
    ScaledLayout1: TScaledLayout;
    FilterMemoEdit: TEdit;
    FindMemo: TButton;
    FindNextMemo: TButton;
    Layout3D1: TLayout3D;
    CaseSensitiveCheckBox: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Label18: TLabel;
    DiscordLink: TLabel;
    Text1: TText;
    IncludeCPP: TCheckBox;
    IncludeC: TCheckBox;
    Label1: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HistoryListBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure OpenFileClick(Sender: TObject);
    procedure FindMemoClick(Sender: TObject);
    procedure FindNextMemoClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    const
      HistoryFolderName = 'SearchHistory';
      HistoryFileName = 'SearchHistory.txt';

    procedure SaveSearchHistory;
    procedure LoadSearchHistory;
    procedure SaveSearchResults(const ASearchString: string);
    procedure LoadSearchResults(const ASearchString: string);
    procedure PerformSearch(const ASearchString: string);
    procedure OpenDirectory(const AFileName: string);
    procedure OpenContainingDirectory(const AFileName: string);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.OpenContainingDirectory(const AFileName: string);
var
  DirectoryPath: string;
begin
  DirectoryPath := ExtractFilePath(AFileName);
  if DirectoryExists(DirectoryPath) then
    ShellExecute(0, 'open', PChar(DirectoryPath), nil, nil, SW_SHOWNORMAL)
  else
    ShowMessage('Directory does not exist.');
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  HistoryFolderPath, HistoryFilePath: string;
begin
  HistoryFolderPath := HistoryFolderName;

  if not TDirectory.Exists(HistoryFolderPath) then
    TDirectory.CreateDirectory(HistoryFolderPath);

  HistoryFilePath := HistoryFolderPath + PathDelim + HistoryFileName;

  if not TFile.Exists(HistoryFilePath) then
    TFile.WriteAllText(HistoryFilePath, '');

  LoadSearchHistory;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if ListBox1.Selected <> nil then
    OpenContainingDirectory(ListBox1.Selected.Text);
end;

procedure TForm2.FindMemoClick(Sender: TObject);
var
  SearchText: string;
  StartPos, FoundPos: Integer;
begin
  SearchText := FilterMemoEdit.Text;
  if SearchText <> '' then
  begin
    StartPos := Memo1.SelStart + Memo1.SelLength;
    FoundPos := Pos(SearchText, Memo1.Text, StartPos + 1);
    if FoundPos > 0 then
    begin
      Memo1.SelStart := FoundPos - 1;
      Memo1.SelLength := Length(SearchText);
      Memo1.GoToLineBegin;
      Memo1.GoToLineEnd;
      Memo1.SelectWord;
      Memo1.SetFocus;
    end
    else
      ShowMessage('Text not found.');
  end;
end;

procedure TForm2.FindNextMemoClick(Sender: TObject);
var
  SearchText: string;
  StartPos, FoundPos: Integer;
begin
  SearchText := FilterMemoEdit.Text;
  if SearchText <> '' then
  begin
    StartPos := Memo1.SelStart + Memo1.SelLength + 1;
    FoundPos := Pos(SearchText, Memo1.Text, StartPos + 1);
    if FoundPos > 0 then
    begin
      Memo1.SelStart := FoundPos - 1;
      Memo1.SelLength := Length(SearchText);
      Memo1.GoToLineBegin;
      Memo1.GoToLineEnd;
      Memo1.SelectWord;
      Memo1.SetFocus;
    end
    else
      ShowMessage('No more occurrences found.');
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSearchHistory;
end;

procedure TForm2.SaveSearchHistory;
begin
  HistoryListBox.Items.SaveToFile(HistoryFolderName + '\' + HistoryFileName);
end;

procedure TForm2.LoadSearchHistory;
begin
  HistoryListBox.Items.LoadFromFile(HistoryFolderName + '\' + HistoryFileName);
end;

procedure TForm2.SaveSearchResults(const ASearchString: string);
begin
  ListBox1.Items.SaveToFile(HistoryFolderName + '\' + ASearchString + '.txt');
end;

procedure TForm2.LoadSearchResults(const ASearchString: string);
begin
  ListBox1.Items.LoadFromFile(HistoryFolderName + '\' + ASearchString + '.txt');
end;

procedure SearchFilesForString(const APath, ASearchString: string);
var
  Files: TArray<string>;
  FileName, FileContent: string;
  FileFilters: TArray<string>;
  FilterFiles: TArray<string>;
begin
  FileFilters := ['*.cpp', '*.c'];

  SetLength(Files, 0);
  Application.ProcessMessages;
  for FileName in FileFilters do
  begin
    FilterFiles := TDirectory.GetFiles(APath, FileName, TSearchOption.soAllDirectories);
    Files := Files + FilterFiles;
  end;

  for FileName in Files do
  begin

    FileContent := TFile.ReadAllText(FileName);

    if Pos(ASearchString, FileContent) > 0 then
      Form2.ListBox1.Items.Add(FileName);
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  ListBox1.Clear;
  Memo1.Lines.Clear;
  PerformSearch(Edit1.Text);
end;

procedure TForm2.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if ListBox1.ItemIndex > -1 then
  begin
    Memo1.Lines.LoadFromFile(ListBox1.Selected.Text);
  end;
end;

procedure TForm2.HistoryListBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if HistoryListBox.ItemIndex >= 0 then
  begin
    Edit1.Text := HistoryListBox.Selected.Text;
    LoadSearchResults(Edit1.Text);
    TabControl1.TabIndex :=  0;
  end;
end;

procedure TForm2.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  ShellExecute(0, 'open', PChar('https://discord.gg/juvwGwQbGy'), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm2.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  ShellExecute(0, 'open', PChar('https://www.paypal.com/donate/?hosted_button_id=WEP26373TGAT6'), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm2.PerformSearch(const ASearchString: string);
var
  Files: TArray<string>;
  FileName, FileContent: string;
  FileFilters: TArray<string>;
  FilterFiles: TArray<string>;
  CaseSensitive: Boolean;
begin
  ListBox1.Clear;
  if not IncludeCPP.IsChecked and not IncludeC.IsChecked then
  begin
      ShowMessage('Please Pick A Filter Option');
      exit;
  end;

  if IncludeC.IsChecked then
  begin
    FileFilters := ['*.c'];
  end;

  if IncludeCPP.IsChecked then
  begin
      FileFilters := ['*.cpp'];
  end;

  if IncludeCPP.IsChecked and IncludeC.IsChecked then
  begin
      FileFilters := ['*.cpp','*.c'];
  end;
  Files := [];

  CaseSensitive := CaseSensitiveCheckBox.IsChecked;

  for FileName in FileFilters do
  begin
    FilterFiles := TDirectory.GetFiles('P:\', FileName, TSearchOption.soAllDirectories);
    Files := Files + FilterFiles;
  end;

  for FileName in Files do
  begin
    FileContent := TFile.ReadAllText(FileName);
    if CaseSensitive then
    begin
      if Pos(ASearchString, FileContent) > 0 then
        ListBox1.Items.Add(FileName);
    end
    else
    begin
      if Pos(AnsiUpperCase(ASearchString), AnsiUpperCase(FileContent)) > 0 then
        ListBox1.Items.Add(FileName);
    end;
  end;

  if HistoryListBox.Items.IndexOf(ASearchString) = -1 then
    HistoryListBox.Items.Add(ASearchString);
  SaveSearchHistory;
  SaveSearchResults(ASearchString);
end;

procedure TForm2.OpenDirectory(const AFileName: string);
var
  FileExtension: string;
begin
  FileExtension := ExtractFileExt(AFileName);
  if SameText(FileExtension, '.cpp') or SameText(FileExtension, '.c') then
    ShellExecute(0, 'open', PChar(AFileName), nil, nil, SW_SHOWNORMAL)
  else
    ShowMessage('Unsupported file type.');
end;

procedure TForm2.OpenFileClick(Sender: TObject);
begin
  if ListBox1.Selected <> nil then
    OpenDirectory(ListBox1.Selected.Text);
end;

end.

