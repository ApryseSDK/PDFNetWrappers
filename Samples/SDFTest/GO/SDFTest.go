//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	. "pdftron"
)

// This sample illustrates how to use basic SDF API (also known as Cos) to edit an 
// existing document.

func main(){
    PDFNetInitialize()
    
    // Relative path to the folder containing the test files.
    inputPath := "../../TestFiles/"
    outputPath := "../../TestFiles/Output/"
    
    fmt.Println("Opening the test file...")
    
    // Here we create a SDF/Cos document directly from PDF file. In case you have 
    // PDFDoc you can always access SDF/Cos document using PDFDoc.GetSDFDoc() method.
    doc := NewSDFDoc(inputPath + "fish.pdf")
    doc.InitSecurityHandler()
    
    fmt.Println("Modifying info dictionary, adding custom properties, embedding a stream...")
    trailer := doc.GetTrailer()  // Get the trailer
    
    // Now we will change PDF document information properties using SDF API
    
    // Get the Info dictionary
    itr := trailer.Find("Info")
    info := NewObj()
    if itr.HasNext(){
        info = itr.Value()
        // Modify 'Producer' entry
        info.PutString("Producer", "PDFTron PDFNet")
        
        // Read title entry (if it is present)
        itr = info.Find("Author")
        if itr.HasNext(){
		fmt.Println("Author inside")
            oldstr := itr.Value().GetAsPDFText()
            info.PutText("Author", oldstr + "- Modified")
        }else{
            info.PutString("Author", "Me, myself, and I")
		}
    }else{
        // Info dict is missing.
        info = trailer.PutDict("Info")
        info.PutString("Producer", "PDFTron PDFNet")
        info.PutString("Title", "My document")
    }    
    // Create a custom inline dictionary within Info dictionary
    customDict := info.PutDict("My Direct Dict")
    customDict.PutNumber("My Number", 100)     // Add some key/value pairs
    customDict.PutArray("My Array")
    
    // Create a custom indirect array within Info dictionary
    customArray := doc.CreateIndirectArray()
    info.Put("My Indirect Array", customArray)    // Add some entries
    
    // Create indirect link to root
    customArray.PushBack(trailer.Get("Root").Value())
    
    // Embed a custom stream (file mystream.txt).
    embedFile := NewMappedFile(inputPath + "my_stream.txt")
    mystm := NewFilterReader(embedFile)
    customArray.PushBack( doc.CreateIndirectStream(mystm) )
    
    // Save the changes.
    fmt.Println("Saving modified test file...")
    doc.Save(outputPath + "sdftest_out.pdf", uint(0), "%PDF-1.4")
    doc.Close()
    
    fmt.Println("Test Completed")
    
}
