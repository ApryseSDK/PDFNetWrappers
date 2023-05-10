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

//------------------------------------------------------------------------------
// The following sample illustrates how to use ConvertOfficeToPDF
// to convert MS Office files to PDF and replace templated tags present in the document
// with content supplied via json
//
// For a detailed specification of the template format and supported features,
// see: https://docs.apryse.com/documentation/core/guides/generate-via-template/data-model/
//
// This conversion is performed entirely within the PDFNet and has *no*
// external or system dependencies -- Conversion results will be
// the same whether on Windows, Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func TestOfficeTemplate(t *testing.T){
    // The first step in every application using PDFNet is to initialize the
    // library. The library is usually initialized only once, but calling
    // Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    PDFNetSetResourcesPath("../../Resources")

    var inputFileName = "SYH_Letter.docx"
    var outputFileName = "SYH_Letter.pdf"
    var json = `
    {
		"dest_given_name": "Janice N.",
        "dest_street_address": "187 Duizelstraat",
        "dest_surname": "Symonds",
        "dest_title": "Ms.",
        "land_location": "225 Parc St., Rochelle, QC ",
        "lease_problem": "According to the city records, the lease was initiated in September 2010 and never terminated",
        "logo": { "image_url": "` + inputPath + `logo_red.png", "width" : 64, "height":  64 },
        "sender_name": "Arnold Smith"
	}`;

    // Create a TemplateDocument object from an input office file.
    var templateDoc = ConvertCreateOfficeTemplate(inputPath + inputFileName, NewOfficeToPDFOptions());

    // Fill the template with data from a JSON string, producing a PDF document.
    var pdfdoc = templateDoc.FillTemplateJson(json);

    // Save the PDF to a file.
    pdfdoc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

    // And we're done!
    fmt.Println("Saved " + outputFileName )
}
