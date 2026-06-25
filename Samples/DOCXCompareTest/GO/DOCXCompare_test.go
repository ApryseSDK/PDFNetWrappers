//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
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

//------------------------------------------------------------------------------
// The following sample illustrates how to use the Office.DOCXCompare utility
// class to compare two MS Word (DOCX) documents and produce a new DOCX document
// containing the differences between them as tracked changes.
//
// This comparison is performed entirely within the PDFNet and has *no* external
// or system dependencies -- Comparison results will be the same whether on
// Windows, Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

// Provide your own original and revised versions of a DOCX document here.
var originalFilename = "SYH_Letter.docx"
var revisedFilename = "SYH_Letter_revision2.docx"
var outputFilename = "SYH_Letter_changes.docx"

func TestDOCXCompare(t *testing.T){
    // The first step in every application using PDFNet is to initialize the
    // library. The library is usually initialized only once, but calling
    // Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    PDFNetSetResourcesPath("../../Resources")

    options := NewDOCXCompareOptions()

    // Compare the two DOCX documents, writing the differences as tracked
    // changes into the output DOCX document.
    result := DOCXCompareCompare(inputPath + originalFilename, inputPath + revisedFilename, outputPath + outputFilename, options)

    // And we're done!
    if result.DifferencesDetected() {
        fmt.Println("Differences detected, saved to " + outputFilename)
    } else {
        fmt.Println("No difference detected")
    }

    PDFNetTerminate()
    fmt.Println("Done.")
}

