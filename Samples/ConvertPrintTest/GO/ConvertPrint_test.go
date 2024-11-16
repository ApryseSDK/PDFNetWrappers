//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"testing"
	"fmt"
	"flag"
	"runtime"
	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert to PDF with virtual printer on Windows.
// It supports several input formats like docx, xlsx, rtf, txt, html, pub, emf, etc. For more details, visit 
// https://docs.apryse.com/documentation/windows/guides/features/conversion/convert-other/
//
// To check if ToPDF (or ToXPS) require that PDFNet printer is installed use Convert::RequiresPrinter(filename). 
// The installing application must be run as administrator. The manifest for this sample 
// specifies appropriate the UAC elevation.
//
// Note: the PDFNet printer is a virtual XPS printer supported on Vista SP1 and Windows 7.
// For Windows XP SP2 or higher, or Vista SP0 you need to install the XPS Essentials Pack (or 
// equivalent redistributables). You can download the XPS Essentials Pack from:
//		http://www.microsoft.com/downloads/details.aspx?FamilyId=B8DCFFDD-E3A5-44CC-8021-7649FD37FFEE&displaylang=en
// Windows XP Sp2 will also need the Microsoft Core XML Services (MSXML) 6.0:
//		http://www.microsoft.com/downloads/details.aspx?familyid=993C0BCF-3BCF-4009-BE21-27E85E1857B1&displaylang=en
//
// Note: Convert.fromEmf and Convert.toEmf will only work on Windows and require GDI+.
//
// Please contact us if you have any questions.	
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"


func ConvertSpecificFormats() bool{
	ret := false

        
	// Convert MSWord document to XPS
	fmt.Println("Converting DOCX to XPS")
	outputFile := "simple-word_2007.xps"
	ConvertToXps(inputPath + "simple-word_2007.docx", outputPath + outputFile)
	fmt.Println("Saved " + outputFile)

    // Start with a PDFDoc to collect the converted documents
    pdfdoc := NewPDFDoc()
    // Convert the EMF document to PDF
    s1 := inputPath + "simple-emf.emf"

    fmt.Println("Converting from EMF")
    ConvertFromEmf(pdfdoc, s1)
    outputFile = "emf2pdf v2.pdf"
    pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_remove_unused))
    fmt.Println("Saved " + outputFile)
        
    return ret
}
func ConvertToPdfFromFile() bool{
	testFiles := [][]string{
	{"simple-word_2007.docx","docx2pdf.pdf"}, 
	{"simple-powerpoint_2007.pptx","pptx2pdf.pdf"}, 
	{"simple-excel_2007.xlsx","xlsx2pdf.pdf"}, 
    {"simple-publisher.pub","pub2pdf.pdf"},
	{"simple-text.txt","txt2pdf.pdf"}, 
    { "simple-rtf.rtf","rtf2pdf.pdf"},
    { "simple-emf.emf","emf2pdf.pdf"},
    { "simple-webpage.mht","mht2pdf.pdf"},
    { "simple-webpage.html","html2pdf.pdf"}}
    ret := false

    if PrinterIsInstalled("PDFTron PDFNet"){
		PrinterSetPrinterName("PDFTron PDFNet")
    }else if ! PrinterIsInstalled(){
		fmt.Println("Installing printer (requires Windows platform and administrator)")
		PrinterInstall()
		fmt.Println("Installed printer " + PrinterGetPrinterName())
	}

	for _, testfile := range testFiles {

        pdfdoc := NewPDFDoc()
        inputFile := testfile[0]
        outputFile := testfile[1]
        if ConvertRequiresPrinter(inputPath + inputFile){
            fmt.Println("Using PDFNet printer to convert file " + inputFile)
		}
        ConvertToPdf(pdfdoc, inputPath + inputFile)
        pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_linearized))
        pdfdoc.Close()
        fmt.Println("Converted file: " + inputFile + "\nto: " + outputFile)
	}
    return ret
}

func TestConvertPrint(t *testing.T){
	if runtime.GOOS == "windows" {
		// The first step in every application using PDFNet is to initialize the 
		// library. The library is usually initialized only once, but calling 
		// Initialize() multiple times is also fine.
		PDFNetInitialize(licenseKey)

		// Demonstrate Convert.ToPdf and Convert.Printer
		err := ConvertToPdfFromFile()
		if err{
			fmt.Println("ConvertFile failed")
		}else{
			fmt.Println("ConvertFile succeeded")
		}
		// Demonstrate Convert.[FromEmf, FromXps, ToEmf, ToSVG, ToXPS]
		err = ConvertSpecificFormats()
		if err{
			fmt.Println("ConvertSpecificFormats failed")
		}else{
			fmt.Println("ConvertSpecificFormats succeeded")
		}
		fmt.Println("Uninstalling printer (requires Windows platform and administrator)")
		PrinterUninstall()
		fmt.Println("Uninstalled printer " + PrinterGetPrinterName())

		PDFNetTerminate()
		fmt.Println("Done.")
	}else{
		fmt.Println("ConvertPrintTest only available on Windows")
	}
}
