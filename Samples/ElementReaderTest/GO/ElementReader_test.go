//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
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

func ProcessElements(reader ElementReader){
    element := reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{       // Read page contents
        if element.GetType() == ElementE_path{      // Process path data...
            //uncomment below if needed
            //data := element.GetPathData()
            //points := data.GetPoints()
        }else if element.GetType() == ElementE_text{        // Process text strings...
            data := element.GetTextString()
            fmt.Println(data)
        }else if element.GetType() == ElementE_form{        // Process form XObjects
            reader.FormBegin()
            ProcessElements(reader)
            reader.End()
        }
        element = reader.Next()
    }
}

func TestElementReader(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Extract text data from all pages in the document
    fmt.Println("-------------------------------------------------")
    fmt.Println("Sample 1 - Extract text data from all pages in the document.")
    fmt.Println("Opening the input pdf...")
    
    doc := NewPDFDoc(inputPath + "newsletter.pdf")
    doc.InitSecurityHandler()
    
    pageReader := NewElementReader()
    
    itr := doc.GetPageIterator()
    
    // Read every page
    for itr.HasNext(){
        pageReader.Begin(itr.Current())
        ProcessElements(pageReader)
        pageReader.End()
        itr.Next()
    }
    // Close the open document to free up document memory sooner.    
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
