//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package U3DTest
import (
    "fmt"
    "testing"
    . "github.com/pdftron/pdftron-go"
    "flag"
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

func Create3DAnnotation(doc PDFDoc, annots Obj){
    // ---------------------------------------------------------------------------------
    // Create a 3D annotation based on U3D content. PDF 1.6 introduces the capability 
    // for collections of three-dimensional objects, such as those used by CAD software, 
    // to be embedded in PDF files.
    link3D := doc.CreateIndirectDict()
    link3D.PutName("Subtype", "3D")
    
    // Annotation location on the page
    link3DRect := NewRect(25.0, 180.0, 585.0, 643.0)
    link3D.PutRect("Rect", link3DRect.GetX1(), link3DRect.GetY1(),
                    link3DRect.GetX2(), link3DRect.GetY2())
    annots.PushBack(link3D)
    
    // The 3DA entry is an activation dictionary (see Table 9.34 in the PDF Reference Manual) 
    // that determines how the state of the annotation and its associated artwork can change.
    activationDict3D := link3D.PutDict("3DA")
    
    // Set the annotation so that it is activated as soon as the page containing the 
    // annotation is opened. Other options are: PV (page view) and XA (explicit) activation.
    activationDict3D.PutName("A", "PO")  
    
    // Embed U3D Streams (3D Model/Artwork).
    u3dFile := NewMappedFile(inputPath + "dice.u3d")
    u3dReader := NewFilterReader(u3dFile)
    u3dDataDict := doc.CreateIndirectStream(u3dReader, NewFilter())
    u3dDataDict.PutName("Subtype", "U3D")
    link3D.Put("3DD", u3dDataDict)
    
    // Set the initial view of the 3D artwork that should be used when the annotation is activated.
    view3DDict := link3D.PutDict("3DV")
    
    view3DDict.PutString("IN", "Unnamed")
    view3DDict.PutString("XN", "Default")
    view3DDict.PutName("MS", "M")
    view3DDict.PutNumber("CO", 27.5)
    
    // A 12-element 3D transformation matrix that specifies a position and orientation 
    // of the camera in world coordinates.
    tr3d := view3DDict.PutArray("C2W")
    tr3d.PushBackNumber(1.0)
    tr3d.PushBackNumber(0.0)
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(-1.0)
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(1.0) 
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(0.0) 
    tr3d.PushBackNumber(-27.5) 
    tr3d.PushBackNumber(0.0)
    
    // Create annotation appearance stream, a thumbnail which is used during printing or
    // in PDF processors that do not understand 3D data.
    apDict := link3D.PutDict("AP")
    
    builder := NewElementBuilder()
    writer := NewElementWriter()
    writer.Begin(doc.GetSDFDoc())
    
    thumbPathname := inputPath + "dice.jpg"
    image := ImageCreate(doc.GetSDFDoc(), thumbPathname)
    writer.WritePlacedElement(builder.CreateImage(image, 0.0, 0.0, float64(link3DRect.Width()), float64(link3DRect.Height())))
    
    normalApStream := writer.End()
    normalApStream.PutName("Subtype", "Form")
    normalApStream.PutRect("BBox", 0.0, 0.0, float64(link3DRect.Width()), float64(link3DRect.Height()))
    apDict.Put("N", normalApStream)
}

func TestU3D(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    doc := NewPDFDoc()
    page := doc.PageCreate()
    doc.PagePushBack(page)
    annots := doc.CreateIndirectArray()
    page.GetSDFObj().Put("Annots", annots)
    
    Create3DAnnotation(doc, annots)
    doc.Save(outputPath + "dice_u3d.pdf", uint(SDFDocE_linearized))
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
