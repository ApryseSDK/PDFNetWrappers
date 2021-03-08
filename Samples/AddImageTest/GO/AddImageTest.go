//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	. "pdftron"
)
 
//-----------------------------------------------------------------------------------
// This sample illustrates how to embed various raster image formats
// (e.g. TIFF, JPEG, JPEG2000, JBIG2, GIF, PNG, BMP, etc.) in a PDF document.
//
// Note: On Windows platform this sample utilizes GDI+ and requires GDIPLUS.DLL to
// be present in the system path.
//-----------------------------------------------------------------------------------

func main(){
	PDFNetInitialize()
	// Relative path to the folder containing test files.
	var inputPath = "../../TestFiles/"
	var outputPath = "../../TestFiles/Output/"
	doc := NewPDFDoc()
	f := NewElementBuilder()			// Used to build new Element objects
	writer := NewElementWriter()		// Used to write Elements to the page
	page := doc.PageCreate()					// Start a new page
	writer.Begin(page)							// Begin writing to this page
    // ----------------------------------------------------------
    // Add JPEG image to the output file
	img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    element := f.CreateImage(img, 50.0, 500.0, float64(img.GetImageWidth()/2), float64(img.GetImageHeight()/2))
    writer.WritePlacedElement(element)
    
	// ----------------------------------------------------------
    // Add a PNG image to the output file    
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "butterfly.png")
    element = f.CreateImage(img, NewMatrix2D(100.0, 0.0, 0.0, 100.0, 300.0, 500.0))
    writer.WritePlacedElement(element)
    
    //----------------------------------------------------------
    // Add a GIF image to the output file
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "pdfnet.gif")
    element = f.CreateImage(img, NewMatrix2D(float64(img.GetImageWidth()), 0.0, 0.0, float64(img.GetImageHeight()), 50.0, 350.0))
    writer.WritePlacedElement(element)
    
    // ----------------------------------------------------------
    // Add a TIFF image to the output file
    
    img = ImageCreate(doc.GetSDFDoc(), (inputPath + "grayscale.tif"))
    element = f.CreateImage(img, NewMatrix2D(float64(img.GetImageWidth()), 0.0, 0.0, float64(img.GetImageHeight()), 10.0, 50.0))
    writer.WritePlacedElement(element)
    
    writer.End()                // Save the page
    doc.PagePushBack(page)      // Add the page to the document page sequence

    // ----------------------------------------------------------
    // Embed a monochrome TIFF. Compress the image using lossy JBIG2 filter.
    page = doc.PageCreate(NewRect(0.0, 0.0, 612.0, 794.0))
    writer.Begin(page)          // begin writing to this page

    // Note: encoder hints can be used to select between different compression methods. 
    // For example to instruct PDFNet to compress a monochrome image using JBIG2 compression.
    hintSet := NewObjSet();
    enc := hintSet.CreateArray();  // Initilaize encoder 'hint' parameter 
    enc.PushBackName("JBIG2");
    enc.PushBackName("Lossy");

    img = ImageCreate(doc.GetSDFDoc(), inputPath + "multipage.tif");
    element = f.CreateImage(img, NewMatrix2D(612.0, 0.0, 0.0, 794.0, 0.0, 0.0));
    writer.WritePlacedElement(element);

    writer.End()                   // Save the page
    doc.PagePushBack(page)         // Add the page to the document page sequence
    
    // ----------------------------------------------------------
    // Add a JPEG2000 (JP2) image to the output file
    
    // Create a new page
    page = doc.PageCreate()
    writer.Begin(page)             // Begin writing to the page
    
    // Embed the image
    img = ImageCreate(doc.GetSDFDoc(), inputPath + "palm.jp2")
    
    // Position the image on the page
    element = f.CreateImage(img, NewMatrix2D(float64(img.GetImageWidth()), 0.0, 0.0, float64(img.GetImageHeight()), 96.0, 80.0))
    writer.WritePlacedElement(element)
    
    // Write 'JPEG2000 Sample' text string under the image
    writer.WriteElement(f.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_roman), 32.0))
    element = f.CreateTextRun("JPEG2000 Sample")
    element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 190.0, 30.0)
    writer.WriteElement(element)
    writer.WriteElement(f.CreateTextEnd())
    
	writer.End()
	doc.PagePushBack(page)

	doc.Save((outputPath + "addimage.pdf"), uint(SDFDocE_linearized));
    doc.Close()
    fmt.Println("Done. Result saved in addimage.pdf...")
}
