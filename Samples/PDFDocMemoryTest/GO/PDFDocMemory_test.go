//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "os"
    "flag"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func TestPDFDocMemory(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    // The following sample illustrates how to read/write a PDF document from/to 
    // a memory buffer.  This is useful for applications that work with dynamic PDF
    // documents that don't need to be saved/read from a disk.
    
    // Read a PDF document in a memory buffer.
    file := NewMappedFile(inputPath + "tiger.pdf")
    fileSZ := file.FileSize()
    
    fileReader := NewFilterReader(file)
    
    mem := fileReader.Read(fileSZ)
    memBytes := make([]byte, int(mem.Size()))
    for i := 0; i < int(mem.Size()); i++{
        memBytes[i] = mem.Get(i)
    }
    doc := NewPDFDoc(&memBytes[0], fileSZ)
    doc.InitSecurityHandler()
    numPages := doc.GetPageCount()
    
    writer := NewElementWriter()
    reader := NewElementReader()
    element := NewElement()
    
    // Create a duplicate of every page but copy only path objects
    
    i := 1
    for i <= numPages{
        itr := doc.GetPageIterator(uint(2*i - 1))
        
        reader.Begin(itr.Current())
        new_page := doc.PageCreate(itr.Current().GetMediaBox())
        next_page := itr
        next_page.Next()
        doc.PageInsert(next_page, new_page)
        
        writer.Begin(new_page)
        element = reader.Next()
        for element.GetMp_elem().Swigcptr() != 0 { // Read page contents
            //if element.GetType() == Element.e_path:
            writer.WriteElement(element)
            element = reader.Next()
        }
        writer.End()
        reader.End()           
        i = i + 1
    }
    doc.Save(outputPath + "doc_memory_edit.pdf", uint(SDFDocE_remove_unused))
    
    // Save the document to a memory buffer
    buffer := (doc.Save(uint(SDFDocE_remove_unused))).(VectorUnChar)

    // Write the contents of the buffer to the disk
    bufferBytes := make([]byte, int(buffer.Size()))
    for i := 0; i < int(buffer.Size()); i++{
        bufferBytes[i] = buffer.Get(i)
    }
    f, err := os.Create(outputPath + "doc_memory_edit.txt")

    if err != nil {
        fmt.Println(err)
    }
    defer f.Close()
    _, err2 := f.Write(bufferBytes)
    if err2 != nil {
        fmt.Println(err2)
    }

    // Read some data from the file stored in memory
    reader.Begin(doc.GetPage(1))
    element = reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{
        if element.GetType() == ElementE_path{
            os.Stdout.Write([]byte("Path, "))
        }
        element = reader.Next()
    }
    reader.End()
    
    PDFNetTerminate()
    fmt.Println("\n\nDone. Result saved in doc_memory_edit.pdf and doc_memory_edit.txt ...")
}
