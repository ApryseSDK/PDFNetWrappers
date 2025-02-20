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

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func CreateTilingPattern(doc PDFDoc) Obj{
    writer := NewElementWriter()
    eb := NewElementBuilder()
    
    // Create a new pattern content stream - a heart. ------------
    writer.Begin(doc.GetSDFDoc())
    eb.PathBegin()
    eb.MoveTo(0.0, 0.0)
    eb.CurveTo(500.0, 500.0, 125.0, 625.0, 0.0, 500.0)
    eb.CurveTo(-125.0, 625.0, -500.0, 500.0, 0.0, 0.0)
    heart := eb.PathEnd()
    heart.SetPathFill(true)
    
    // Set heart color to red.
    heart.GetGState().SetFillColorSpace(ColorSpaceCreateDeviceRGB()) 
    heart.GetGState().SetFillColor(NewColorPt(1.0, 0.0, 0.0)) 
    writer.WriteElement(heart)
    
    patternDict := writer.End()
    
    // Initialize pattern dictionary. For details on what each parameter represents please 
    // refer to Table 4.22 (Section '4.6.2 Tiling Patterns') in PDF Reference Manual.
    patternDict.PutName("Type", "Pattern")
    patternDict.PutNumber("PatternType", 1)
    
    // TilingType - Constant spacing.
    patternDict.PutNumber("TilingType",1) 

    // This is a Type1 pattern - A colored tiling pattern.
    patternDict.PutNumber("PaintType", 1)

    // Set bounding box
    patternDict.PutRect("BBox", -253.0, 0.0, 253.0, 545.0)

    // Create and set the matrix
    patternMtx := NewMatrix2D(0.04,0.0,0.0,0.04,0.0,0.0)
    patternDict.PutMatrix("Matrix", patternMtx)
    
    // Set the desired horizontal and vertical spacing between pattern cells, 
    // measured in the pattern coordinate system.
    patternDict.PutNumber("XStep", 1000)
    patternDict.PutNumber("YStep", 1000)
    
    return patternDict // finished creating the Pattern resource
}
    
    
    
func CreateImageTilingPattern(doc PDFDoc) Obj{
    writer := NewElementWriter()
    eb := NewElementBuilder()
    
    // Create a new pattern content stream - a single bitmap object ----------
    writer.Begin(doc.GetSDFDoc())
    image := ImageCreate(doc.GetSDFDoc(), inputPath + "dice.jpg")
    imgElement := eb.CreateImage(image, 0.0, 0.0, float64(image.GetImageWidth()), float64(image.GetImageHeight()))
    writer.WritePlacedElement(imgElement)
    patternDict := writer.End()
    
    // Initialize pattern dictionary. For details on what each parameter represents please 
    // refer to Table 4.22 (Section '4.6.2 Tiling Patterns') in PDF Reference Manual.
    patternDict.PutName("Type", "Pattern")
    patternDict.PutNumber("PatternType",1)
    
    // TilingType - Constant spacing.
    patternDict.PutNumber("TilingType", 1)
    
    // This is a Type1 pattern - A colored tiling pattern.
    patternDict.PutNumber("PaintType", 1)
    
    // Set bounding box
    patternDict.PutRect("BBox", -253.0, 0.0, 253.0, 545.0)
    
    // Create and set the matrix
    patternMtx := NewMatrix2D(0.3,0.0,0.0,0.3,0.0,0.0)
    patternDict.PutMatrix("Matrix", patternMtx)
    
    // Set the desired horizontal and vertical spacing between pattern cells, 
    // measured in the pattern coordinate system.
    patternDict.PutNumber("XStep", 300)
    patternDict.PutNumber("YStep", 300)
    
    return patternDict     // finished creating the Pattern resource
}    
    
func CreateAxialShading(doc PDFDoc) Obj{
    // Create a new Shading object ------------
    patternDict := doc.CreateIndirectDict()
    
    // Initialize pattern dictionary. For details on what each parameter represents 
    // please refer to Tables 4.30 and 4.26 in PDF Reference Manual
    patternDict.PutName("Type", "Pattern")
    patternDict.PutNumber("PatternType", 2)    // 2 stands for shading
    
    shadingDict := patternDict.PutDict("Shading")
    shadingDict.PutNumber("ShadingType",2)
    shadingDict.PutName("ColorSpace","DeviceCMYK")
    
    // pass the coordinates of the axial shading to the output
    shadingCoords := shadingDict.PutArray("Coords")
    shadingCoords.PushBackNumber(0)
    shadingCoords.PushBackNumber(0)
    shadingCoords.PushBackNumber(612)
    shadingCoords.PushBackNumber(794)
    
    // pass the function to the axial shading
    function := shadingDict.PutDict("Function")
    C0 := function.PutArray("C0")
    C0.PushBackNumber(1)
    C0.PushBackNumber(0)
    C0.PushBackNumber(0)
    C0.PushBackNumber(0)
    
    C1 := function.PutArray("C1")
    C1.PushBackNumber(0)
    C1.PushBackNumber(1)
    C1.PushBackNumber(0)
    C1.PushBackNumber(0)
    
    domain := function.PutArray("Domain")
    domain.PushBackNumber(0)
    domain.PushBackNumber(1)
    
    function.PutNumber("FunctionType", 2)
    function.PutNumber("N", 1)
    
    return patternDict
}    

func TestPattern(t *testing.T){
    PDFNetInitialize(licenseKey)
      
    doc := NewPDFDoc()
    writer := NewElementWriter()
    eb := NewElementBuilder()
    
    // The following sample illustrates how to create and use tiling patterns
    page := doc.PageCreate()
    writer.Begin(page)
    
    element := eb.CreateTextBegin(FontCreate(doc.GetSDFDoc(), FontE_times_bold), 1.0)
    writer.WriteElement(element) // Begin the text block
    
    data := "G"
    element = eb.CreateTextRun(data)
    element.SetTextMatrix(720.0, 0.0, 0.0, 720.0, 20.0, 240.0)
    gs := element.GetGState()
    gs.SetTextRenderMode(GStateE_fill_stroke_text)
    gs.SetLineWidth(4)
    
    // Set the fill color space to the Pattern color space. 
    gs.SetFillColorSpace(ColorSpaceCreatePattern())
    gs.SetFillColor(NewPatternColor(CreateTilingPattern(doc)))
    
    element.SetPathFill(true)
   
    writer.WriteElement(element)
    writer.WriteElement(eb.CreateTextEnd()) // Finish the text block
    
    writer.End() // Save the page
    doc.PagePushBack(page)
    
    //-----------------------------------------------
    // The following sample illustrates how to create and use image tiling pattern
    
    page = doc.PageCreate()
    writer.Begin(page)
    
    eb.Reset()
    element = eb.CreateRect(0.0, 0.0, 612.0, 794.0)
    
    // Set the fill color space to the Pattern color space. 
    gs = element.GetGState()
    gs.SetFillColorSpace(ColorSpaceCreatePattern())
    gs.SetFillColor(NewPatternColor(CreateImageTilingPattern(doc)))
    element.SetPathFill(true)
    
    writer.WriteElement(element)
    
    writer.End()    // Save the page
    doc.PagePushBack(page)
    
    //-----------------------------------------------
    
    // The following sample illustrates how to create and use PDF shadings
    page = doc.PageCreate()
    writer.Begin(page)
    
    eb.Reset()
    element = eb.CreateRect(0.0, 0.0, 612.0, 794.0)
    
    // Set the fill color space to the Pattern color space. 
    gs = element.GetGState()
    gs.SetFillColorSpace(ColorSpaceCreatePattern())
    gs.SetFillColor(NewPatternColor(CreateAxialShading(doc)))
    element.SetPathFill(true)
    
    writer.WriteElement(element)
    writer.End()    // save the page
    doc.PagePushBack(page)
    //-----------------------------------------------
    
    doc.Save(outputPath + "patterns.pdf", uint(SDFDocE_remove_unused))
    fmt.Println("Done. Result saved in patterns.pdf...")
    
    doc.Close()
    PDFNetTerminate()
}
