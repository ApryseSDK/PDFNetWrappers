//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package WebViewerConvertTest
import (
    "fmt"
    "testing"
    . "github.com/pdftron/pdftron-go/v2"
    "flag"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert PDF, XPS, image, MS Office, and 
// other image document formats to XOD format.
//
// Certain file formats such as PDF, generic XPS, EMF, and raster image formats can 
// be directly converted to XOD. Other formats such as MS Office 
// (Word, Excel, Publisher, Powerpoint, etc) can be directly converted via interop. 
// These types of conversions guarantee optimal output, while preserving important 
// information such as document metadata, intra document links and hyper-links, 
// bookmarks etc. 
//
// In case there is no direct conversion available, PDFNet can still convert from 
// any printable document to XOD using a virtual printer driver. To check 
// if a virtual printer is required use Convert::RequiresPrinter(filename). In this 
// case the installing application must be run as administrator. The manifest for this 
// sample specifies appropriate the UAC elevation. The administrator privileges are 
// not required for direct or interop conversions. 
//
// Please note that PDFNet Publisher (i.e. 'pdftron.PDF.Convert.ToXod') is an
// optionally licensable add-on to PDFNet Core SDK. For details, please see
// https://apryse.com/pricing.
//---------------------------------------------------------------------------------------

func TestWebViewerConvert(t *testing.T){
    // Relative path to the folder containing the test files.
    var inputPath = "../TestFiles/"
    var outputPath = "../TestFiles/Output/"

    PDFNetInitialize(licenseKey)

    // Sample 1:
    // Directly convert from PDF to XOD.
    ConvertToXod(inputPath + "newsletter.pdf", outputPath + "from_pdf.xod")

    // Sample 2:
    // Directly convert from generic XPS to XOD.
    ConvertToXod(inputPath + "simple-xps.xps", outputPath + "from_xps.xod")

    // Sample 3:
    // Directly convert from PNG to XOD.
    fmt.Println("Converting: " + inputPath + "butterfly.png" + " to: " + outputPath + "butterfly.xod")
    ConvertToXod(inputPath + "butterfly.png", outputPath + "butterfly.xod")

    // Sample 4:
    fmt.Println("Converting: " + inputPath + "numbered.pdf" + " to: " + outputPath + "numbered.xod")
    ConvertToXod(inputPath + "numbered.pdf", outputPath + "numbered.xod")

    // Sample 5:
    // Directly convert from JPG to XOD.
    fmt.Println("Converting: " + inputPath + "dice.jpg" + " to: " + outputPath + "dice.xod")
    ConvertToXod(inputPath + "dice.jpg", outputPath + "dice.xod")

    // Sample 6:
    // Directly convert from generic XPS to XOD.
    fmt.Println("Converting: " + inputPath + "simple-xps.xps" + " to: " + outputPath + "simple-xps.xod")
    ConvertToXod(inputPath + "simple-xps.xps", outputPath + "simple-xps.xod")

    PDFNetTerminate()
    fmt.Println("Done.")
}
