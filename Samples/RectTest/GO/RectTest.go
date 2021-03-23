//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	. "pdftron"
)

func main(){
	PDFNetInitialize()
	// Relative path to the folder containing test files.
	var inputPath = "../../TestFiles/"
	var outputPath = "../../TestFiles/Output/"
    // Test  - Adjust the position of content within the page.
    fmt.Println("_______________________________________________")
    fmt.Println("Opening the input pdf...")
    
    inputDoc := NewPDFDoc(inputPath + "tiger.pdf")
    inputDoc.InitSecurityHandler()
    pgItr1 := inputDoc.GetPageIterator()
    
    mediaBox := NewRect(pgItr1.Current().GetMediaBox())
    
    mediaBox.SetX1(mediaBox.GetX1() - 200)     // translate the page 200 units (1 uint = 1/72 inch)
    mediaBox.SetX2(mediaBox.GetX2() - 200)    
    
    mediaBox.Update()
    
    inputDoc.Save(outputPath + "tiger_shift.pdf", uint(0))
    inputDoc.Close()
    
    fmt.Println("Done. Result saved in tiger_shift...")    
}
