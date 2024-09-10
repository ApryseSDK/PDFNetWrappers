//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"testing"
	"flag"
	"strconv"
	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
	flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
	flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to make sure a file meets the PDF/UA standard, using the PDFUAConformance class object.
// Note: this feature is currently experimental and subject to change
//
// DataExtractionModule is required (Mac users can use StructuredOutputModule instead)
// https://docs.apryse.com/documentation/core/info/modules/#data-extraction-module
// https://docs.apryse.com/documentation/core/info/modules/#structured-output-module (Mac)
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func TestPDFUA(t *testing.T) {

	input_file1 := input_path + "autotag_input.pdf"
	input_file2 := input_path + "table.pdf"
	output_file1 := output_path + "autotag_pdfua.pdf"
	output_file2 := output_path + "table_pdfua_linearized.pdf"

	PDFNetInitialize(licenseKey)

	fmt.Println("AutoConverting...")

	PDFNetAddResourceSearchPath(modulePath)

	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_DocStructure) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		PDFNetTerminate()
		return nil
	}

	pdf_ua := NewPDFUAConformance()

	fmt.Println("Simple Conversion...")

	// Perform conversion using default options
	pdf_ua.AutoConvert(input_file1, output_file1)

	fmt.Println("Converting With Options...")

	pdf_ua_opts := NewPDFUAOptions()
	pdf_ua_opts.SetSaveLinearized(true) // Linearize when saving output
	// Note: if file is password protected, you can use pdf_ua_opts.SetPassword()

	// Perform conversion using the options we specify
	pdf_ua.AutoConvert(input_file2, output_file2, pdf_ua_opts)

	PDFNetTerminate()
	fmt.Println("")
	fmt.Println("PDFUAConformance test completed.")
}
