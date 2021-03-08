//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
    "os"
	. "pdftron"
)

//-----------------------------------------------------------------------------------
// The sample illustrates how multiple pages can be combined/imposed 
// using PDFNet. Page imposition can be used to arrange/order pages 
// prior to printing or to assemble a 'master' page from several 'source' 
// pages. Using PDFNet API it is possible to write applications that can 
// re-order the pages such that they will display in the correct order 
// when the hard copy pages are compiled and folded correctly. 
//-----------------------------------------------------------------------------------

func main(){
    PDFNetInitialize()

    //var resource_path = ""
    //if len(os.Args) > 3{
    //    resource_path = os.Args[3]
    //}else{
    //    resource_path = "../../../resources"
    //}
    
    // Relative path to the folder containing the test files.
    inputPath := "../../TestFiles/newsletter.pdf"
    outputPath := "../../TestFiles/Output/newsletter_booklet.pdf"
    
    fmt.Println("-------------------------------------------------")
    fmt.Println("Opening the input pdf...")
    
    var filein = ""
    if len(os.Args) > 1{
        filein = os.Args[1]
    }else{
        filein = inputPath
    }
    var fileout = ""
    if len(os.Args) > 2{
        fileout = os.Args[2]
    }else{
        fileout = outputPath
    }
    
    inDoc := NewPDFDoc(filein)
    inDoc.InitSecurityHandler()
    
    // Create a list of pages to import from one PDF document to another
    importPages := NewVectorPage()
    itr := inDoc.GetPageIterator()
    for itr.HasNext(){
        importPages.Add(itr.Current())
        itr.Next()
    }

    newDoc := NewPDFDoc()
    importedPages := newDoc.ImportPages(importPages)

    // Paper dimension for A3 format in points. Because one inch has 
    // 72 points, 11.69 inch 72 = 841.69 points
    mediaDox := NewRect(0.0, 0.0, 1190.88, 841.69)
    midPoint := mediaDox.Width()/2

    builder := NewElementBuilder()
    writer := NewElementWriter()

    i := 0    
    for i < int(importedPages.Size()){
        // Create a blank new A3 page and place on it two pages from the input document.
        newPage := newDoc.PageCreate(mediaDox)
        writer.Begin(newPage)
        
        // Place the first page
        srcPage := importedPages.Get(i)
        
        element := builder.CreateForm(importedPages.Get(i))
        sc_x := midPoint / srcPage.GetPageWidth()
        sc_y := mediaDox.Height() / srcPage.GetPageHeight()
        var scale = 0.0
        if sc_x < sc_y { // min(sc_x, sc_y)
            scale = sc_x
        }else{
            scale = sc_y
        } 
        element.GetGState().SetTransform(scale, 0.0, 0.0, scale, 0.0, 0.0)
        writer.WritePlacedElement(element)
        
        // Place the second page
        i = i + 1
        if i < int(importedPages.Size()){
            srcPage = importedPages.Get(i)
            element = builder.CreateForm(srcPage)
            sc_x = midPoint / srcPage.GetPageWidth()
            sc_y = mediaDox.Height() / srcPage.GetPageHeight()
            if sc_x < sc_y { // min(sc_x, sc_y)
                scale = sc_x
            }else{
                scale = sc_y
            } 
            element.GetGState().SetTransform(scale, 0.0, 0.0, scale, midPoint, 0.0)
            writer.WritePlacedElement(element)
        }    
        writer.End()
        newDoc.PagePushBack(newPage)
        i = i + 1
    }    
    newDoc.Save(fileout, uint(SDFDocE_linearized))
    fmt.Println("Done. Result saved in newsletter_booklet.pdf...")
}
