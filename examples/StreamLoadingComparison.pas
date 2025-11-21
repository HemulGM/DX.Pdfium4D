unit StreamLoadingComparison;

{*******************************************************************************
  Demonstrates the two different methods for loading PDFs in DX.Pdfium4D:
  1. LoadFromFile - Direct file loading
  2. LoadFromStream - Efficient streaming support (on-demand loading)
*******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  DX.Pdf.Document,
  DX.Pdf.Viewer.FMX;

type
  TPdfLoadingExamples = class
  public
    /// <summary>
    /// Method 1: Load from file (recommended for local files)
    /// </summary>
    class procedure LoadFromFileExample(APdfViewer: TPdfViewer);

    /// <summary>
    /// Method 2: Load from stream with efficient streaming support
    /// </summary>
    class procedure LoadFromStreamExample(APdfViewer: TPdfViewer);

    /// <summary>
    /// Comparison: Memory usage for different methods
    /// </summary>
    class procedure CompareMemoryUsage;
  end;

implementation

{ TPdfLoadingExamples }

class procedure TPdfLoadingExamples.LoadFromFileExample(APdfViewer: TPdfViewer);
begin
  // ✅ Method 1: Load from file
  // - Simplest method
  // - PDFium handles file access internally
  // - Implementation unknown (could be memory-mapped, buffered, or streaming)
  // - Best for: Local files that already exist on disk

  APdfViewer.LoadFromFile('C:\Documents\report.pdf');

  // That's it! No stream management needed.
end;

class procedure TPdfLoadingExamples.LoadFromStreamExample(APdfViewer: TPdfViewer);
var
  LStream: TMemoryStream;
begin
  // ✅ Method 2: LoadFromStream (RECOMMENDED for streams)
  // - TRUE streaming support via FPDF_LoadCustomDocument
  // - PDFium reads blocks on-demand via callback
  // - Stream is NOT duplicated in memory
  // - Stream must remain valid for document lifetime
  // - Best for: Large PDFs, network streams, memory-constrained scenarios

  LStream := TMemoryStream.Create;

  // Example: Load from HTTP, database, encrypted container, etc.
  LStream.LoadFromFile('C:\Documents\large_report.pdf');
  LStream.Position := 0;

  // Option A: Keep ownership of stream (you manage lifetime)
  APdfViewer.LoadFromStream(LStream, False);  // AOwnsStream = False
  // You MUST keep LStream alive until document is closed!
  // You MUST free LStream yourself later

  // Option B: Transfer ownership to viewer (recommended)
  // APdfViewer.LoadFromStream(LStream, True);  // AOwnsStream = True
  // Viewer will free the stream when document is closed
  // DO NOT free LStream yourself!

  // Memory impact: Only 1x PDF size (the stream itself)
  // PDFium reads blocks on-demand - no duplication!
end;

class procedure TPdfLoadingExamples.CompareMemoryUsage;
var
  LDocument: TPdfDocument;
  LStream: TMemoryStream;
begin
  // Comparison for a 100 MB PDF file:
  //
  // ┌─────────────────────────────────────────────────────────────┐
  // │ Method              │ Memory Usage    │ Recommendation      │
  // ├─────────────────────────────────────────────────────────────┤
  // │ LoadFromFile        │ Unknown*        │ ✅ Good for local   │
  // │                     │                 │    files            │
  // ├─────────────────────────────────────────────────────────────┤
  // │ LoadFromStream      │ ~100 MB         │ ✅ Best for streams │
  // │                     │ (1x, no copy)   │    and large files  │
  // └─────────────────────────────────────────────────────────────┘
  //
  // * PDFium's internal implementation is not documented
  //   Could be memory-mapped, buffered, or streaming

  LDocument := TPdfDocument.Create;
  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile('large_file.pdf');

    // Use LoadFromStream for efficient streaming
    LDocument.LoadFromStream(LStream, False);

    // Stream is NOT duplicated - PDFium reads on-demand
    // Memory usage = stream size only
  finally
    LStream.Free;
    LDocument.Free;
  end;
end;

end.

