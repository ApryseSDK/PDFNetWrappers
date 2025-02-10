//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"testing"
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
// documents and files to HTML.
//
// There are two HTML modules and one of them is an optional PDFNet Add-on.
// 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
//    documents.
// 2. The optional add-on module is used to convert PDF documents to HTML documents with
//    text flowing across the browser window.
//
// The PDFTron SDK HTML add-on module can be downloaded from https://dev.apryse.com/
//
// Please contact us if you have any questions.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func catch(err *error) {
    if r := recover(); r != nil {
        *err = fmt.Errorf("%v", r)
    }
}

//---------------------------------------------------------------------------------------

func ConvertToHtmlFixedPositionTest() (err error) {
	defer catch(&err)

	// Convert PDF document to HTML with fixed positioning option turned on (default)
	fmt.Println("Converting PDF to HTML with fixed positioning option turned on (default)")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_fixed_positioning"

	// Convert to HTML
	ConvertToHtml(inputFile, outputFile)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func ConvertToHtmlReflowParagraphTest1() (err error) {
	defer catch(&err)

	// Convert PDF document to HTML with reflow full option turned on (1)
	fmt.Println("Converting PDF to HTML with reflow full option turned on (1)")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_reflow_full.html"

	htmlOutputOptions := NewHTMLOutputOptions()

	// Set e_reflow_full content reflow setting
	htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptionsE_reflow_full);

	// Convert to HTML
	ConvertToHtml(inputFile, outputFile, htmlOutputOptions)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func ConvertToHtmlReflowParagraphTest2() (err error) {
	defer catch(&err)

	// Convert PDF document to HTML with reflow full option turned on (only converting the first page) (2)
	fmt.Println("Converting PDF to HTML with reflow full option turned on (only converting the first page) (2)")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_reflow_full_first_page.html"

	htmlOutputOptions := NewHTMLOutputOptions()

	// Set e_reflow_full content reflow setting
	htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptionsE_reflow_full);

	// Convert only the first page
	htmlOutputOptions.SetPages(1, 1);

	// Convert to HTML
	ConvertToHtml(inputFile, outputFile, htmlOutputOptions)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func TestPDF2HTML(t *testing.T) {
    // The first step in every application using PDFNet is to initialize the 
    // library. The library is usually initialized only once, but calling 
    // Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)

	//-----------------------------------------------------------------------------------

	// Convert PDF document to HTML with fixed positioning option turned on (default)
	err := ConvertToHtmlFixedPositionTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")

	if !StructuredOutputModuleIsModuleAvailable() {
		fmt.Println("")
		fmt.Println("Unable to run part of the sample: PDFTron SDK Structured Output module not available.")
		fmt.Println("-------------------------------------------------------------------------------------")
		fmt.Println("The Structured Output module is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required file")
		fmt.Println("using the PDFNet::AddResourceSearchPath() function.")
		fmt.Println("")
		return
	}

	//-----------------------------------------------------------------------------------

	// Convert PDF document to HTML with reflow full option turned on (1)
	err = ConvertToHtmlReflowParagraphTest1()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	// Convert PDF document to HTML with reflow full option turned on (only converting the first page) (2)
	err = ConvertToHtmlReflowParagraphTest2()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

    PDFNetTerminate()
    fmt.Println("Done.")
}
