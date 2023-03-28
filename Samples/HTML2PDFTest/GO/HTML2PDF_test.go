//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package HTML2PDFTest
import (
    "fmt"
    "testing"
    "strconv"
    . "github.com/pdftron/pdftron-go/v2"
    "flag"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Path for downloaded modules")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to convert HTML pages to PDF format using
// the HTML2PDF class.
// 
// 'pdftron.PDF.HTML2PDF' is an optional PDFNet Add-On utility class that can be 
// used to convert HTML web pages into PDF documents by using an external module (html2pdf).
//
// html2pdf modules can be downloaded from http://www.pdftron.com/pdfnet/downloads.html.
//
// Users can convert HTML pages to PDF using the following operations:
// - Simple one line static method to convert a single web page to PDF. 
// - Convert HTML pages from URL or string, plus optional table of contents, in user defined order. 
// - Optionally configure settings for proxy, images, java script, and more for each HTML page. 
// - Optionally configure the PDF output, including page size, margins, orientation, and more. 
// - Optionally add table of contents, including setting the depth and appearance.
//---------------------------------------------------------------------------------------

func TestHTM2PDF(t *testing.T){
    outputPath := "../TestFiles/Output/html2pdf_example"
    host := "https://www.pdftron.com"
    page0 := "/"
    page1 := "/support"
    page2 := "/blog"
 
    // The first step in every application using PDFNet is to initialize the 
    // library and set the path to common PDF resources. The library is usually 
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    
    // For HTML2PDF we need to locate the html2pdf module. If placed with the 
    // PDFNet library, or in the current working directory, it will be loaded
    // automatically. Otherwise, it must be set manually using HTML2PDF.SetModulePath.
    HTML2PDFSetModulePath(modulePath)
    if ! HTML2PDFIsModuleAvailable(){
        fmt.Println("Unable to run HTML2PDFTest: PDFTron SDK HTML2PDF module not available.\n" +
        "---------------------------------------------------------------\n" +
        "The HTML2PDF module is an optional add-on, available for download\n" +
        "at http://www.pdftron.com/. If you have already downloaded this\n" +
        "module, ensure that the SDK is able to find the required files\n" +
        "using the HTML2PDF::SetModulePath() function.")
        return
    }
    
    //--------------------------------------------------------------------------------
    // Example 1) Simple conversion of a web page to a PDF doc. 

    doc := NewPDFDoc()
    // now convert a web page, sending generated PDF pages to doc
    converter := NewHTML2PDF()
    converter.InsertFromURL(host + page0)
    if converter.Convert(doc){
        doc.Save(outputPath + "_01.pdf", uint(SDFDocE_linearized))
	}else{
        fmt.Println("Conversion failed.")
    }

    //--------------------------------------------------------------------------------
    // Example 2) Modify the settings of the generated PDF pages and attach to an
    // existing PDF document. 
    
    // open the existing PDF, and initialize the security handler
    doc = NewPDFDoc("../../TestFiles/numbered.pdf")
    doc.InitSecurityHandler()
    
    // create the HTML2PDF converter object and modify the output of the PDF pages
    converter = NewHTML2PDF()
    converter.SetPaperSize(PrinterModeE_11x17)
    
    // insert the web page to convert
    converter.InsertFromURL(host + page0)
    
    // convert the web page, appending generated PDF pages to doc
    if converter.Convert(doc){
        doc.Save(outputPath + "_02.pdf", uint(SDFDocE_linearized))
    }else{
        fmt.Println("Conversion failed. HTTP Code: " + strconv.Itoa(converter.GetHTTPErrorCode()) + "\n" + converter.GetLog())
	}
    //--------------------------------------------------------------------------------
    // Example 3) Convert multiple web pages, adding a table of contents, and setting
    // the first page as a cover page, not to be included with the table of contents outline.
    
    doc = NewPDFDoc()
    converter = NewHTML2PDF()

    header := "<div style='width:15%;margin-left:0.5cm;text-align:left;font-size:10px;color:#0000FF'><span class='date'></span></div><div style='width:70%;direction:rtl;white-space:nowrap;overflow:hidden;text-overflow:clip;text-align:center;font-size:10px;color:#0000FF'><span>PDFTRON HEADER EXAMPLE</span></div><div style='width:15%;margin-right:0.5cm;text-align:right;font-size:10px;color:#0000FF'><span class='pageNumber'></span> of <span class='totalPages'></span></div>"
    footer := "<div style='width:15%;margin-left:0.5cm;text-align:left;font-size:7px;color:#FF00FF'><span class='date'></span></div><div style='width:70%;direction:rtl;white-space:nowrap;overflow:hidden;text-overflow:clip;text-align:center;font-size:7px;color:#FF00FF'><span>PDFTRON FOOTER EXAMPLE</span></div><div style='width:15%;margin-right:0.5cm;text-align:right;font-size:7px;color:#FF00FF'><span class='pageNumber'></span> of <span class='totalPages'></span></div>"
    converter.SetHeader(header)
    converter.SetFooter(footer)
    converter.SetMargins("1cm", "2cm", ".5cm", "1.5cm")
    settings := NewWebPageSettings()
    settings.SetZoom(0.5)
    converter.InsertFromURL(host + page0, settings)
    is_conversion_0_successful := converter.Convert(doc)

    // convert page 1 with the same settings, appending generated PDF pages to doc
    converter.InsertFromURL(host + page1, settings)
    is_conversion_1_successful := converter.Convert(doc)

    // convert page 2 with different settings, appending generated PDF pages to doc
    another_converter := NewHTML2PDF()
    another_converter.SetLandscape(true)
    another_settings := NewWebPageSettings()
    another_settings.SetPrintBackground(false)
    another_converter.InsertFromURL(host + page2, another_settings)
    is_conversion_2_successful := another_converter.Convert(doc);

    if(is_conversion_0_successful && is_conversion_1_successful && is_conversion_2_successful){
        doc.Save(outputPath + "_03.pdf", uint(SDFDocE_linearized))
    }else{
        fmt.Println("Conversion failed. HTTP Code: " + strconv.Itoa(converter.GetHTTPErrorCode()) + "\n" + converter.GetLog())
    }

    //--------------------------------------------------------------------------------
    // Example 4) Convert HTML string to PDF. 
    
    doc = NewPDFDoc()
    converter = NewHTML2PDF()
    
    // Our HTML data
    html := "<html><body><h1>Heading</h1><p>Paragraph.</p></body></html>"
    
    // Add html data
    converter.InsertFromHtmlString(html)
    // Note, InsertFromHtmlString can be mixed with the other Insert methods.
    
    if converter.Convert(doc){
        doc.Save(outputPath + "_04.pdf", uint(SDFDocE_linearized))
    }else{
        fmt.Println("Conversion failed. HTTP Code: " + strconv.Itoa(converter.GetHTTPErrorCode()) + "\n" + converter.GetLog())
	}
    PDFNetTerminate()
}
