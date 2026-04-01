//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult legal.txt regarding legal and license information.
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
// PDFNet's Sanitizer is a security-focused feature that permanently removes
// hidden, sensitive, or potentially unsafe content from a PDF document.
// While redaction targets visible page content such as text or graphics,
// sanitization focuses on non-visual elements and embedded structures.
//
// PDFNet Sanitizer ensures hidden or inactive content is destroyed,
// not merely obscured or disabled. This prevents leakage of sensitive
// data such as authoring details, editing history, private identifiers,
// and residual form entries, and neutralizes scripts or attachments.
//
// Sanitization is recommended prior to external sharing with clients,
// partners, or regulatory bodies. It helps align with privacy policies
// and compliance requirements by permanently removing non-visual data.
//------------------------------------------------------------------------------

func TestPDFSanitize(t *testing.T){

    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"

    PDFNetInitialize(licenseKey)

	// The following example illustrates how to retrieve the existing
	// sanitizable content categories within a document.
	{
		doc := NewPDFDoc(inputPath + "numbered.pdf")
		doc.InitSecurityHandler()
		opts := SanitizerGetSanitizableContent(doc)
		if opts.GetMetadata() {
			fmt.Println("Document has metadata.")
		}
		if opts.GetMarkups() {
			fmt.Println("Document has markups.")
		}
		if opts.GetHiddenLayers() {
			fmt.Println("Document has hidden layers.")
		}
		fmt.Println("Done...")
	}

	// The following example illustrates how to sanitize a document with default options,
	// which will remove all sanitizable content present within a document.
	{
		doc := NewPDFDoc(inputPath + "financial.pdf")
		doc.InitSecurityHandler()
		SanitizerSanitizeDocument(doc, NewSanitizeOptions())
		doc.Save(outputPath+"financial_sanitized.pdf", uint(SDFDocE_linearized))
		fmt.Println("Done...")
	}

	// The following example illustrates how to sanitize a document with custom set options,
	// which will only remove the content categories specified by the options object.
	{
		options := NewSanitizeOptions()
		options.SetMetadata(true)
		options.SetFormData(true)
		options.SetBookmarks(true)

		doc := NewPDFDoc(inputPath + "form1.pdf")
		doc.InitSecurityHandler()
		SanitizerSanitizeDocument(doc, options)
		doc.Save(outputPath+"form1_sanitized.pdf", uint(SDFDocE_linearized))
		fmt.Println("Done...")
	}

    PDFNetTerminate()
}

