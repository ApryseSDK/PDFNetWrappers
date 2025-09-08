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
    flag.StringVar(&modulePath, "modulePath", "", "Path for downloaded modules")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract xlf from a PDF document for translation.
// It then applies a pre-prepared translated xlf file to the PDF to produce a translated PDF.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func TestTransPDF(t *testing.T) {

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)

    // Open a PDF document to translate
    doc := NewPDFDoc(inputPath + "find-replace-test.pdf")
    options := NewTransPDFOptions()

    // Set the source language in the options
    options.SetSourceLanguage("en")

    // Set the number of pages to process in each batch
    options.SetBatchSize(20)

    // Optionally, subset the pages to process
    // This PDF only has a single page, but you can specify a subset of pages like this
    // options.SetPages("-2,5-6,9,11-")

    // Extract the xlf to file and field the PDF for translation
    TransPDFExtractXLIFF(doc, outputPath + "find-replace-test.xlf", options)

    // Save the fielded PDF
    doc.Save(outputPath + "find-replace-test-fielded.pdf", uint(SDFDocE_linearized))

    // The extracted xlf can be translated in a system of your choice.
    // In this sample a pre-prepared translated file is used - find-replace-test_(en_to_fr).xlf

    // Perform the translation using the pre-prepared translated xliff
    TransPDFApplyXLIFF(doc, inputPath + "find-replace-test_(en_to_fr).xlf", options)

    // Save the translated PDF
    doc.Save(outputPath + "find-replace-test-fr.pdf", uint(SDFDocE_linearized))
    doc.Close()

    PDFNetTerminate()
    fmt.Println("Done.")
}
