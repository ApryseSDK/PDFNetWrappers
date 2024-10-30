//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"testing"
	"os"
	"flag"
	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Path for downloaded modules")
}

//---------------------------------------------------------------------------------------
// The Barcode Module is an optional PDFNet add-on that can be used to extract
// various types of barcodes from PDF documents.
//
// The Apryse SDK Barcode Module can be downloaded from http://dev.apryse.com/
//---------------------------------------------------------------------------------------

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/Barcode/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func WriteTextToFile(outputFile string, text string) {
	f, err := os.Create(outputFile)
	if err != nil {
		fmt.Println(err)
	}

	defer f.Close()

	_, err2 := f.WriteString(text)
	if err2 != nil {
		fmt.Println(err2)
	}
}

//---------------------------------------------------------------------------------------

func TestBarcode(t *testing.T) {

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)

    // The location of the Barcode Module
    PDFNetAddResourceSearchPath(modulePath)

    if ! BarcodeModuleIsModuleAvailable() {

        fmt.Println("Unable to run BarcodeTest: Apryse SDK Barcode Module not available.\n" +
        "---------------------------------------------------------------\n" +
        "The Barcode Module is an optional add-on, available for download\n" +
        "at https://dev.apryse.com/. If you have already downloaded this\n" +
        "module, ensure that the SDK is able to find the required files\n" +
        "using the PDFNetAddResourceSearchPath() function.")

    } else {

        // Example 1) Detect and extract all barcodes from a PDF document into a JSON file
        // --------------------------------------------------------------------------------

        fmt.Println("Example 1: extracting barcodes from barcodes.pdf to barcodes.json")

        // A) Open the .pdf document
        doc := NewPDFDoc(inputPath + "barcodes.pdf")

        // B) Detect PDF barcodes with the default options
        BarcodeModuleExtractBarcodes(doc, outputPath + "barcodes.json")

        doc.Close()

        // Example 2) Limit barcode extraction to a range of pages, and retrieve the JSON into a
        // local string variable, which is then written to a file in a separate function call
        // --------------------------------------------------------------------------------

        fmt.Println("Example 2: extracting barcodes from pages 1-2 to barcodes_from_pages_1-2.json")

        // A) Open the .pdf document
        doc = NewPDFDoc(inputPath + "barcodes.pdf")

        // B) Detect PDF barcodes with custom options
        options := NewBarcodeOptions()

        // Convert only the first two pages
        options.SetPages("1-2")

        json := BarcodeModuleExtractBarcodesAsString(doc, options)

        // C) Save JSON to file
        WriteTextToFile(outputPath + "barcodes_from_pages_1-2.json", json)

        doc.Close()

        // Example 3) Narrow down barcode types and allow the detection of both horizontal
        // and vertical barcodes
        // --------------------------------------------------------------------------------

        fmt.Println("Example 3: extracting basic horizontal and vertical barcodes")

        // A) Open the .pdf document
        doc = NewPDFDoc(inputPath + "barcodes.pdf")

        // B) Detect only basic 1D barcodes, both horizontal and vertical
        options = NewBarcodeOptions()

        // Limit extraction to basic 1D barcode types, such as EAN 13, EAN 8, UPCA, UPCE,
        // Code 3 of 9, Code 128, Code 2 of 5, Code 93, Code 11 and GS1 Databar.
        options.SetBarcodeSearchTypes(uint(BarcodeOptionsE_linear))

        // Search for barcodes oriented horizontally and vertically
        options.SetBarcodeOrientations(
				uint(BarcodeOptionsE_horizontal) |
				uint(BarcodeOptionsE_vertical))

        BarcodeModuleExtractBarcodes(doc, outputPath + "barcodes_1D.json", options)

        doc.Close()
	}

	PDFNetTerminate()
	fmt.Println("Done.")
}
