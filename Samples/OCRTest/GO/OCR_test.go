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
    flag.StringVar(&modulePath, "modulePath", "", "Path for downloaded modules")
}

// Relative path to the folder containing test files.
var inputPath = "../TestFiles/OCR/"
var outputPath = "../TestFiles/Output/"

// ---------------------------------------------------------------------------------------
// The following sample illustrates how to use OCR module
// --------------------------------------------------------------------------------------

func TestOCR(t *testing.T){

    // The first step in every application using PDFNet is to initialize the
    // library and set the path to common PDF resources. The library is usually
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)

    // The location of the OCR Module
    PDFNetAddResourceSearchPath(modulePath);

    if ! OCRModuleIsModuleAvailable(){

        fmt.Println("Unable to run OCRTest: PDFTron SDK OCR module not available.\n" +
        "---------------------------------------------------------------\n" +
        "The OCR module is an optional add-on, available for download\n" +
        "at https://dev.apryse.com/. If you have already downloaded this\n" +
        "module, ensure that the SDK is able to find the required files\n" +
        "using the PDFNet::AddResourceSearchPath() function.")

    }else{

        // Example 1) Process image without specifying options, default language - English - is used
        // --------------------------------------------------------------------------------

        // A) Setup empty destination doc

        doc := NewPDFDoc()

        // B) Run OCR on the .png with options
        
        ocrOpts := NewOCROptions()
        OCRModuleImageToPDF(doc, inputPath + "psychomachia_excerpt.png", ocrOpts)

        // C) Check the result

        doc.Save(outputPath + "psychomachia_excerpt.pdf", uint(0))
        fmt.Println("Example 1: psychomachia_excerpt.png")

        // Example 2) Process document using multiple languages
        // --------------------------------------------------------------------------------

        // A) Setup empty destination doc

        doc = NewPDFDoc()

        // B) Setup options with multiple target languages, English will always be considered as secondary language

        opts := NewOCROptions()
        opts.AddLang("deu")
        opts.AddLang("fra")
        opts.AddLang("eng")

        // C) Run OCR on the .jpg with options

        OCRModuleImageToPDF(doc, inputPath + "multi_lang.jpg", opts)

        // D) Check the result

        doc.Save(outputPath + "multi_lang.pdf", uint(0))
        fmt.Println("Example 2: multi_lang.jpg")

        // Example 3) Process a .pdf specifying a language - German - and ignore zone comprising a sidebar image
        // --------------------------------------------------------------------------------

        // A) Open the .pdf document

        doc = NewPDFDoc(inputPath + "german_kids_song.pdf")

        // B) Setup options with a single language and an ignore zone

        opts = NewOCROptions()
        opts.AddLang("deu")

        ignoreZones := NewRectCollection()
        ignoreZones.AddRect(NewRect(424.0, 163.0, 493.0, 730.0))
        opts.AddIgnoreZonesForPage(ignoreZones, 1)

        // C) Run OCR on the .pdf with options

        OCRModuleProcessPDF(doc, opts)

        // D) check the result

        doc.Save(outputPath + "german_kids_song.pdf", uint(0))
        fmt.Println("Example 3: german_kids_song.pdf")

        // Example 4) Process multi-page tiff with text/ignore zones specified for each page,
        // optionally provide English as the target language
        // --------------------------------------------------------------------------------

        // A) Setup empty destination doc

        doc = NewPDFDoc()

        // B) Setup options with a single language plus text/ignore zones

        opts = NewOCROptions()
        opts.AddLang("eng")

        ignoreZones = NewRectCollection()

        // ignore signature box in the first 2 pages
        ignoreZones.AddRect(NewRect(1492.0, 56.0, 2236.0, 432.0))
        opts.AddIgnoreZonesForPage(ignoreZones, 1)

        opts.AddIgnoreZonesForPage(ignoreZones, 2)

        // can use a combination of ignore and text boxes to focus on the page area of interest,
        // as ignore boxes are applied first, we remove the arrows before selecting part of the diagram
        ignoreZones.Clear()
        ignoreZones.AddRect(NewRect(992.0, 1276.0, 1368.0, 1372.0))
        opts.AddIgnoreZonesForPage(ignoreZones, 3)

        textZones := NewRectCollection()
        // we only have text zones selected in page 3

        // select horizontal BUFFER ZONE sign
        textZones.AddRect(NewRect(900.0, 2384.0, 1236.0, 2480.0))

        // select right vertical BUFFER ZONE sign
        textZones.AddRect(NewRect(1960.0, 1976.0, 2016.0, 2296.0))
        // select Lot No.
        textZones.AddRect(NewRect(696.0, 1028.0, 1196.0, 1128.0))

        // select part of the plan inside the BUFFER ZONE
        textZones.AddRect(NewRect(428.0, 1484.0, 1784.0, 2344.0))
        textZones.AddRect(NewRect(948.0, 1288.0, 1672.0, 1476.0))
        opts.AddTextZonesForPage(textZones, 3)

        // C) Run OCR on the .pdf with options

        OCRModuleImageToPDF(doc, inputPath + "bc_environment_protection.tif", opts)

        // D) check the result

        doc.Save(outputPath + "bc_environment_protection.pdf", uint(0))
        fmt.Println("Example 4: bc_environment_protection.tif")

        // Example 5) Alternative workflow for extracting OCR result JSON, postprocessing
        // (e.g., removing words not in the dictionary or filtering special
        // out special characters), and finally applying modified OCR JSON to the source PDF document
        // --------------------------------------------------------------------------------

        // A) Open the .pdf document

        doc = NewPDFDoc(inputPath + "zero_value_test_no_text.pdf")

        // B) Run OCR on the .pdf with default English language

        opts = NewOCROptions()
        json := OCRModuleGetOCRJsonFromPDF(doc, opts)

        // C) Post-processing step (whatever it might be)

        fmt.Println("Have OCR result JSON, re-applying to PDF")

        OCRModuleApplyOCRJsonToPDF(doc, json)

        // D) Check the result

        doc.Save(outputPath + "zero_value_test_no_text.pdf", uint(0))
        fmt.Println("Example 5: extracting and applying OCR JSON from zero_value_test_no_text.pdf")

        // Example 6) The postprocessing workflow has also an option of extracting OCR results in XML format,
        // similar to the one used by TextExtractor
        // --------------------------------------------------------------------------------

        // A) Setup empty destination doc

        doc = NewPDFDoc()

        // B) Run OCR on the .tif with default English language, extracting OCR results in XML format. Note that
        // in the process we convert the source image into PDF.
        // We reuse this PDF document later to add hidden text layer to it.

        xml := OCRModuleGetOCRXmlFromImage(doc, inputPath + "physics.tif", opts)

        // C) Post-processing step (whatever it might be)

        fmt.Println("Have OCR result XML, re-applying to PDF")

        OCRModuleApplyOCRXmlToPDF(doc, xml)

        // D) Check the result

        doc.Save(outputPath + "physics.pdf", uint(0))
        fmt.Println("Example 6: extracting and applying OCR XML from physics.tif")

        // Example 7) Resolution can be manually set, when DPI missing from metadata or is wrong
        // --------------------------------------------------------------------------------

        // A) Setup empty destination doc

        doc = NewPDFDoc()

        // B) Setup options with a text zone

        opts = NewOCROptions()
        textZones = NewRectCollection()
        textZones.AddRect(NewRect(140.0, 870.0, 310.0, 920.0))
        opts.AddTextZonesForPage(textZones, 1)

        // C) Manually override DPI
        opts.AddDPI(100)

        // D) Run OCR on the .jpg with options
        OCRModuleImageToPDF(doc, inputPath + "corrupted_dpi.jpg", opts)

        // E) Check the result
        doc.Save(outputPath + "corrupted_dpi.pdf", uint(0))
        PDFNetTerminate()
        fmt.Println("Example 7: converting image with corrupted resolution metadata corrupted_dpi.jpg to pdf with searchable text")
    }
}
