//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"testing"
	"os"
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
// The Data Extraction suite is an optional PDFNet add-on collection that can be used to
// extract various types of data from PDF documents.
//
// The PDFTron SDK Data Extraction suite can be downloaded from
// https://docs.apryse.com/documentation/core/info/modules/
//
// Please contact us if you have any questions.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func catch(err *error) {
	if r := recover(); r != nil {
		*err = fmt.Errorf("%v", r)
	}
}

//---------------------------------------------------------------------------------------

func WriteTextToFile(outputFile string, text string) {
	f, err := os.Create(outputFile)
	if err != nil {
		fmt.Println(err)
	}

	defer f.Close()

	_, err2 := f.WriteString(text)
	if err2 != nil {
		fmt.Println(err2)
	}
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract tables from PDF documents.
//---------------------------------------------------------------------------------------

func TabularDataTest() (err error) {
	defer catch(&err)

    PDFNetAddResourceSearchPath(modulePath)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_Tabular) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Tabular Data module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	// Extract tabular data as a JSON file
	fmt.Println("Extract tabular data as a JSON file")

	inputFile := inputPath + "table.pdf"
	outputFile := outputPath + "table.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_Tabular)

	fmt.Println("Result saved in " + outputFile)

	// Extract tabular data as a JSON string
	fmt.Println("Extract tabular data as a JSON string")

	inputFile = inputPath + "financial.pdf"
	outputFile = outputPath + "financial.json"

	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_Tabular).(string)
	WriteTextToFile(outputFile, json)

	fmt.Println("Result saved in " + outputFile)

	// Extract tabular data as an XLSX file
	fmt.Println("Extract tabular data as an XLSX file")

	inputFile = inputPath + "table.pdf"
	outputFile = outputPath + "table.xlsx"
	DataExtractionModuleExtractToXLSX(inputFile, outputFile)

	fmt.Println("Result saved in " + outputFile)

	// Extract tabular data as an XLSX stream (also known as filter)
	fmt.Println("Extract tabular data as an XLSX stream")

	inputFile = inputPath + "financial.pdf"
	outputFile = outputPath + "financial.xlsx"
	outputXlsxStream := NewMemoryFilter(0, false)
	outputFilter := NewFilter(outputXlsxStream)
	options := NewDataExtractionOptions()
	options.SetPages("1"); // page 1
	DataExtractionModuleExtractToXLSX(inputFile, outputFilter, options)
	outputXlsxStream.SetAsInputFilter()
	outputXlsxStream.WriteToFile(outputFile, false)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract document structure from PDF documents.
//---------------------------------------------------------------------------------------

func DocumentStructureTest() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_DocStructure) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	// Extract document structure as a JSON file
	fmt.Println("Extract document structure as a JSON file")

	inputFile := inputPath + "paragraphs_and_tables.pdf"
	outputFile := outputPath + "paragraphs_and_tables.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_DocStructure)

	fmt.Println("Result saved in " + outputFile)

	// Extract document structure as a JSON string
	fmt.Println("Extract document structure as a JSON string")

	inputFile = inputPath + "tagged.pdf"
	outputFile = outputPath + "tagged.json"
	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_DocStructure).(string)
	WriteTextToFile(outputFile, json)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract form fields from PDF documents.
//---------------------------------------------------------------------------------------

func FormFieldsTest() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_Form) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	// Extract form fields as a JSON file
	fmt.Println("Extract form fields as a JSON file")

	inputFile := inputPath + "formfields-scanned.pdf"
	outputFile := outputPath + "formfields-scanned.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_Form)

	fmt.Println("Result saved in " + outputFile)

	// Extract form fields as a JSON string
	fmt.Println("Extract form fields as a JSON string")

	inputFile = inputPath + "formfields.pdf"
	outputFile = outputPath + "formfields.json"

	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_Form).(string)
	WriteTextToFile(outputFile, json)

	fmt.Println("Result saved in " + outputFile)

	//////////////////////////////////////////////////////////////////////////
	// Detect and add form fields to a PDF document.
	// PDF document already has form fields, and this sample will update to new found fields.
	doc := NewPDFDoc(inputPath + "formfields-scanned-withfields.pdf")

	fmt.Println("Extract form fields as a PDF file, keep new fields")
	DataExtractionModuleDetectAndAddFormFieldsToPDF(doc)

	outputFile = outputPath + "formfields-scanned-fields-new.pdf"
	doc.Save(outputFile, uint(SDFDocE_linearized))
	doc.Close()

	fmt.Println("Result saved in " + outputFile)

	//////////////////////////////////////////////////////////////////////////
	// Detect and add form fields to a PDF document.
	// PDF document already has form fields, and this sample will keep the original fields.
	doc = NewPDFDoc(inputPath + "formfields-scanned-withfields.pdf")

	// Setup DataExtractionOptions to keep old fields
	options := NewDataExtractionOptions()
	options.SetOverlappingFormFieldBehavior("KeepOld")

	fmt.Println("Extract form fields as a PDF file, keep old fields")
	DataExtractionModuleDetectAndAddFormFieldsToPDF(doc, options)

	outputFile = outputPath + "formfields-scanned-fields-old.pdf"
	doc.Save(outputFile, uint(SDFDocE_linearized))
	doc.Close()

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract key-value pairs from PDF documents.
//---------------------------------------------------------------------------------------

func GenericKeyValueTest() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_GenericKeyValue) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK AIPageObjectExtractor module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	fmt.Println("Extract key-value pairs from a PDF")

	inputFile := inputPath + "newsletter.pdf"
	outputFile := outputPath + "newsletter_key_val.json"
	// Simple example: Extract Keys & Values as a JSON file
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_GenericKeyValue)

	fmt.Println("Result saved in " + outputFile)

	// Example with customized options:
	// Extract Keys & Values from pages 2-4, excluding ads
	options := NewDataExtractionOptions()
	options.SetPages("2-4")
	
	p2ExclusionZones := NewRectCollection()
	// Exclude the ad on page 2
	// These coordinates are in PDF user space, with the origin at the bottom left corner of the page
	// Coordinates rotate with the page, if it has rotation applied.
	p2ExclusionZones.AddRect(NewRect(166, 47, 562, 222))
	options.AddExclusionZonesForPage(p2ExclusionZones, 2)

	p4InclusionZones := NewRectCollection()
	p4ExclusionZones := NewRectCollection()
	// Only include the article text for page 4, exclude ads and headings
	p4InclusionZones.AddRect(NewRect(30, 432, 562, 684))
	p4ExclusionZones.AddRect(NewRect(30, 657, 295, 684))
	options.AddInclusionZonesForPage(p4InclusionZones, 4)
	options.AddExclusionZonesForPage(p4ExclusionZones, 4)
	
	fmt.Println("Extract Key-Value pairs from specific pages and zones as a JSON file")
	outputFile = outputPath + "newsletter_key_val_with_zones.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_GenericKeyValue, options)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract document classes from PDF documents.
//---------------------------------------------------------------------------------------

func DocClassifierTest() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_DocClassification) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	// Simple example: classify pages as a JSON file
	fmt.Println("Classify pages as a JSON file")

	inputFile := inputPath + "Invoice.pdf"
	outputFile := outputPath + "Invoice_Classified.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_DocClassification)

	fmt.Println("Result saved in " + outputFile)

	// Classify pages as a JSON string
	fmt.Println("Classify pages as a JSON string")

	inputFile = inputPath + "Scientific_Publication.pdf"
	outputFile = outputPath + "Scientific_Publication_Classified.json"
	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_DocClassification).(string)
	WriteTextToFile(outputFile, json)

	fmt.Println("Result saved in " + outputFile)

	// Example with customized options:
	fmt.Println("Classify pages with customized options")

	inputFile = inputPath + "Email.pdf"
	outputFile = outputPath + "Email_Classified.json"
	options := NewDataExtractionOptions()
	// Classes that don't meet the minimum confidence threshold of 70% will not be listed in the output JSON
	options.SetMinimumConfidenceThreshold(0.7)
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_DocClassification, options)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------

func TestDataExtraction(t *testing.T) {
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	PDFNetInitialize(licenseKey)

	//-----------------------------------------------------------------------------------

	PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")

	//-----------------------------------------------------------------------------------

	err := TabularDataTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract tabular data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = DocumentStructureTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract document structure data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = FormFieldsTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract form fields data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = GenericKeyValueTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract key-value pairs, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = DocClassifierTest()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract document classifications, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	PDFNetTerminate()
	fmt.Println("Done.")
}
