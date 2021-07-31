//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    . "pdftron"
)

import  "pdftron/Samples/LicenseKey/GO"

//-----------------------------------------------------------------------------------
// This sample demonstrates how to create layers in PDF.
// The sample also shows how to extract and render PDF layers in documents 
// that contain optional content groups (OCGs)
//
// With the introduction of PDF version 1.5 came the concept of Layers. 
// Layers, or as they are more formally known Optional Content Groups (OCGs),
// refer to sections of content in a PDF document that can be selectively 
// viewed or hidden by document authors or consumers. This capability is useful 
// in CAD drawings, layered artwork, maps, multi-language documents etc.
// 
// Notes: 
// ---------------------------------------
// - This sample is using CreateLayer() utility method to create new OCGs. 
//   CreateLayer() is relatively basic, however it can be extended to set 
//   other optional entries in the 'OCG' and 'OCProperties' dictionary. For 
//   a complete listing of possible entries in OC dictionary please refer to 
//   section 4.10 'Optional Content' in the PDF Reference Manual.
// - The sample is grouping all layer content into separate Form XObjects. 
//   Although using PDFNet is is also possible to specify Optional Content in 
//   Content Streams (Section 4.10.2 in PDF Reference), Optional Content in  
//   XObjects results in PDFs that are cleaner, less-error prone, and faster 
//   to process.
//-----------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

// A utility function used to add new Content Groups (Layers) to the document.
func CreateLayer(doc PDFDoc, layerName string) Group{
    grp := GroupCreate(doc, layerName)
    cfg := doc.GetOCGConfig()
    if ! cfg.IsValid(){
        cfg = ConfigCreate(doc, true)
        cfg.SetName("Default")
    }   
    // Add the new OCG to the list of layers that should appear in PDF viewer GUI.
    layerOrderArray := cfg.GetOrder()
    if layerOrderArray.GetMp_obj().Swigcptr() == 0{
        layerOrderArray = doc.CreateIndirectArray()
        cfg.SetOrder(layerOrderArray)
    }
    layerOrderArray.PushBack(grp.GetSDFObj())
    return grp
}
// Creates some content (3 images) and associate them with the image layer
func CreateGroup1(doc PDFDoc, layer Obj) Obj{
    writer := NewElementWriter()
    writer.Begin(doc.GetSDFDoc())
    
    // Create an Image that can be reused in the document or on the same page.
    img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    builder := NewElementBuilder()
    element := builder.CreateImage(img, NewMatrix2D(float64(img.GetImageWidth()/2), -145.0, 20.0, float64(img.GetImageHeight()/2), 200.0, 150.0))
    writer.WritePlacedElement(element)
    
    gstate := element.GetGState()    // use the same image (just change its matrix)
    gstate.SetTransform(200.0, 0.0, 0.0, 300.0, 50.0, 450.0)
    writer.WritePlacedElement(element)
    
    // use the same image again (just change its matrix).
    writer.WritePlacedElement(builder.CreateImage(img, 300.0, 600.0, 200.0, -150.0))
    
    grpObj := writer.End()
    
    // Indicate that this form (content group) belongs to the given layer (OCG).
    grpObj.PutName("Subtype","Form")
    grpObj.Put("OC", layer)
    grpObj.PutRect("BBox", 0.0, 0.0, 1000.0, 1000.0)   // Set the clip box for the content.
    
    return grpObj
}
// Creates some content (a path in the shape of a heart) and associate it with the vector layer
func CreateGroup2(doc PDFDoc, layer Obj) Obj{
    writer := NewElementWriter()
    writer.Begin(doc.GetSDFDoc())
    
    // Create a path object in the shape of a heart
    builder := NewElementBuilder()
    builder.PathBegin()     // start constructing the path
    builder.MoveTo(306.0, 396.0)
    builder.CurveTo(681.0, 771.0, 399.75, 864.75, 306.0, 771.0)
    builder.CurveTo(212.25, 864.75, -69, 771, 306.0, 396.0)
    builder.ClosePath()
    element := builder.PathEnd() // the path geometry is now specified.

    // Set the path FILL color space and color.
    element.SetPathFill(true)
    gstate := element.GetGState()
    gstate.SetFillColorSpace(ColorSpaceCreateDeviceCMYK())
    gstate.SetFillColor(NewColorPt(1.0, 0.0, 0.0, 0.0))    // cyan
    
    // Set the path STROKE color space and color
    element.SetPathStroke(true)
    gstate.SetStrokeColorSpace(ColorSpaceCreateDeviceRGB())
    gstate.SetStrokeColor(NewColorPt(1.0, 0.0, 0.0))     // red
    gstate.SetLineWidth(20)
    
    gstate.SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 300.0)
    
    writer.WriteElement(element)
    
    grpObj := writer.End()
    
    // Indicate that this form (content group) belongs to the given layer (OCG).
    grpObj.PutName("Subtype","Form")
    grpObj.Put("OC", layer)
    grpObj.PutRect("BBox", 0.0, 0.0, 1000.0, 1000.0)       // Set the clip box for the content.
    
    return grpObj
}
// Creates some text and associate it with the text layer
func CreateGroup3(doc PDFDoc, layer Obj) Obj{
    writer := NewElementWriter()
    writer.Begin(doc.GetSDFDoc())
    
    // Create a path object in the shape of a heart.
    builder := NewElementBuilder()
    
    // Begin writing a block of text
    element := builder.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_roman), 120.0)
    writer.WriteElement(element)
    
    element = builder.CreateTextRun("A text layer!")
    
    // Rotate text 45 degrees, than translate 180 pts horizontally and 100 pts vertically.
    transform := Matrix2DRotationMatrix(-45 * (3.1415/ 180.0))
    transform.Concat(1.0, 0.0, 0.0, 1.0, 180.0, 100.0)
    element.SetTextMatrix(transform)
    
    writer.WriteElement(element)
    writer.WriteElement(builder.CreateTextEnd())
    
    grpObj := writer.End()
    
    // Indicate that this form (content group) belongs to the given layer (OCG).
    grpObj.PutName("Subtype","Form")
    grpObj.Put("OC", layer)
    grpObj.PutRect("BBox", 0.0, 0.0, 1000.0, 1000.0)   // Set the clip box for the content.
    
    return grpObj
}

func main(){
    PDFNetInitialize(PDFTronLicense.Key)
    
    // Create three layers...
    doc := NewPDFDoc()
    imageLayer := CreateLayer(doc, "Image Layer")
    textLayer := CreateLayer(doc, "Text Layer")
    vectorLayer := CreateLayer(doc, "Vector Layer")
    
    // Start a new page ------------------------------------
    page := doc.PageCreate()
    
    builder := NewElementBuilder()    // NewElementBuilder is used to build new Element objects
    writer := NewElementWriter()      // NewElementWriter is used to write Elements to the page
    writer.Begin(page)            // Begin writting to the page
    
    // Add new content to the page and associate it with one of the layers.
    element := builder.CreateForm(CreateGroup1(doc, imageLayer.GetSDFObj()))
    writer.WriteElement(element)
    
    element = builder.CreateForm(CreateGroup2(doc, vectorLayer.GetSDFObj()))
    writer.WriteElement(element)
    
    // Add the text layer to the page...
    if false{ // set to true to enable 'ocmd' example.
        // A bit more advanced example of how to create an OCMD text layer that 
        // is visible only if text, image and path layers are all 'ON'.
        // An example of how to set 'Visibility Policy' in OCMD.
        ocgs := doc.CreateIndirectArray()
        ocgs.PushBack(imageLayer.GetSDFObj())
        ocgs.PushBack(vectorLayer.GetSDFObj())
        ocgs.PushBack(textLayer.GetSDFObj())
        text_ocmd := OCMDCreate(doc, ocgs, OCMDE_AllOn)
        element = builder.CreateForm(CreateGroup3(doc, text_ocmd.GetSDFObj()))
    }else{
        element = builder.CreateForm(CreateGroup3(doc, textLayer.GetSDFObj()))
    }
    writer.WriteElement(element)
    
    // Add some content to the page that does not belong to any layer...
    // In this case this is a rectangle representing the page border.
    element = builder.CreateRect(0, 0, page.GetPageWidth(), page.GetPageHeight())
    element.SetPathFill(false)
    element.SetPathStroke(true)
    element.GetGState().SetLineWidth(40)
    writer.WriteElement(element)
    
    writer.End()    // save changes to the current page
    doc.PagePushBack(page)
    // Set the default viewing preference to display 'Layer' tab
    prefs := doc.GetViewPrefs()
    prefs.SetPageMode(PDFDocViewPrefsE_UseOC)
    
    doc.Save(outputPath + "pdf_layers.pdf", uint(SDFDocE_linearized))
    doc.Close()
    fmt.Println("Done.")
    
    // The following is a code snippet shows how to selectively render 
    // and export PDF layers.
    
    doc = NewPDFDoc(outputPath + "pdf_layers.pdf")
    doc.InitSecurityHandler()
    
    if ! doc.HasOC(){
        fmt.Println("The document does not contain 'Optional Content'")
    }else{
        init_cfg := doc.GetOCGConfig()
        ctx := NewContext(init_cfg)
        
        pdfdraw := NewPDFDraw()
        pdfdraw.SetImageSize(1000, 1000)
        pdfdraw.SetOCGContext(ctx)  // Render the page using the given OCG context.
        
        page = doc.GetPage(1)   // Get the first page in the document.
        pdfdraw.Export(page, outputPath + "pdf_layers_default.png")
        
        // Disable drawing of content that is not optional (i.e. is not part of any layer).
        ctx.SetNonOCDrawing(false)
        
        // Now render each layer in the input document to a separate image.
        ocgs := doc.GetOCGs()    // Get the array of all OCGs in the document.
        if ocgs != nil{
            sz := ocgs.Size()
            i := int64(0)
            for i < sz{
                ocg := NewGroup(ocgs.GetAt(i))
                ctx.ResetStates(false)
                ctx.SetState(ocg, true)
                fname := "pdf_layers_" + ocg.GetName() + ".png"
                fmt.Println(fname)
                pdfdraw.Export(page, outputPath + fname)
                i = i + 1
            }
        }
        // Now draw content that is not part of any layer...
        ctx.SetNonOCDrawing(true)
        ctx.SetOCDrawMode(ContextE_NoOC)
        pdfdraw.Export(page, outputPath + "pdf_layers_non_oc.png")
        
        doc.Close()
        PDFNetTerminate()
        fmt.Println("Done.") 
    }
}
