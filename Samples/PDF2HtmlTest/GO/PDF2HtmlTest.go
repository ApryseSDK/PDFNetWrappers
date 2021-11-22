//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	. "pdftron"
)

import  "pdftron/Samples/LicenseKey/GO"

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF::Convert utility class to convert 
// documents and files to HTML.
//
// There are two HTML modules and one of them is an optional PDFNet Add-on.
// 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
//    documents.
// 2. The optional add-on module is used to convert PDF documents to HTML documents with
//    text flowing within paragraphs.
//
// The PDFTron SDK HTML add-on module can be downloaded from http://www.pdftron.com/
//
// Please contact us if you have any questions.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

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

	// Convert PDF document to HTML with reflow paragraphs option turned on (1)
	fmt.Println("Converting PDF to HTML with reflow paragraphs option turned on (1)")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_reflow_paragraphs.html"

	htmlOutputOptions := NewHTMLOutputOptions()

	// Set e_reflow_paragraphs content reflow setting
	htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptionsE_reflow_paragraphs);

	// Convert to HTML
	ConvertToHtml(inputFile, outputFile, htmlOutputOptions)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func ConvertToHtmlReflowParagraphTest2() (err error) {
	defer catch(&err)

	// Convert PDF document to HTML with reflow paragraphs option turned on (2)
	fmt.Println("Converting PDF to HTML with reflow paragraphs option turned on (2)")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_reflow_paragraphs_no_page_width.html"

	htmlOutputOptions := NewHTMLOutputOptions()

	// Set e_reflow_paragraphs content reflow setting
	htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptionsE_reflow_paragraphs);

	// Set to flow paragraphs across the entire browser window.
	htmlOutputOptions.SetNoPageWidth(true);

	// Convert to HTML
	ConvertToHtml(inputFile, outputFile, htmlOutputOptions)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func main() {
    // The first step in every application using PDFNet is to initialize the 
    // library. The library is usually initialized only once, but calling 
    // Initialize() multiple times is also fine.
    PDFNetInitialize(PDFTronLicense.Key)

	//-----------------------------------------------------------------------------------

	// Convert PDF document to HTML with fixed positioning option turned on (default)
	err := ConvertToHtmlFixedPositionTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")

	if !PDF2WordModuleIsModuleAvailable() {
		fmt.Println("")
		fmt.Println("Unable to run part of the sample: PDFTron SDK HTML reflow paragraphs module not available.")
		fmt.Println("---------------------------------------------------------------")
		fmt.Println("The HTML reflow paragraphs module is an optional add-on, available for download")
		fmt.Println("at https://www.pdftron.com/documentation/core/info/modules/.")
		fmt.Println("If you have already downloaded this module, ensure that the SDK")
		fmt.Println("is able to find the required file using the")
		fmt.Println("PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return
	}

	//-----------------------------------------------------------------------------------

	// CConvert PDF document to HTML with reflow paragraphs option turned on (1)
	err = ConvertToHtmlReflowParagraphTest1()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	// CConvert PDF document to HTML with reflow paragraphs option turned on (2)
	err = ConvertToHtmlReflowParagraphTest2()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to HTML, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

    PDFNetTerminate()
    fmt.Println("Done.")
}
