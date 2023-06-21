//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"testing"
	"fmt"
	"flag"
	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to PDF, XPS, or SVG, or EMF. The sample also shows how to convert MS Office files 
// using our built in conversion.
//
// Certain file formats such as XPS, EMF, PDF, and raster image formats can be directly 
// converted to PDF or XPS. 
//
// Please contact us if you have any questions.    
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"


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
func ConvertToPdfFromFile() bool{
	testFiles := [][]string{
	{"simple-word_2007.docx","docx2pdf.pdf"}, 
	{"simple-powerpoint_2007.pptx","pptx2pdf.pdf"}, 
	{"simple-excel_2007.xlsx","xlsx2pdf.pdf"}, 

	{"simple-text.txt","txt2pdf.pdf"}, 
	{"butterfly.png","png2pdf.pdf"}, 
	{"simple-xps.xps","xps2pdf.pdf"}}
    ret := false


	for _, testfile := range testFiles {

        pdfdoc := NewPDFDoc()
        inputFile := testfile[0]
        outputFile := testfile[1]
        PrinterSetMode(PrinterE_prefer_builtin_converter)
        ConvertToPdf(pdfdoc, inputPath + inputFile)
        pdfdoc.Save(outputPath + outputFile, uint(SDFDocE_linearized))
        pdfdoc.Close()
        fmt.Println("Converted file: " + inputFile + "\nto: " + outputFile)
	}
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

    PDFNetTerminate()
    fmt.Println("Done.")
}
