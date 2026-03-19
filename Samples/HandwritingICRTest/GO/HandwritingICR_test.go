//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
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

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/HandwritingICR/"
var outputPath = "../TestFiles/Output/"

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

// ---------------------------------------------------------------------------------------
// The Handwriting ICR Module is an optional PDFNet add-on that can be used to extract
// handwriting from image-based pages and apply them as hidden text.
//
// The Apryse SDK Handwriting ICR Module can be downloaded from https://dev.apryse.com/
// --------------------------------------------------------------------------------------

func TestHandwritingICR(t *testing.T) {

	// The first step in every application using PDFNet is to initialize the
	// library and set the path to common PDF resources. The library is usually
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNetInitialize(licenseKey)

	// The location of the Handwriting ICR Module
	PDFNetAddResourceSearchPath(modulePath)

	// Test if the add-on is installed
	if !HandwritingICRModuleIsModuleAvailable() {

		fmt.Println("Unable to run HandwritingICRTest: Apryse SDK Handwriting ICR Module\n" +
			"not available.\n" +
			"---------------------------------------------------------------\n" +
			"The Handwriting ICR Module is an optional add-on, available for download\n" +
			"at https://dev.apryse.com/. If you have already downloaded this\n" +
			"module, ensure that the SDK is able to find the required files\n" +
			"using the PDFNetAddResourceSearchPath() function.")

	} else {

		// --------------------------------------------------------------------------------
		// Example 1) Process a PDF without specifying options
		fmt.Println("Example 1: processing icr.pdf")

		// Open the .pdf document
		doc := NewPDFDoc(inputPath + "icr.pdf")

		// Run ICR on the .pdf with the default options
		HandwritingICRModuleProcessPDF(doc)

		// Save the result with hidden text applied
		doc.Save(outputPath + "icr-simple.pdf", uint(SDFDocE_linearized))
		doc.Close()

		// --------------------------------------------------------------------------------
		// Example 2) Process a subset of PDF pages
		fmt.Println("Example 2: processing pages from icr.pdf")

		// Open the .pdf document
		doc = NewPDFDoc(inputPath + "icr.pdf")
		
		// Process handwriting with custom options
		options := NewHandwritingICROptions()
		
		// Optionally, process a subset of pages
		options.SetPages("2-3")

		// Run ICR on the .pdf
		HandwritingICRModuleProcessPDF(doc, options)

		// Save the result with hidden text applied
		doc.Save(outputPath + "icr-pages.pdf", uint(SDFDocE_linearized))
		doc.Close()

		// --------------------------------------------------------------------------------
		// Example 3) Ignore zones specified for each page
		fmt.Println("Example 3: processing & ignoring zones")

		// Open the .pdf document
		doc = NewPDFDoc(inputPath + "icr.pdf")
		
		// Process handwriting with custom options
		options = NewHandwritingICROptions()
		
		// Process page 2 by ignoring the signature area on the bottom
		options.SetPages("2")
		ignoreZonesPage2 = NewRectCollection()
		// These coordinates are in PDF user space, with the origin at the bottom left corner of the page.
		// Coordinates rotate with the page, if it has rotation applied.
		ignoreZonesPage2.AddRect(NewRect(78, 850.1 - 770, 340, 850.1 - 676))
		options.AddIgnoreZonesForPage(ignoreZonesPage2, 2)

		// Run ICR on the .pdf
		HandwritingICRModuleProcessPDF(doc, options)

		// Save the result with hidden text applied
		doc.Save(outputPath + "icr-ignore.pdf", uint(SDFDocE_linearized))
		doc.Close()

		// --------------------------------------------------------------------------------
		// Example 4) The postprocessing workflow has also an option of extracting ICR results
		// in JSON format, similar to the one used by the OCR Module
		fmt.Println("Example 4: extract & apply")

		// Open the .pdf document
		doc = NewPDFDoc(inputPath + "icr.pdf")
		
		// Extract ICR results in JSON format
		json := HandwritingICRModuleGetICRJsonFromPDF(doc)
		WriteTextToFile(outputPath + "icr-get.json", json)

		// Insert your post-processing step (whatever it might be)
		// ...

		// Apply potentially modified ICR JSON to the PDF
		HandwritingICRModuleApplyICRJsonToPDF(doc, json)

		// Save the result with hidden text applied
		doc.Save(outputPath + "icr-get-apply.pdf", uint(SDFDocE_linearized))
		doc.Close()

		fmt.Println("Done.")

		PDFNetTerminate()
	}
}
