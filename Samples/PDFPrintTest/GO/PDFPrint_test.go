//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "testing"
    "flag"
    "runtime"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// The following sample illustrates how to print PDF document using currently selected
// default printer. 
// 
// The first example uses the new PDF::Print::StartPrintJob function to send a rasterization 
// of the document with optimal compression to the printer.  If the OS is Windows 7, then the
// XPS print path will be used to preserve vector quality.  For earlier Windows versions
// the GDI print path will be used.  On other operating systems this will be a no-op
// 
// The second example uses PDFDraw send unoptimized rasterized data via awt.print API. 
// 
// If you would like to rasterize page at high resolutions (e.g. more than 600 DPI), you 
// should use PDFRasterizer or PDFNet vector output instead of PDFDraw.

func TestPDFPrint(t *testing.T){
    PDFNetInitialize(licenseKey)
    if runtime.GOOS != "windows" {
        // Not applicable
        return
    }

    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    
    doc := NewPDFDoc(inputPath + "tiger.pdf")
    doc.InitSecurityHandler()
    
    // Set our PrinterMode options
    printerMode := NewPrinterMode()
    printerMode.SetCollation(true)
    printerMode.SetCopyCount(1)
    printerMode.SetDPI(100); // regardless of ordering, an explicit DPI setting overrides the OutputQuality setting
    printerMode.SetDuplexing(PrinterModeE_Duplex_Auto)
    
    // If the XPS print path is being used, then the printer spooler file will
    // ignore the grayscale option and be in full color
    printerMode.SetOutputColor(PrinterModeE_OutputColor_Grayscale)
    printerMode.SetOutputQuality(PrinterModeE_OutputQuality_Medium)
    // printerMode.SetNUp(2,1)
    // printerMode.SetScaleType(PrinterModeE_ScaleType_FitToOutPage)
    
    // Print the PDF document to the default printer, using "tiger.pdf" as the document
    // name, send the file to the printer not to an output file, print all pages, set the printerMode
    // and a cancel flag to true
    pageSet := NewPageSet(1, doc.GetPageCount())
    boolValue := true
    PrintStartPrintJob(doc, "", doc.GetFileName(), "", pageSet, printerMode, &boolValue)
    PDFNetTerminate()
}
