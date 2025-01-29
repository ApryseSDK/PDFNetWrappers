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

// ---------------------------------------------------------------------------------------
// The following sample illustrates how to use Advanced Imaging module
// --------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/AdvancedImaging/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func catch(err *error) {
	if r := recover(); r != nil {
		*err = fmt.Errorf("%v", r)
	}
}

//---------------------------------------------------------------------------------------

func DicomTest() (err error) {
	defer catch(&err)

	inputFileName := "xray.dcm"
	outputFileName := inputFileName + ".pdf"
	doc := NewPDFDoc()
	ConvertFromDICOM(doc, inputPath + inputFileName)
	doc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

	return nil
}

//---------------------------------------------------------------------------------------

func HeicTest() (err error) {
	defer catch(&err)

	inputFileName := "jasper.heic"
	outputFileName := inputFileName + ".pdf"
	doc := NewPDFDoc()
	ConvertToPdf(doc, inputPath + inputFileName)
	doc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

	return nil
}

//---------------------------------------------------------------------------------------

func PsdTest() (err error) {
	defer catch(&err)

	inputFileName := "tiger.psd"
	outputFileName := inputFileName + ".pdf"
	doc := NewPDFDoc()
	ConvertToPdf(doc, inputPath + inputFileName)
	doc.Save(outputPath + outputFileName, uint(SDFDocE_linearized))

	return nil
}

//---------------------------------------------------------------------------------------

func TestAdvancedImagingModule(t *testing.T) {
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	PDFNetInitialize(licenseKey)

	//-----------------------------------------------------------------------------------

	PDFNetAddResourceSearchPath(modulePath)

	// Test if the add-on is installed
	if !AdvancedImagingModuleIsModuleAvailable() {
		fmt.Println("")
		fmt.Println("Unable to run AdvancedImagingTest: Apryse SDK AdvancedImaging module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The AdvancedImaging module is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
	} else {

		err := DicomTest()
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to convert DICOM test file, error: %s", err))
		}

		err = HeicTest()
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to convert the HEIC test file, error: %s", err))
		}

		err = PsdTest()
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to convert the PSD test file, error: %s", err))
		}
		fmt.Println("Done.")
	}

	PDFNetTerminate()
}
