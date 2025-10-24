unit Main.Form;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.StdCtrls,
  System.IOUtils,
  DX.Pdf.Viewer.FMX,
  DX.Pdf.Document, FMX.Controls.Presentation;

type
  TMainForm = class(TForm)
    DropPanel: TPanel;
    DropLabel: TLabel;
    StatusBar: TStatusBar;
    StatusLabel: TLabel;
    PageLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPdfViewer: TPdfViewer;
    FCurrentPdfPath: string;
    procedure HideDropPanel;
    procedure ShowDropPanel;
    procedure CreatePdfViewer;
    procedure UpdateStatusBar;
    procedure OnPdfViewerPageChanged(Sender: TObject);
  protected
    procedure LoadPdfFile(const AFilePath: string);
    procedure ProcessCommandLineParams;
  public
    procedure DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation); override;
    procedure DragDrop(const Data: TDragObject; const Point: TPointF); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'DX PDF-Viewer 1.0';
  FCurrentPdfPath := '';

  // Create PDF viewer dynamically
  CreatePdfViewer;

  // Initialize status bar
  UpdateStatusBar;

  // Show drop panel initially
  ShowDropPanel;

  // Process command line parameters
  ProcessCommandLineParams;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FPdfViewer);
end;

procedure TMainForm.CreatePdfViewer;
begin
  FPdfViewer := TPdfViewer.Create(Self);
  FPdfViewer.Parent := Self;
  FPdfViewer.Align := TAlignLayout.Client;
  FPdfViewer.BackgroundColor := TAlphaColors.White;
  FPdfViewer.OnPageChanged := OnPdfViewerPageChanged;
  FPdfViewer.SendToBack; // Send behind DropPanel
end;

procedure TMainForm.HideDropPanel;
begin
  DropPanel.Visible := False;
  DropPanel.HitTest := False;
end;

procedure TMainForm.ShowDropPanel;
begin
  DropPanel.Visible := True;
  DropPanel.HitTest := False;  // Let drag events pass through to form
  DropPanel.BringToFront;
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
begin
  if not TFile.Exists(AFilePath) then
  begin
    ShowMessage('File not found: ' + AFilePath);
    Exit;
  end;

  try
    // Load PDF in viewer
    FPdfViewer.LoadFromFile(AFilePath);

    FCurrentPdfPath := AFilePath;

    // Hide drop panel when PDF is loaded
    HideDropPanel;

    // Update window title and status bar
    Caption := 'DX PDF-Viewer 1.0 - ' + TPath.GetFileName(AFilePath);
    UpdateStatusBar;

    // Set focus to viewer for keyboard navigation
    FPdfViewer.SetFocus;
  except
    on E: EPdfException do
    begin
      ShowMessage('Error loading PDF: ' + E.Message);
      ShowDropPanel;
      UpdateStatusBar;
    end;
  end;
end;

procedure TMainForm.UpdateStatusBar;
var
  LFileName: string;
  LPdfVersion: string;
  LPdfAInfo: string;
  LStatusText: string;
begin
  if (FCurrentPdfPath = '') or (FPdfViewer.Document = nil) or not FPdfViewer.Document.IsLoaded then
  begin
    StatusLabel.Text := 'No document loaded';
    PageLabel.Text := '';
    Exit;
  end;

  // Get file name
  LFileName := TPath.GetFileName(FCurrentPdfPath);

  // Get PDF version
  LPdfVersion := FPdfViewer.Document.GetFileVersionString;

  // Get PDF/A information
  LPdfAInfo := FPdfViewer.Document.GetPdfAInfo;

  // Build status text (left side)
  LStatusText := Format('File: %s  |  PDF Version: %s', [LFileName, LPdfVersion]);

  // Add PDF/A info if available
  if LPdfAInfo <> '' then
    LStatusText := LStatusText + '  |  ' + LPdfAInfo;

  StatusLabel.Text := LStatusText;

  // Page info on the right side
  PageLabel.Text := Format('Page %d/%d', [FPdfViewer.CurrentPageIndex + 1, FPdfViewer.PageCount]);
end;

procedure TMainForm.OnPdfViewerPageChanged(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TMainForm.DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  // Check if we have files and if it's a PDF file
  if (Length(Data.Files) > 0) and
     (LowerCase(TPath.GetExtension(Data.Files[0])) = '.pdf') then
  begin
    Operation := TDragOperation.Copy;
  end
  else
  begin
    Operation := TDragOperation.None;
  end;
end;

procedure TMainForm.DragDrop(const Data: TDragObject; const Point: TPointF);
begin
  // Check if we have files
  if Length(Data.Files) > 0 then
  begin
    // Check if it's a PDF file
    if LowerCase(TPath.GetExtension(Data.Files[0])) = '.pdf' then
    begin
      LoadPdfFile(Data.Files[0]);
    end
    else
    begin
      ShowMessage('Please drop PDF files only.');
    end;
  end;
end;

end.

