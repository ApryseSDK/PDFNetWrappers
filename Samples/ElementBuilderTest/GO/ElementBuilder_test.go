//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "strings"
    "flag"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func Find(s, substr string, offset int) int {
    if len(s) < offset {
        return -1
    }
    if idx := strings.Index(s[offset:], substr); idx >= 0 {
        return offset + idx
    }
    return -1
}

//-----------------------------------------------------------------------------------------------------------------------
func TestElementBuilder(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    doc := NewPDFDoc()
    
    // ElementBuilder is used to build new Element objects
    eb := NewElementBuilder()
    // ElementWriter is used to write Elements to the page
    writer := NewElementWriter()
    
    // Start a new page ------------------------------------
    page := doc.PageCreate(NewRect(0.0, 0.0, 612.0, 794.0))
    
    writer.Begin(page)  // begin writing to the page

    // Create an Image that can be reused in the document or on the same page.
    img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")
    
    element := eb.CreateImage(img, NewMatrix2D(float64(img.GetImageWidth()/2), -145.0, 20.0, float64(img.GetImageHeight()/2), 200.0, 150.0))
    writer.WritePlacedElement(element)
    
    gstate := element.GetGState()    // use the same image (just change its matrix)
    gstate.SetTransform(200.0, 0.0, 0.0, 300.0, 50.0, 450.0)
    writer.WritePlacedElement(element)
    
    // use the same image again (just change its matrix)
    writer.WritePlacedElement(eb.CreateImage(img, 300.0, 600.0, 200.0, -150.0))
    
    writer.End()    // save changes to the current page
    doc.PagePushBack(page)
    
    // Start a new page ------------------------------------
    // Construct and draw a path object using different styles
    page = doc.PageCreate(NewRect(0.0, 0.0, 612.0, 794.0))
    
    writer.Begin(page)  // begin writing to this page
    eb.Reset()          // Reset the GState to default
    
    eb.PathBegin()      // start constructing the path
    eb.MoveTo(306.0, 396.0)
    eb.CurveTo(681.0, 771.0, 399.75, 864.75, 306.0, 771.0)
    eb.CurveTo(212.25, 864.75, -69, 771.0, 306.0, 396.0)
    eb.ClosePath()
    element = eb.PathEnd()      // the path is now finished
    element.SetPathFill(true)   // the path should be filled
    
    // Set the path color space and color
    gstate = element.GetGState()
    gstate.SetFillColorSpace(ColorSpaceCreateDeviceCMYK())
    gstate.SetFillColor(NewColorPt(1.0, 0.0, 0.0, 0.0))  // cyan
    gstate.SetTransform(0.5, 0.0, 0.0, 0.5, -20.0, 300.0)
    writer.WritePlacedElement(element)
    
    // Draw the same path using a different stroke color
    element.SetPathStroke(true)     // this path is should be filled and stroked
    gstate.SetFillColor(NewColorPt(0.0, 0.0, 1.0, 0.0))  // yellow
    gstate.SetStrokeColorSpace(ColorSpaceCreateDeviceRGB())
    gstate.SetStrokeColor(NewColorPt(1.0, 0.0, 0.0))  // red
    gstate.SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 300.0)
    gstate.SetLineWidth(20)
    writer.WritePlacedElement(element)
    
    // Draw the same path with a given dash pattern
    element.SetPathFill(false)      // this path should be only stroked
    
    gstate.SetStrokeColor(NewColorPt(0.0,0.0,1.0))   // blue
    gstate.SetTransform(0.5, 0.0, 0.0, 0.5, 280.0, 0.0)
    dashPattern := NewVectorDouble()
    dashPattern.Add(30.0)
    gstate.SetDashPattern(dashPattern, 0)
    writer.WritePlacedElement(element)
    
    // Use the path as a clipping path
    writer.WriteElement(eb.CreateGroupBegin())    // Save the graphics state
    // Start constructing the new path (the old path was lost when we created 
    // a new Element using CreateGroupBegin()).
    eb.PathBegin()
    eb.MoveTo(306.0, 396.0)
    eb.CurveTo(681.0, 771.0, 399.75, 864.75, 306.0, 771.0)
    eb.CurveTo(212.25, 864.75, -69.0, 771.0, 306.0, 396.0)
    eb.ClosePath()
    element = eb.PathEnd()    // path is now constructed
    element.SetPathClip(true)    // this path is a clipping path
    element.SetPathStroke(true)        // this path should be filled and stroked
    gstate = element.GetGState()
    gstate.SetTransform(0.5, 0.0, 0.0, 0.5, -20.0, 0.0)
    
    writer.WriteElement(element)

    writer.WriteElement(eb.CreateImage(img, 100.0, 300.0, 400.0, 600.0))
        
    writer.WriteElement(eb.CreateGroupEnd())    // Restore the graphics state

    writer.End()  // save changes to the current page
    doc.PagePushBack(page)

    // Start a new page ------------------------------------
    page = doc.PageCreate(NewRect(0.0, 0.0, 612.0, 794.0))

    writer.Begin(page)    // begin writing to this page
    eb.Reset()          // Reset the GState to default

    // Begin writing a block of text
    element = eb.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_roman), 12.0)
    writer.WriteElement(element)

    element = eb.CreateTextRun("Hello World!")
    element.SetTextMatrix(10.0, 0.0, 0.0, 10.0, 0.0, 600.0)
    element.GetGState().SetLeading(15)         // Set the spacing between lines
    writer.WriteElement(element)

    writer.WriteElement(eb.CreateTextNewLine())  // New line

    element = eb.CreateTextRun("Hello World!")
    gstate = element.GetGState() 
    gstate.SetTextRenderMode(GStateE_stroke_text)
    gstate.SetCharSpacing(-1.25)
    gstate.SetWordSpacing(-1.25)
    writer.WriteElement(element)

    writer.WriteElement(eb.CreateTextNewLine())  // New line

    element = eb.CreateTextRun("Hello World!")
    gstate = element.GetGState() 
    gstate.SetCharSpacing(0)
    gstate.SetWordSpacing(0)
    gstate.SetLineWidth(3)
    gstate.SetTextRenderMode(GStateE_fill_stroke_text)
    gstate.SetStrokeColorSpace(ColorSpaceCreateDeviceRGB()) 
    gstate.SetStrokeColor(NewColorPt(1.0, 0.0, 0.0))    // red
    gstate.SetFillColorSpace(ColorSpaceCreateDeviceCMYK()) 
    gstate.SetFillColor(NewColorPt(1.0, 0.0, 0.0, 0.0))    // cyan
    writer.WriteElement(element)
    
    writer.WriteElement(eb.CreateTextNewLine())  // New line

    // Set text as a clipping path to the image.
    element = eb.CreateTextRun("Hello World!")
    gstate = element.GetGState() 
    gstate.SetTextRenderMode(GStateE_clip_text)
    writer.WriteElement(element)

    // Finish the block of text
    writer.WriteElement(eb.CreateTextEnd())        

    // Draw an image that will be clipped by the above text
    writer.WriteElement(eb.CreateImage(img, 10.0, 100.0, 1300.0, 720.0))

    writer.End()  // save changes to the current page
    doc.PagePushBack(page)
   
    // Start a new page ------------------------------------
    //
    // The example illustrates how to embed the external font in a PDF document. 
    // The example also shows how ElementReader can be used to copy and modify 
    // Elements between pages.

    reader := NewElementReader()

    // Start reading Elements from the last page. We will copy all Elements to 
    // a new page but will modify the font associated with text.
    reader.Begin(doc.GetPage(uint(doc.GetPageCount())))

    page = doc.PageCreate(NewRect(0.0, 0.0, 1300.0, 794.0))

    writer.Begin(page)    // begin writing to this page
    eb.Reset()          // Reset the GState to default

    // Embed an external font in the document.
    font := FontCreateTrueTypeFont(doc.GetSDFDoc(), (inputPath + "font.ttf"))
    element = reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{
        if element.GetType() == ElementE_text{
            element.GetGState().SetFont(font, 12.0)
        }
        writer.WriteElement(element)
        element = reader.Next()
    }
    

    reader.End()
    writer.End()    // save changes to the current page
    doc.PagePushBack(page)
    
    // Start a new page ------------------------------------
    //
    // The example illustrates how to embed the external font in a PDF document. 
    // The example also shows how ElementReader can be used to copy and modify 
    // Elements between pages.

    // Start reading Elements from the last page. We will copy all Elements to 
    // a new page but will modify the font associated with text.
    reader.Begin(doc.GetPage(uint(doc.GetPageCount())))

    page = doc.PageCreate(NewRect(0.0, 0.0, 1300.0, 794.0))

    writer.Begin(page)    // begin writing to this page
    eb.Reset()          // Reset the GState to default

    // Embed an external font in the document.
    font2 := FontCreateType1Font(doc.GetSDFDoc(), (inputPath + "Misc-Fixed.pfa"))
    
    element = reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{
        if element.GetType() == ElementE_text{
            element.GetGState().SetFont(font2, 12.0)
        }
        writer.WriteElement(element)
        element = reader.Next()
    }

    reader.End()
    writer.End()    // save changes to the current page
    doc.PagePushBack(page)
    // Start a new page ------------------------------------
    page = doc.PageCreate()
    writer.Begin(page)    // begin writing to this page
    eb.Reset()          // Reset the GState to default

    // Begin writing a block of text
    element = eb.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_roman), 12.0)
    element.SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, 600.0)
    element.GetGState().SetLeading(15)    // Set the spacing between lines
    writer.WriteElement(element)
    
    para := "A PDF text object consists of operators that can show " +
        "text strings, move the text position, and set text state and certain " +
        "other parameters. In addition, there are three parameters that are " +
        "defined only within a text object and do not persist from one text " +
        "object to the next: Tm, the text matrix, Tlm, the text line matrix, " +
        "Trm, the text rendering matrix, actually just an intermediate result " +
        "that combines the effects of text state parameters, the text matrix " +
        "(Tm), and the current transformation matrix\n"

    paraEnd := len(para)
    textRun := 0
    
    paraWidth := 300 // paragraph width is 300 units 
    curWidth := 0

    for textRun < paraEnd{
        textRunEnd := Find(para, " ", textRun)  
        if textRunEnd < 0{
            textRunEnd = paraEnd - 1
        }
        text := para[textRun:textRunEnd+1]
        element = eb.CreateTextRun(text)
        if curWidth + int(element.GetTextLength() )< paraWidth{
            writer.WriteElement(element)
            curWidth = curWidth + int(element.GetTextLength())
        }else{
            writer.WriteElement(eb.CreateTextNewLine())    // new line
            element = eb.CreateTextRun(text)
            curWidth = int(element.GetTextLength())
            writer.WriteElement(element)
        }
        textRun = textRunEnd + 1
    }
    
    // -----------------------------------------------------------------------
    // The following code snippet illustrates how to adjust spacing between 
    // characters (text runs).
    element = eb.CreateTextNewLine()
    writer.WriteElement(element)  // Skip 2 lines
    writer.WriteElement(element) 
        
    writer.WriteElement(eb.CreateTextRun("An example of space adjustments between inter-characters:")) 
    writer.WriteElement(eb.CreateTextNewLine()) 
        
    // Write string "AWAY" without space adjustments between characters.
    element = eb.CreateTextRun("AWAY")
    writer.WriteElement(element)  
        
    writer.WriteElement(eb.CreateTextNewLine()) 
        
    // Write string "AWAY" with space adjustments between characters.
    element = eb.CreateTextRun("A")
    writer.WriteElement(element)
        
    element = eb.CreateTextRun("W")
    element.SetPosAdjustment(140)
    writer.WriteElement(element)
        
    element = eb.CreateTextRun("A")
    element.SetPosAdjustment(140)
    writer.WriteElement(element)
        
    element = eb.CreateTextRun("Y again")
    element.SetPosAdjustment(115)
    writer.WriteElement(element)
    
    // Draw the same strings using direct content output...
    writer.Flush()  // flush pending Element writing operations.

    // You can also write page content directly to the content stream using 
    // ElementWriter.WriteString(...) and ElementWriter.WriteBuffer(...) methods.
    // Note that if you are planning to use these functions you need to be familiar
    // with PDF page content operators (see Appendix A in PDF Reference Manual). 
    // Because it is easy to make mistakes during direct output we recommend that 
    // you use ElementBuilder and Element interface instead.

    writer.WriteString("T* T* ") // Skip 2 lines
    writer.WriteString("(Direct output to PDF page content stream:) Tj  T* ")
    writer.WriteString("(AWAY) Tj T* ")
    writer.WriteString("[(A)140(W)140(A)115(Y again)] TJ ")

    // Finish the block of text
    writer.WriteElement(eb.CreateTextEnd())        

    writer.End()  // save changes to the current page
    doc.PagePushBack(page)

    // Start a new page ------------------------------------

    // Image Masks
    //
    // In the opaque imaging model, images mark all areas they occupy on the page as 
    // if with opaque paint. All portions of the image, whether black, white, gray, 
    // or color, completely obscure any marks that may previously have existed in the 
    // same place on the page.
    // In the graphic arts industry and page layout applications, however, it is common 
    // to crop or 'mask out' the background of an image and then place the masked image 
    // on a different background, allowing the existing background to show through the 
    // masked areas. This sample illustrates how to use image masks. 

    page = doc.PageCreate()
    writer.Begin(page)    // begin writing to the page

    // Create the Image Mask
    imgf := NewMappedFile(inputPath + "imagemask.dat")
    maskRead := NewFilterReader(imgf)

    deviceGray := ColorSpaceCreateDeviceGray()
    mask := ImageCreate(doc.GetSDFDoc(), maskRead, 64, 64, 1, deviceGray, ImageE_ascii_hex)
    
    mask.GetSDFObj().PutBool("ImageMask", true)

    element = eb.CreateRect(0, 0, 612, 794)
    element.SetPathStroke(false)
    element.SetPathFill(true)
    element.GetGState().SetFillColorSpace(deviceGray)
    element.GetGState().SetFillColor(NewColorPt(0.8))
    writer.WritePlacedElement(element)

    element = eb.CreateImage(mask, NewMatrix2D(200.0, 0.0, 0.0, -200.0, 40.0, 680.0))
    element.GetGState().SetFillColor(NewColorPt(0.1))
    writer.WritePlacedElement(element)

    element.GetGState().SetFillColorSpace(ColorSpaceCreateDeviceRGB())
    element.GetGState().SetFillColor(NewColorPt(1.0, 0.0, 0.0))
    element = eb.CreateImage(mask, NewMatrix2D(200.0, 0.0, 0.0, -200.0, 320.0, 680.0))
    writer.WritePlacedElement(element)

    element.GetGState().SetFillColor(NewColorPt(0.0, 1.0, 0.0))
    element = eb.CreateImage(mask, NewMatrix2D(200.0, 0.0, 0.0, -200.0, 40.0, 380.0))
    writer.WritePlacedElement(element)
    
    // This sample illustrates Explicit Masking. 
    img = ImageCreate(doc.GetSDFDoc(), (inputPath + "peppers.jpg"))

    // mask is the explicit mask for the primary (base) image
    img.SetMask(mask)

    element = eb.CreateImage(img, NewMatrix2D(200.0, 0.0, 0.0, -200.0, 320.0, 380.0))
    writer.WritePlacedElement(element)
    
    writer.End()  // save changes to the current page
    doc.PagePushBack(page)
    
    // Transparency sample ----------------------------------
        
    // Start a new page -------------------------------------
    page = doc.PageCreate()
    writer.Begin(page)    // begin writing to this page
    eb.Reset()          // Reset the GState to default

    // Write some transparent text at the bottom of the page.
    element = eb.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_roman), 100.0)

    // Set the text knockout attribute. Text knockout must be set outside of 
    // the text group.
    gstate = element.GetGState()
    gstate.SetTextKnockout(false)
    gstate.SetBlendMode(GStateE_bl_difference)
    writer.WriteElement(element)

    element = eb.CreateTextRun("Transparency")
    element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 30.0, 30.0)
    gstate = element.GetGState()
    gstate.SetFillColorSpace(ColorSpaceCreateDeviceCMYK())
    gstate.SetFillColor(NewColorPt(1.0, 0.0, 0.0, 0.0))

    gstate.SetFillOpacity(0.5)
    writer.WriteElement(element)

    // Write the same text on top the old; shifted by 3 points
    element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 33.0, 33.0)
    gstate.SetFillColor(NewColorPt(0.0, 1.0, 0.0, 0.0))
    gstate.SetFillOpacity(0.5)

    writer.WriteElement(element)
    writer.WriteElement(eb.CreateTextEnd())

    // Draw three overlapping transparent circles.
    eb.PathBegin()        // start constructing the path
    eb.MoveTo(459.223, 505.646)
    eb.CurveTo(459.223, 415.841, 389.85, 343.04, 304.273, 343.04)
    eb.CurveTo(218.697, 343.04, 149.324, 415.841, 149.324, 505.646)
    eb.CurveTo(149.324, 595.45, 218.697, 668.25, 304.273, 668.25)
    eb.CurveTo(389.85, 668.25, 459.223, 595.45, 459.223, 505.646)
    element = eb.PathEnd()
    element.SetPathFill(true)
    
    gstate = element.GetGState()
    gstate.SetFillColorSpace(ColorSpaceCreateDeviceRGB())
    gstate.SetFillColor(NewColorPt(0.0, 0.0, 1.0))                     // Blue Circle

    gstate.SetBlendMode(GStateE_bl_normal)
    gstate.SetFillOpacity(0.5)
    writer.WriteElement(element)

    // Translate relative to the Blue Circle
    gstate.SetTransform(1.0, 0.0, 0.0, 1.0, 113.0, -185.0)                
    gstate.SetFillColor(NewColorPt(0.0, 1.0, 0.0))                     // Green Circle
    gstate.SetFillOpacity(0.5)
    writer.WriteElement(element)

    // Translate relative to the Green Circle
    gstate.SetTransform(1.0, 0.0, 0.0, 1.0, -220.0, 0.0)
    gstate.SetFillColor(NewColorPt(1.0, 0.0, 0.0))                     // Red Circle
    gstate.SetFillOpacity(0.5)
    writer.WriteElement(element)

    writer.End()  // save changes to the current page
    doc.PagePushBack(page)

    // End page ------------------------------------

    doc.Save((outputPath + "element_builder.pdf"), uint(SDFDocE_remove_unused))
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done. Result saved in element_builder.pdf...")
}
