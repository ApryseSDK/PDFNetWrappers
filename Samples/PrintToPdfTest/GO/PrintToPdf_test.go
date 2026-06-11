//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main

import (
	"flag"
	"fmt"
	"testing"

	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
	flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
	flag.StringVar(&modulePath, "modulePath", "", "Path for downloaded modules")
}

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

// ---------------------------------------------------------------------------------------
// The following sample illustrates how to convert documents to PDF format by printing
// them to the Apryse PDF printer via the Windows print verb, using the
// 'PrintToPdfModule' class.
//
// The PrintToPdf module is an optional PDFNet Add-on that can be used to convert any
// printable document into a PDF.
//
// The Apryse SDK PrintToPdf module can be downloaded from http://www.apryse.com/
//
// Note: The PrintToPdf module is only available on Windows.
// ---------------------------------------------------------------------------------------

func TestPrintToPdf(t *testing.T) {

	// The first step in every application using PDFNet is to initialize the
	// library and set the path to common PDF resources. The library is usually
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNetInitialize(licenseKey)

	// The location of the PrintToPdf Module
	PDFNetAddResourceSearchPath(modulePath)

	if !PrintToPdfModuleIsModuleAvailable() {

		fmt.Println("Unable to run PrintToPdfTest: Apryse SDK PrintToPdf module not available.\n" +
			"---------------------------------------------------------------\n" +
			"The PrintToPdf module is an optional add-on, available for download\n" +
			"at http://www.apryse.com/. If you have already downloaded this\n" +
			"module, ensure that the SDK is able to find the required files\n" +
			"using the PDFNet::AddResourceSearchPath() function.")

	} else {

		inputFileName := "simple-word_2007.docx"
		outputFileName := inputFileName + ".pdf"

		doc := NewPDFDoc()

		// Convert the document with some user options
		opts := NewPrintToPdfOptions()
		opts.SetPageOrientation("portrait")
		opts.SetHorizontalPageMargin(18)
		opts.SetVerticalPageMargin(18)
		// Page width and height in points (1/72 of an inch).
		// If both are zero (default), letter paper size is used.
		// opts.SetPageWidth(612)
		// opts.SetPageHeight(792)

		PrintToPdfModulePrintToPdf(doc, inputPath+inputFileName, opts)
		doc.Save(outputPath+outputFileName, uint(SDFDocE_linearized))

		fmt.Println("Printed file: " + inputFileName)
		fmt.Println("to: " + outputFileName)
	}
	PDFNetTerminate()
	fmt.Println("PrintToPdf conversion example")
}
