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
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//------------------------------------------------------------------------------
// The following sample illustrates how to use the PDF.Convert utility class 
// to convert MS Office files to PDF
//
// This conversion is performed entirely within the PDFNet and has *no* 
// external or system dependencies dependencies -- Conversion results will be
// the same whether on Windows, Linux or Android.
//
// Please contact us if you have any questions.
//------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func SimpleDocxConvert(inputFileName string, outputFileName string){
	// Start with a PDFDoc (the conversion destination)
    pdfdoc := NewPDFDoc()

    // perform the conversion with no optional parameters
    ConvertOfficeToPDF(pdfdoc, inputPath + inputFileName, NewConversionOptions())

    // save the result
    pdfdoc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

    // And we're done!
    fmt.Println("Saved " + outputFileName )
}

func FlexibleDocxConvert(inputFileName string , outputFileName string){
    // Start with a PDFDoc (the conversion destination)
    pdfdoc :=  NewPDFDoc()

    options :=  NewOfficeToPDFOptions() 

    // set up smart font substitutions to improve conversion results
    // in situations where the original fonts are not available
    options.SetSmartSubstitutionPluginPath(inputPath)

    // create a conversion object -- this sets things up but does not yet
    // perform any conversion logic.
    // in a multithreaded environment, this object can be used to monitor
    // the conversion progress and potentially cancel it as well
    conversion := ConvertStreamingPDFConversion(pdfdoc, inputPath + inputFileName, options)

    // Print the progress of the conversion.
    // print( "Status: " + str(conversion.GetProgress()*100) +"%, " +
    //        conversion.GetProgressLabel())

    // actually perform the conversion
    // this particular method will not throw on conversion failure, but will
    // return an error status instead
	for {
		if (conversion.GetConversionStatus() != DocumentConversionEIncomplete){
			break
		}
		conversion.ConvertNextPage()
		// print out the progress status as we go
		// print("Status: " + str(conversion.GetProgress()*100) + "%, " +
		//     conversion.GetProgressLabel() )
	}

    if(conversion.GetConversionStatus() == DocumentConversionESuccess){
        numWarnings := conversion.GetNumWarnings()
        // print information about the conversion
        for i := uint(0); i < numWarnings; i++ {
            fmt.Println("Conversion Warning: " + conversion.GetWarningString(i) )
            i = i + 1
		}
        // save the result
        pdfdoc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))
        // done
        fmt.Println("Saved " + outputFileName )
	}else{
        fmt.Println("Encountered an error during conversion: " + conversion.GetErrorString() )
	}
}

func TestOfficeToPDF(t *testing.T){
    // The first step in every application using PDFNet is to initialize the 
    // library. The library is usually initialized only once, but calling 
    // Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    PDFNetSetResourcesPath("../../Resources")

    // first the one-line conversion function
    SimpleDocxConvert("Fishermen.docx", "Fishermen.pdf")

    // then the more flexible line-by-line conversion API
    FlexibleDocxConvert("the_rime_of_the_ancient_mariner.docx", "the_rime_of_the_ancient_mariner.pdf")

    // conversion of RTL content
    FlexibleDocxConvert("factsheet_Arabic.docx", "factsheet_Arabic.pdf")
    PDFNetTerminate()

}
