//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
    "path/filepath"
    "strconv"
	. "pdftron"
)

//-----------------------------------------------------------------------------------
// This sample illustrates how to create, extract, and manipulate PDF Portfolios
// (a.k.a. PDF Packages) using PDFNet SDK.
//-----------------------------------------------------------------------------------

func AddPackage(doc PDFDoc, file string, desc string){
    files := NameTreeCreate(doc.GetSDFDoc(), "EmbeddedFiles")
    fs := FileSpecCreate(doc.GetSDFDoc(), file, true)
    key := make([]byte, len(file))
    for i := 0; i < len(file); i++{
        key[i] = file[i]
        //fmt.Println(file[i])
    }
    files.Put(&key[0], len(key), fs.GetSDFObj())
    fs.SetDesc(desc)
    
    collection := doc.GetRoot().FindObj("Collection")
    if collection.GetMp_obj().Swigcptr() == 0{
        collection = doc.GetRoot().PutDict("Collection")
    }

    // You could here manipulate any entry in the Collection dictionary. 
    // For example, the following line sets the tile mode for initial view mode
    // Please refer to section '2.3.5 Collections' in PDF Reference for details.
    collection.PutName("View", "T");
}

func AddCoverPage(doc PDFDoc){
    // Here we dynamically generate cover page (please see ElementBuilder 
    // sample for more extensive coverage of PDF creation API).
    page := doc.PageCreate(NewRect(0.0, 0.0, 200.0, 200.0))
    
    b := NewElementBuilder()
    w := NewElementWriter()
    
    w.Begin(page)
    font := FontCreate(doc.GetSDFDoc(), FontE_helvetica)
    w.WriteElement(b.CreateTextBegin(font, 12.0))
    e := b.CreateTextRun("My PDF Collection")
    e.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 50.0, 96.0)
    e.GetGState().SetFillColorSpace(ColorSpaceCreateDeviceRGB())
    e.GetGState().SetFillColor(NewColorPt(1.0, 0.0, 0.0))
    w.WriteElement(e)
    w.WriteElement(b.CreateTextEnd())
    w.End()
    doc.PagePushBack(page)
    
    // Alternatively we could import a PDF page from a template PDF document
    // (for an example please see PDFPage sample project).
    // ...
}    

func main(){
    PDFNetInitialize()
    
    // Relative path to the folder containing the test files.
    inputPath := "../../TestFiles/"
    outputPath := "../../TestFiles/Output/"
    
    // Create a PDF Package.
    doc := NewPDFDoc()
    AddPackage(doc, inputPath + "numbered.pdf", "My File 1")
    AddPackage(doc, inputPath + "newsletter.pdf", "My Newsletter...")
    AddPackage(doc, inputPath + "peppers.jpg", "An image")
    AddCoverPage(doc)
    doc.Save(outputPath + "package.pdf", uint(SDFDocE_linearized))
    doc.Close()
    fmt.Println("Done.")
    
    // Extract parts from a PDF Package
    doc = NewPDFDoc(outputPath + "package.pdf")
    doc.InitSecurityHandler()
    
    files := NameTreeFind(doc.GetSDFDoc(), "EmbeddedFiles")
    if files.IsValid(){
        // Traverse the list of embedded files.
        i := files.GetIterator()
        counter := 0
        for i.HasNext(){
            entryName := i.Key().GetAsPDFText()
            fmt.Println("Part: " + entryName)
            fileSpec := NewFileSpec(i.Value())
            stm := NewFilter(fileSpec.GetFileData())
            if stm.GetM_impl().Swigcptr() != 0{
                stm.WriteToFile(outputPath + "extract_" + strconv.Itoa(counter) + filepath.Ext(entryName), false)
            }

            i.Next()
            counter = counter + 1
        }
    }
    doc.Close()
    fmt.Println("Done.")
}
