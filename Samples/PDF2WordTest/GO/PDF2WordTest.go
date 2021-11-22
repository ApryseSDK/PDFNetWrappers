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
// documents and files to Word.
//
// The Word module is an optional PDFNet Add-on that can be used to convert PDF
// documents into Word documents.
//
// The PDFTron SDK Word module can be downloaded from http://www.pdftron.com/
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

func ConvertToWordTest() (err error) {
	defer catch(&err)

	// Convert PDF document to Word
	fmt.Println("Converting PDF to Word")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables.docx"

	// Convert to Word
	ConvertToWord(inputFile, outputFile)

	fmt.Println("Result saved in " + outputFile)
	return nil
}

//---------------------------------------------------------------------------------------

func ConvertToWordWithOptionsTest() (err error) {
	defer catch(&err)

	// Convert PDF document to Word with options
	fmt.Println("Converting PDF to Word with options")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables_first_page.docx"

	wordOutputOptions := NewWordOutputOptions()

	// Convert only the first page
	wordOutputOptions.SetPages(1, 1)

	// Convert to Word
	ConvertToWord(inputFile, outputFile, wordOutputOptions)

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

	PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")

	if !PDF2WordModuleIsModuleAvailable() {
		fmt.Println("")
		fmt.Println("Unable to run the sample: PDFTron SDK Word module not available.")
		fmt.Println("---------------------------------------------------------------")
		fmt.Println("The Word module is an optional add-on, available for download")
		fmt.Println("at https://www.pdftron.com/documentation/core/info/modules/.")
		fmt.Println("If you have already downloaded this module, ensure that the SDK")
		fmt.Println("is able to find the required files using the")
		fmt.Println("PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return
	}

	//-----------------------------------------------------------------------------------

	// Convert PDF document to Word
	err := ConvertToWordTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to Word, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	// Convert PDF document to Word with options
	err = ConvertToWordWithOptionsTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to convert PDF document to Word, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

    PDFNetTerminate()
    fmt.Println("Done.")
}
