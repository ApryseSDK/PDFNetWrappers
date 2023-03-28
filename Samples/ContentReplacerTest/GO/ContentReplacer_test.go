//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
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

var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"    

//-----------------------------------------------------------------------------------------
// The sample code illustrates how to use the ContentReplacer class to make using 
// 'template' pdf documents easier.
//-----------------------------------------------------------------------------------------

func TestContentReplacer(t *testing.T){
	PDFNetInitialize(licenseKey)

	// Example 1) Update a business card template with personalized info

	doc := NewPDFDoc(inputPath + "BusinessCardTemplate.pdf")
	doc.InitSecurityHandler()

	// first, replace the image on the first page
	replacer := NewContentReplacer()
	page := doc.GetPage(1)
	img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
	replacer.AddImage(page.GetMediaBox(), img.GetSDFObj())
	// next, replace the text place holders on the second page
	replacer.AddString("NAME", "John Smith")
	replacer.AddString("QUALIFICATIONS", "Philosophy Doctor")
	replacer.AddString("JOB_TITLE", "Software Developer")
	replacer.AddString("ADDRESS_LINE1", "#100 123 Software Rd")
	replacer.AddString("ADDRESS_LINE2", "Vancouver, BC")
	replacer.AddString("PHONE_OFFICE", "604-730-8989")
	replacer.AddString("PHONE_MOBILE", "604-765-4321") 
	replacer.AddString("EMAIL", "info@pdftron.com")
	replacer.AddString("WEBSITE_URL", "http://www.pdftron.com")
	// finally, apply
	replacer.Process(page)

	doc.Save(outputPath + "BusinessCard.pdf", uint(SDFDocE_linearized))
	doc.Close()

	fmt.Println("Done. Result saved in BusinessCard.pdf")

	// Example 2) Replace text in a region with new text

	doc = NewPDFDoc(inputPath + "newsletter.pdf")
	doc.InitSecurityHandler()

	replacer = NewContentReplacer()
	page = doc.GetPage(1)
	replacer.AddText(page.GetMediaBox(), "hello hello hello hello hello hello hello hello hello hello")
	replacer.Process(page)

	doc.Save(outputPath + "ContentReplaced.pdf", uint(SDFDocE_linearized))
	doc.Close()

	fmt.Println("Done. Result saved in ContentReplaced.pdf")
	
    PDFNetTerminate()
	fmt.Println("Done.")
}
