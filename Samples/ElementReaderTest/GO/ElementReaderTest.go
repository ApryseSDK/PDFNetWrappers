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
// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"

//---------------------------------------------------------------------------------------

func catch(err *error) {
    if r := recover(); r != nil {
        *err = fmt.Errorf("%v", r)
    }
}

//---------------------------------------------------------------------------------------


func ProcessElements(reader ElementReader) (err error){

	defer catch(&err)
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
	return nil
}

func main(){
    PDFNetInitialize(PDFTronLicense.Key)
    
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
        err := ProcessElements(pageReader)
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to process elements, error: %s", err))
		}
        pageReader.End()
        itr.Next()
    }
    // Close the open document to free up document memory sooner.    
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
