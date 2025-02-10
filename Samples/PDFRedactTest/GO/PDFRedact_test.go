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

// PDF Redactor is a separately licensable Add-on that offers options to remove
// (not just covering or obscuring) content within a region of PDF. 
// With printed pages, redaction involves blacking-out or cutting-out areas of 
// the printed page. With electronic documents that use formats such as PDF, 
// redaction typically involves removing sensitive content within documents for 
// safe distribution to courts, patent and government institutions, the media, 
// customers, vendors or any other audience with restricted access to the content. 
//
// The redaction process in PDFNet consists of two steps:
// 
//  a) Content identification: A user applies redact annotations that specify the 
// pieces or regions of content that should be removed. The content for redaction 
// can be identified either interactively (e.g. using 'pdftron.PDF.PDFViewCtrl' 
// as shown in PDFView sample) or programmatically (e.g. using 'pdftron.PDF.TextSearch'
// or 'pdftron.PDF.TextExtractor'). Up until the next step is performed, the user 
// can see, move and redefine these annotations.
//  b) Content removal: Using 'pdftron.PDF.Redactor.Redact()' the user instructs 
// PDFNet to apply the redact regions, after which the content in the area specified 
// by the redact annotations is removed. The redaction function includes number of 
// options to control the style of the redaction overlay (including color, text, 
// font, border, transparency, etc.).
// 
// PDFTron Redactor makes sure that if a portion of an image, text, or vector graphics 
// is contained in a redaction region, that portion of the image or path data is 
// destroyed and is not simply hidden with clipping or image masks. PDFNet API can also 
// be used to review and remove metadata and other content that can exist in a PDF 
// document, including XML Forms Architecture (XFA) content and Extensible Metadata 
// Platform (XMP) content.

func Redact(input string, output string, vec VectorRedaction, app Appearance){
    doc := NewPDFDoc(input)
    if doc.InitSecurityHandler(){
        RedactorRedact(doc, vec, app, false, true)
        doc.Save(output, uint(SDFDocE_linearized))
    }
}                                  

func TestPDFRedact(t *testing.T){

    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    PDFNetInitialize(licenseKey)
    
    vec := NewVectorRedaction()
    vec.Add(NewRedaction(1, NewRect(100.0, 100.0, 550.0, 600.0), false, "Top Secret"))
    vec.Add(NewRedaction(2, NewRect(30.0, 30.0, 450.0, 450.0), true, "Negative Redaction"))
    vec.Add(NewRedaction(2, NewRect(0.0, 0.0, 100.0, 100.0), false, "Positive"))
    vec.Add(NewRedaction(2, NewRect(100.0, 100.0, 200.0, 200.0), false, "Positive"))
    vec.Add(NewRedaction(2, NewRect(300.0, 300.0, 400.0, 400.0), false, ""))
    vec.Add(NewRedaction(2, NewRect(500.0, 500.0, 600.0, 600.0), false, ""))
    vec.Add(NewRedaction(3, NewRect(0.0, 0.0, 700.0, 20.0), false, ""))
	
    app := NewAppearance() 
    app.SetRedactionOverlay(true)
    app.SetBorder(false)
    app.SetShowRedactedContentRegions(true)
    Redact(inputPath + "newsletter.pdf", outputPath + "redacted.pdf", vec, app)
    
    PDFNetTerminate()
    fmt.Println("Done...")
}
