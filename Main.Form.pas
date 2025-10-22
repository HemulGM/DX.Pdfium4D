unit Main.Form;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.WebBrowser;

type
  TMainForm = class(TForm)
    WebBrowser: TWebBrowser;
    procedure FormCreate(Sender: TObject);
  private
    FCurrentPdfPath: string;
  protected
    procedure LoadPdfFile(const AFilePath: string);
    procedure ProcessCommandLineParams;
  public
    procedure DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation); override;
    procedure DragDrop(const Data: TDragObject; const Point: TPointF); override;
    procedure DropFiles(const AFiles: array of string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'DX PDF-Viewer 1.0';
  FCurrentPdfPath := '';

  // Process command line parameters
  ProcessCommandLineParams;
end;

procedure TMainForm.ProcessCommandLineParams;
var
  LFilePath: string;
begin
  // Check if a parameter was passed
  if ParamCount > 0 then
  begin
    LFilePath := ParamStr(1);

    // Check if the file exists and is a PDF
    if TFile.Exists(LFilePath) and
       (LowerCase(TPath.GetExtension(LFilePath)) = '.pdf') then
    begin
      LoadPdfFile(LFilePath);
    end;
  end;
end;

procedure TMainForm.LoadPdfFile(const AFilePath: string);
var
  LFileUrl: string;
begin
  if not TFile.Exists(AFilePath) then
  begin
    ShowMessage('File not found: ' + AFilePath);
    Exit;
  end;

  FCurrentPdfPath := AFilePath;

  // Convert file path to file:// URL
  LFileUrl := 'file:///' + StringReplace(AFilePath, '\', '/', [rfReplaceAll]);

  // Load PDF in WebBrowser
  WebBrowser.Navigate(LFileUrl);

  // Update window title
  Caption := 'DX PDF-Viewer 1.0 - ' + TPath.GetFileName(AFilePath);
end;

procedure TMainForm.DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  // Check if it's a PDF file
  if LowerCase(TPath.GetExtension(Data.Files[0])) = '.pdf' then
  begin
    Operation := TDragOperation.Move;
  end;
end;

procedure TMainForm.DragDrop(const Data: TDragObject; const Point: TPointF);
begin
  // Load the file
  LoadPdfFile(Data.Files[0]);
end;

procedure TMainForm.DropFiles(const AFiles: array of string);
var
  LFilePath: string;
begin
  // Process only the first file
  if Length(AFiles) > 0 then
  begin
    LFilePath := AFiles[0];

    // Check if it's a PDF file
    if LowerCase(TPath.GetExtension(LFilePath)) = '.pdf' then
    begin
      LoadPdfFile(LFilePath);
    end
    else
    begin
      ShowMessage('Please drop PDF files only.');
    end;
  end;
end;

end.

