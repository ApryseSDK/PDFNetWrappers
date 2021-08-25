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

// Relative path to the folder containing test files.
var inputPath = "../../TestFiles/CAD/"
var outputPath = "../../TestFiles/Output/"

// ---------------------------------------------------------------------------------------
// The following sample illustrates how to use CAD module
// --------------------------------------------------------------------------------------

func main(){

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(PDFTronLicense.Key)
    
    // The location of the CAD Module
    PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")
    
    if ! CADModuleIsModuleAvailable(){

        fmt.Println("Unable to run CAD2PDFTest: PDFTron SDK CAD module not available.\n" +
        "---------------------------------------------------------------\n" +
        "The CAD module is an optional add-on, available for download\n" +
        "at http://www.pdftron.com/. If you have already downloaded this\n" +
        "module, ensure that the SDK is able to find the required files\n" +
        "using the PDFNet::AddResourceSearchPath() function.")

    }else{

        inputFileName := "construction drawings color-28.05.18.dwg"
        outputFileName := inputFileName + ".pdf"
        doc := NewPDFDoc()
        ConvertFromCAD(doc, inputPath + inputFileName)
        doc.Save(outputPath + outputFileName, uint(0))
    }
    PDFNetTerminate()
    fmt.Println("CAD2PDF conversion example")
}
