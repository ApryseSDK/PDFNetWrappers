//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"os"
	. "pdftron"
)

import "pdftron/Samples/LicenseKey/GO"

//---------------------------------------------------------------------------------------
// The Data Extraction suite is an optional PDFNet add-on collection that can be used to
// extract various types of data from PDF documents.
//
// The PDFTron SDK Data Extraction suite can be downloaded from
// https://www.pdftron.com/documentation/core/info/modules/
//
// Please contact us if you have any questions.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

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

func TestTabularData() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_Tabular) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Tabular Data module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://www.pdftron.com/documentation/core/info/modules/. If you have already")
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

	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_Tabular).(string)
	WriteTextToFile(outputPath + "tableAsString.json", json)

	fmt.Println("Result saved in " + outputFile)

	// Extract tabular data as an XLSX file
	fmt.Println("Extract tabular data as an XLSX file")

	outputFile = outputPath + "table.xlsx"
	DataExtractionModuleExtractToXSLX(inputFile, outputFile)

	fmt.Println("Result saved in " + outputFile)

	// Extract tabular data as an XLSX stream (also known as filter)
	fmt.Println("Extract tabular data as an XLSX stream")

	outputFile = outputPath + "table_streamed.xlsx"
	outputXlsxStream := NewMemoryFilter(0, false)
	options := NewDataExtractionOptions()
	options.SetPages("1"); // page 1
	DataExtractionModuleExtractToXSLX(inputFile, outputXlsxStream, options)
	outputXlsxStream.SetAsInputFilter()
	outputXlsxStream.WriteToFile(outputFile, false)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract document structure from PDF documents.
//---------------------------------------------------------------------------------------

func TestDocumentStructure() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_DocStructure) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://www.pdftron.com/documentation/core/info/modules/. If you have already")
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

	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_DocStructure).(string)
	WriteTextToFile(outputPath + "paragraphs_and_tables_AsString.json", json)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to extract form fields from PDF documents.
//---------------------------------------------------------------------------------------

func TestFormFields() (err error) {
	defer catch(&err)

	// Test if the add-on is installed
	if !DataExtractionModuleIsModuleAvailable(DataExtractionModuleE_Form) {
		fmt.Println("")
		fmt.Println("Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available.")
		fmt.Println("-----------------------------------------------------------------------------")
		fmt.Println("The Data Extraction suite is an optional add-on, available for download")
		fmt.Println("at https://www.pdftron.com/documentation/core/info/modules/. If you have already")
		fmt.Println("downloaded this module, ensure that the SDK is able to find the required files")
		fmt.Println("using the PDFNetAddResourceSearchPath() function.")
		fmt.Println("")
		return nil
	}

	// Extract form fields as a JSON file
	fmt.Println("Extract form fields as a JSON file")

	inputFile := inputPath + "formfield.pdf"
	outputFile := outputPath + "formfield.json"
	DataExtractionModuleExtractData(inputFile, outputFile, DataExtractionModuleE_Form)

	json := DataExtractionModuleExtractData(inputFile, DataExtractionModuleE_Form).(string)
	WriteTextToFile(outputPath + "formfieldAsString.json", json)

	fmt.Println("Result saved in " + outputFile)

	return nil
}

//---------------------------------------------------------------------------------------

func main() {
	// The first step in every application using PDFNet is to initialize the 
	// library. The library is usually initialized only once, but calling 
	// Initialize() multiple times is also fine.
	PDFNetInitialize(PDFTronLicense.Key)

	//-----------------------------------------------------------------------------------

	PDFNetAddResourceSearchPath("../../../PDFNetC/Lib/")

	//-----------------------------------------------------------------------------------

	err := TestTabularData()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract tabular data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = TestDocumentStructure()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract document structure data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	err = TestFormFields()
	if err != nil {
		fmt.Println(fmt.Errorf("Unable to extract form fields data, error: %s", err))
	}

	//-----------------------------------------------------------------------------------

	PDFNetTerminate()
	fmt.Println("Done.")
}
