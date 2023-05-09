//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
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

//---------------------------------------------------------------------------------------
// The following sample shows how to add new content (or watermark) PDF pages
// using 'pdftron.PDF.Stamper' utility class. 
//
// Stamper can be used to PDF pages with text, images, or with other PDF content 
// in only a few lines of code. Although Stamper is very simple to use compared 
// to ElementBuilder/ElementWriter it is not as powerful or flexible. In case you 
// need full control over PDF creation use ElementBuilder/ElementWriter to add 
// new content to existing PDF pages as shown in the ElementBuilder sample project.
//---------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"
var inputFilename = "newsletter"

func TestStamper(t *testing.T){
    // Initialize PDFNet
    PDFNetInitialize(licenseKey)
    
    //--------------------------------------------------------------------------------
    // Example 1) Add text stamp to all pages, then remove text stamp from odd pages. 
    doc := NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    s := NewStamper(StamperE_relative_scale, 0.5, 0.5)
    
    s.SetAlignment(StamperE_horizontal_center, StamperE_vertical_center)
    red := NewColorPt(1.0, 0.0, 0.0) // set text color to red
    s.SetFontColor(red)
    s.StampText(doc, "If you are reading this\nthis is an even page", NewPageSet(1, doc.GetPageCount()))
    // delete all text stamps in odd pages
    StamperDeleteStamps(doc, NewPageSet(1, doc.GetPageCount(), PageSetE_odd))
    
    doc.Save(outputPath + inputFilename + "E_x1.pdf", uint(SDFDocE_linearized))
    doc.Close()

    //--------------------------------------------------------------------------------
    // Example 2) Add Image stamp to first 2 pages. 
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    s = NewStamper(StamperE_relative_scale, 0.05, 0.05)
    img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    s.SetSize(StamperE_relative_scale, 0.5, 0.5)
    
    // set position of the image to the center, left of PDF pages
    s.SetAlignment(StamperE_horizontal_left, StamperE_vertical_center)
    pt := NewColorPt(0.0, 0.0, 0.0, 0.0)
    s.SetFontColor(pt)
    s.SetRotation(180)
    s.SetAsBackground(false)
    // only stamp first 2 pages
    ps := NewPageSet(1, 2)
    s.StampImage(doc, img, ps)
    
    doc.Save(outputPath + inputFilename + "E_x2.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 3) Add Page stamp to all pages. 
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    
    fishDoc := NewPDFDoc(inputPath + "fish.pdf")
    fishDoc.InitSecurityHandler()
    s = NewStamper(StamperE_relative_scale, 0.5, 0.5)
    srcPage := fishDoc.GetPage(1)
    pageOneCrop := srcPage.GetCropBox()
    // set size of the image to 10% of the original while keep the old aspect ratio
    s.SetSize(StamperE_absolute_size, pageOneCrop.Width() * 0.1, -1)
    s.SetOpacity(0.4)
    s.SetRotation(-67)
    // put the image at the bottom right hand corner
    s.SetAlignment(StamperE_horizontal_right, StamperE_vertical_bottom)
    ps = NewPageSet(1, doc.GetPageCount())
    s.StampPage(doc, srcPage, ps)
    doc.Save(outputPath + inputFilename + "E_x3.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 4) Add Image stamp to first 20 odd pages.
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    
    s = NewStamper(StamperE_absolute_size, 20.0, 20.0)
    s.SetOpacity(1)
    s.SetRotation(45)
    s.SetAsBackground(true)
    s.SetPosition(30.0, 40.0)
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    ps = NewPageSet(1, 20, PageSetE_odd)
    s.StampImage(doc, img, ps)
    
    doc.Save(outputPath + inputFilename + "E_x4.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 5) Add text stamp to first 20 even pages
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    s = NewStamper(StamperE_relative_scale, 0.05, 0.05)
    s.SetPosition(0.0, 0.0)
    s.SetOpacity(0.7)
    s.SetRotation(90)
    s.SetSize(StamperE_font_size, 80, -1)
    s.SetTextAlignment(StamperE_align_center)
    ps = NewPageSet(1, 20, PageSetE_even)
    s.StampText(doc, "Goodbye\nMoon", ps)
    
    doc.Save(outputPath + inputFilename + "E_x5.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 6) Add first page as stamp to all even pages
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    
    fishDoc = NewPDFDoc(inputPath + "fish.pdf");
    fishDoc.InitSecurityHandler()
    
    s = NewStamper(StamperE_relative_scale, 0.3, 0.3)
    s.SetOpacity(1)
    s.SetRotation(270)
    s.SetAsBackground(true)
    s.SetPosition(0.5, 0.5, true)
    s.SetAlignment(StamperE_horizontal_left, StamperE_vertical_bottom)
    pageOne := fishDoc.GetPage(1)
    ps = NewPageSet(1, doc.GetPageCount(), PageSetE_even)
    s.StampPage(doc, pageOne, ps)
    
    doc.Save(outputPath + inputFilename + "E_x6.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 7) Add image stamp at top left corner in every pages
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    
    s = NewStamper(StamperE_relative_scale, 0.1, 0.1)
    s.SetOpacity(0.8)
    s.SetRotation(135)
    s.SetAsBackground(false)
    s.ShowsOnPrint(false)
    s.SetAlignment(StamperE_horizontal_left, StamperE_vertical_top)
    s.SetPosition(10.0, 10.0)
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    ps = NewPageSet(1, doc.GetPageCount(), PageSetE_all)
    s.StampImage(doc, img, ps)
    doc.Save(outputPath + inputFilename + "E_x7.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 8) Add Text stamp to first 2 pages, and image stamp to first page.
    //          Because text stamp is set as background, the image is top of the text
    //          stamp. Text stamp on the first page is not visible.
    
    doc = NewPDFDoc(inputPath + inputFilename + ".pdf")
    doc.InitSecurityHandler()
    
    s = NewStamper(StamperE_relative_scale, 0.07, -0.1)
    s.SetAlignment(StamperE_horizontal_right, StamperE_vertical_bottom)
    s.SetAlignment(StamperE_horizontal_center, StamperE_vertical_top)
    s.SetFont(FontCreate(doc.GetSDFDoc(), FontE_courier, true))
    red = NewColorPt(1.0, 0.0, 0.0) 
    s.SetFontColor(red) // set text color to red
    s.SetTextAlignment(StamperE_align_right)
    s.SetAsBackground(true) // set text stamp as background
    ps = NewPageSet(1, 2)
    s.StampText(doc, "This is a title!", ps)
    
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    s.SetAsBackground(false)    // set image stamp as foreground
    firstPagePS := NewPageSet(1)
    s.StampImage(doc, img, firstPagePS)

    doc.Save(outputPath + inputFilename + "E_x8.pdf", uint(SDFDocE_linearized))
    doc.Close()
    PDFNetTerminate()
}
