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
// The following sample illustrates how to find and replace text in a PDF document.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func TestFindReplace(t *testing.T) {

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)

    // Open a PDF document to edit
    doc := NewPDFDoc(inputPath + "find-replace-test.pdf")
    options := NewFindReplaceOptions()

    // Set some find/replace options
    options.SetWholeWords(true)
    options.SetMatchCase(true)
    options.SetMatchMode(FindReplaceOptionsE_exact)
    options.SetReflowMode(FindReplaceOptionsE_para)
    options.SetAlignment(FindReplaceOptionsE_left)

    // Perform a Find/Replace finding "the" with "THE INCREDIBLE"
    FindReplaceFindReplaceText(doc, "the", "THE INCREDIBLE", options)

    // Save the edited PDF
    doc.Save(outputPath + "find-replace-test-replaced.pdf", uint(SDFDocE_linearized))

    doc.Close()

    PDFNetTerminate()
    fmt.Println("Done.")
}
