//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	"strconv"
	. "pdftron"
)

import  "pdftron/Samples/LicenseKey/GO"

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

func main(){
    outputPath := "../../TestFiles/Output/html2pdf_example"
    host := "http://www.swig.org/"
    page0 := ""
    page1 := "doc.html"
    page2 := "history.html"
    page3 := "survey.html"
    
    // The first step in every application using PDFNet is to initialize the 
    // library and set the path to common PDF resources. The library is usually 
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(PDFTronLicense.Key)
    
    // For HTML2PDF we need to locate the html2pdf module. If placed with the 
    // PDFNet library, or in the current working directory, it will be loaded
    // automatically. Otherwise, it must be set manually using HTML2PDF.SetModulePath.
    HTML2PDFSetModulePath("../../../PDFNetC/Lib/")
    
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
    converter.SetImageQuality(25)
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
    
    // Add a cover page, which is excluded from the outline, and ignore any errors
    cover := NewWebPageSettings()
    cover.SetLoadErrorHandling(WebPageSettingsE_ignore)
    cover.SetIncludeInOutline(false)
    converter.InsertFromURL(host + page3, cover)
    
    // Add a table of contents settings (modifying the settings is optional)
    toc := NewTOCSettings()
    toc.SetDottedLines(false)
    converter.InsertTOC(toc)

    // Now add the rest of the web pages, disabling external links and 
    // skipping any web pages that fail to load.
    // Note that the order of insertion matters, so these will appear
    // after the cover and table of contents, in the order below.
    settings := NewWebPageSettings()
    settings.SetLoadErrorHandling(WebPageSettingsE_skip)
    settings.SetExternalLinks(false)
    converter.InsertFromURL(host + page0, settings)
    converter.InsertFromURL(host + page1, settings)
    converter.InsertFromURL(host + page2, settings)
    
    if converter.Convert(doc){
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
