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

//------------------------------------------------------------------------------
// The following sample illustrates how to use ConvertOfficeToPDF
// to convert MS Office files to PDF and replace templated tags present in the document
// with content supplied via json
//
// For a detailed specification of the template format and supported features,
// see: https://www.pdftron.com/documentation/core/guides/generate-via-template/data-model/
//
// This conversion is performed entirely within the PDFNet and has *no*
// external or system dependencies -- Conversion results will be
// the same whether on Windows, Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

func main(){
    // The first step in every application using PDFNet is to initialize the
    // library. The library is usually initialized only once, but calling
    // Initialize() multiple times is also fine.
    PDFNetInitialize(PDFTronLicense.Key)
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

    var templateDoc = ConvertCreateOfficeTemplate(inputPath + inputFileName, NewOfficeToPDFOptions());

    var pdfdoc = templateDoc.FillTemplateJson(json);

    // save the result
    pdfdoc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

    // And we're done!
    fmt.Println("Saved " + outputFileName )
}
