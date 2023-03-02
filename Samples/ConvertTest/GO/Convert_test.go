//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"testing"
	"fmt"
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

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF.Convert utility class to convert 
// documents and files to PDF, XPS, SVG, or EMF.
//
// Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
// converted to PDF or XPS. Other formats are converted using a virtual driver. To check 
// if ToPDF (or ToXPS) require that PDFNet printer is installed use Convert.RequiresPrinter(filename). 
// The installing application must be run as administrator. The manifest for this sample 
// specifies appropriate the UAC elevation.
//
// Note: the PDFNet printer is a virtual XPS printer supported on Vista SP1 and Windows 7.
// For Windows XP SP2 or higher, or Vista SP0 you need to install the XPS Essentials Pack (or 
// equivalent redistributables). You can download the XPS Essentials Pack from:
//        http://www.microsoft.com/downloads/details.aspx?FamilyId=B8DCFFDD-E3A5-44CC-8021-7649FD37FFEE&displaylang=en
// Windows XP Sp2 will also need the Microsoft Core XML Services (MSXML) 6.0:
//         http://www.microsoft.com/downloads/details.aspx?familyid=993C0BCF-3BCF-4009-BE21-27E85E1857B1&displaylang=en
//
// Note: Convert.fromEmf and Convert.toEmf will only work on Windows and require GDI+.
//
// Please contact us if you have any questions.    
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func ConvertToPdfFromFile() bool{
	testFiles := [][]string{	
	{"simple-word_2007.docx","docx2pdf.pdf", "false"}, 
	{"simple-powerpoint_2007.pptx","pptx2pdf.pdf", "false"}, 
	{"simple-excel_2007.xlsx","xlsx2pdf.pdf", "false"}, 
	{"simple-publisher.pub","pub2pdf.pdf", "true"},
	//{"simple-visio.vsd","vsd2pdf.pdf}, // requires Microsoft Office Visio 
	{"simple-text.txt","txt2pdf.pdf", "false"}, 
	{"simple-rtf.rtf","rtf2pdf.pdf", "true"}, 
	{"butterfly.png","png2pdf.pdf", "false"}, 
	{"simple-emf.emf","emf2pdf.pdf", "true"}, 
	{"simple-xps.xps","xps2pdf.pdf", "false"}, 
	//{"simple-webpage.mht","mht2pdf.pdf", true}, 
	{"simple-webpage.html","html2pdf.pdf", "true"}}
    ret := false

    if runtime.GOOS == "windows" {
        if PrinterIsInstalled("PDFTron PDFNet"){
			PrinterSetPrinterName("PDFTron PDFNet")
        }else if ! PrinterIsInstalled(){
			fmt.Println("Installing printer (requires Windows platform and administrator)")
			PrinterInstall()
			fmt.Println("Installed printer " + PrinterGetPrinterName())
		}
	}

	for _, testfile := range testFiles {
	    if runtime.GOOS != "windows" {
            if testfile[2] == "true" {
                continue
			}
		}
        pdfdoc := NewPDFDoc()
        inputFile := testfile[0]
        outputFile := testfile[1]
        if ConvertRequiresPrinter(inputPath + inputFile){
            fmt.Println("Using PDFNet printer to convert file " + inputFile)
		}
        ConvertToPdf(pdfdoc, inputPath + inputFile)
        pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_compatibility))
        pdfdoc.Close()
        fmt.Println("Converted file: " + inputFile + "\nto: " + outputFile)
	}
    return ret
}

func ConvertSpecificFormats() bool{
	ret := false
    // Start with a PDFDoc to collect the converted documents
    pdfdoc := NewPDFDoc()
    s1 := inputPath + "simple-xps.xps"
    // Convert the XPS document to PDF
    fmt.Println("Converting from XPS")
    ConvertFromXps(pdfdoc, s1)
    outputFile := "xps2pdf v2.pdf"
    pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_remove_unused))
    fmt.Println("Saved " + outputFile)
        
    // Convert the EMF document to PDF
	if runtime.GOOS == "windows" {
		s1 = inputPath + "simple-emf.emf"
		fmt.Println("Converting from EMF")
		ConvertFromEmf(pdfdoc, s1)
		outputFile = "emf2pdf v2.pdf"
		pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_remove_unused))
		fmt.Println("Saved " + outputFile)
	}

	// Convert the TXT document to PDF
	set :=  NewObjSet()
	options := set.CreateDict()
	// Put options
	options.PutNumber("FontSize", 15)
	options.PutBool("UseSourceCodeFormatting", true)
	options.PutNumber("PageWidth", 12)
	options.PutNumber("PageHeight", 6)
	s1 = inputPath + "simple-text.txt"
	fmt.Println("Converting from txt")
	ConvertFromText(pdfdoc, s1)
	outputFile = "simple-text.pdf"
	pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_remove_unused))
	fmt.Println("Saved " + outputFile)
        
	// Convert the two page PDF document to SVG
	outputFile = "pdf2svg v2.svg"
	pdfdoc = NewPDFDoc(inputPath + "newsletter.pdf")
	fmt.Println("Converting pdfdoc to SVG")
	ConvertToSvg(pdfdoc, outputPath + outputFile)
	fmt.Println("Saved " + outputFile)
        
	// Convert the PNG image to XPS
	fmt.Println("Converting PNG to XPS")
	outputFile = "butterfly.xps"
	ConvertToXps(inputPath + "butterfly.png", outputPath +outputFile)
	fmt.Println("Saved " + outputFile)
            
	// Convert PDF document to XPS
	fmt.Println("Converting PDF to XPS")
	outputFile = "newsletter.xps"
	ConvertToXps(inputPath + "newsletter.pdf", outputPath + outputFile)
	fmt.Println("Saved " + outputFile)
        
	// Convert PDF document to HTML
	fmt.Println("Converting PDF to HTML")
	outputFile = "newsletter"
	ConvertToHtml(inputPath + "newsletter.pdf", outputPath + outputFile)
	fmt.Println("Saved newsletter as HTML")

	// Convert PDF document to EPUB
	fmt.Println("Converting PDF to EPUB")
	outputFile = "newsletter.epub"
	ConvertToEpub(inputPath + "newsletter.pdf", outputPath + outputFile)
	fmt.Println("Saved " + outputFile)

	fmt.Println("Converting PDF to multipage TIFF")
	tiffOptions := NewTiffOutputOptions()
	tiffOptions.SetDPI(200)
	tiffOptions.SetDither(true)
	tiffOptions.SetMono(true)
	ConvertToTiff(inputPath + "newsletter.pdf", outputPath + "newsletter.tiff", tiffOptions)
	fmt.Println("Saved newsletter.tiff")

	// Convert SVG file to PDF
	fmt.Println("Converting SVG to PDF")
	pdfdoc = NewPDFDoc()
	ConvertFromSVG(pdfdoc, inputPath + "tiger.svg")
	pdfdoc.Save(outputPath + "svg2pdf.pdf", uint(SDFDocE_remove_unused))
	fmt.Println("Saved svg2pdf.pdf")

    return ret
}

func TestConvert(t *testing.T){
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
	if runtime.GOOS == "windows" {
        fmt.Println("Uninstalling printer (requires Windows platform and administrator)")
        PrinterUninstall()
        fmt.Println("Uninstalled printer " + PrinterGetPrinterName())
	}
    PDFNetTerminate()
    fmt.Println("Done.")
}
