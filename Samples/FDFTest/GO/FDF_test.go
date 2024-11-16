//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
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

//---------------------------------------------------------------------------------------
// PDFNet includes a full support for FDF (Forms Data Format) and capability to merge/extract 
// forms data (FDF) with/from PDF. This sample illustrates basic FDF merge/extract functionality 
// available in PDFNet.
//---------------------------------------------------------------------------------------

func TestFDF(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    // Example 1
    // Iterate over all form fields in the document. Display all field names.
    
    doc := NewPDFDoc(inputPath + "form1.pdf")
    doc.InitSecurityHandler()
    
    itr := doc.GetFieldIterator()
    for itr.HasNext(){
        fmt.Println("Field name: " + itr.Current().GetName())
        fmt.Println("Field partial name: " + itr.Current().GetPartialName())
        
        fieldType := itr.Current().GetType()
		fieldTypeStr := ""
        if fieldType == FieldE_button{
            fieldTypeStr = "Button"
		}else if fieldType == FieldE_text{
            fieldTypeStr = "Text"
		}else if fieldType == FieldE_choice{
            fieldTypeStr = "Choice"
		}else if fieldType == FieldE_signature{
            fieldTypeStr = "Signiture"
        }  
        fmt.Println("Field type: " + fieldTypeStr)
        fmt.Println("------------------------------")
        itr.Next()
    }
    doc.Close()
    fmt.Println("Done.")
    
    // Example 2
    // Import XFDF into FDF, then merge data from FDF
	
	// XFDF to FDF
	// form fields
    fmt.Println("Import form field data from XFDF to FDF.")
	
    fdfDoc1 := FDFDocCreateFromXFDF(inputPath + "form1_data.xfdf")
    fdfDoc1.Save(outputPath + "form1_data.fdf")
	
	// annotations
    fmt.Println("Import annotations from XFDF to FDF.")
	
    fdfDoc2 := FDFDocCreateFromXFDF(inputPath + "form1_annots.xfdf")
    fdfDoc2.Save(outputPath + "form1_annots.fdf")
	
	// FDF to PDF
	// form fields
    fmt.Println("Merge form field data from FDF.")
	
    doc = NewPDFDoc(inputPath + "form1.pdf")
    doc.InitSecurityHandler()
    doc.FDFMerge(fdfDoc1)
	
    // Refreshing missing appearances is not required here, but is recommended to make them 
    // visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
    doc.RefreshAnnotAppearances()
	
    doc.Save(outputPath + "form1_filled.pdf", uint(SDFDocE_linearized))
	
	// annotations
    fmt.Println("Merge annotations from FDF.")

    doc.FDFMerge(fdfDoc2)
    // Refreshing missing appearances is not required here, but is recommended to make them 
    // visible in PDF viewers with incomplete annotation viewing support. (such as Chrome)
    doc.RefreshAnnotAppearances()
    doc.Save(outputPath + "form1_filled_with_annots.pdf", uint(SDFDocE_linearized))
    doc.Close()
    fmt.Println("Done.")
	
    
    // Example 3
    // Extract data from PDF to FDF, then export FDF as XFDF
    
	// PDF to FDF
    inDoc := NewPDFDoc(outputPath + "form1_filled_with_annots.pdf")
    inDoc.InitSecurityHandler()
	
	// form fields only
    fmt.Println("Extract form fields data to FDF.")
	
    docFields := inDoc.FDFExtract(PDFDocE_forms_only)
    docFields.SetPDFFileName("../form1_filled_with_annots.pdf")
    docFields.Save(outputPath + "form1_filled_data.fdf")
	
	// annotations only
    fmt.Println("Extract annotations to FDF.")
	
    docAnnots := inDoc.FDFExtract(PDFDocE_annots_only)
    docAnnots.SetPDFFileName("../form1_filled_with_annots.pdf")
    docAnnots.Save(outputPath + "form1_filled_annot.fdf")
	
	// both form fields and annotations
    fmt.Println("Extract both form fields and annotations to FDF.")
	
    docBoth := inDoc.FDFExtract(PDFDocE_both)
    docBoth.SetPDFFileName("../form1_filled_with_annots.pdf")
    docBoth.Save(outputPath + "form1_filled_both.fdf")
	
	// FDF to XFDF
	// form fields
    fmt.Println("Export form field data from FDF to XFDF.")
	
    docFields.SaveAsXFDF(outputPath + "form1_filled_data.xfdf")
	
	// annotations
    fmt.Println("Export annotations from FDF to XFDF.")
	
    docAnnots.SaveAsXFDF(outputPath + "form1_filled_annot.xfdf")
	
	// both form fields and annotations
    fmt.Println("Export both form fields and annotations from FDF to XFDF.")
	
    docBoth.SaveAsXFDF(outputPath + "form1_filled_both.xfdf")
	
    inDoc.Close()
    fmt.Println("Done.")
	
    // Example 4
    // Merge/Extract XFDF into/from PDF
    
    // Merge XFDF from string
    inDoc = NewPDFDoc(inputPath + "numbered.pdf")
    inDoc.InitSecurityHandler()

    fmt.Println("Merge XFDF string into PDF.")

    str := "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><xfdf xmlns=\"http://ns.adobe.com/xfdf\" xml:space=\"preserve\"><square subject=\"Rectangle\" page=\"0\" name=\"cf4d2e58-e9c5-2a58-5b4d-9b4b1a330e45\" title=\"user\" creationdate=\"D:20120827112326-07'00'\" date=\"D:20120827112326-07'00'\" rect=\"227.7814207650273,597.6174863387978,437.07103825136608,705.0491803278688\" color=\"#000000\" interior-color=\"#FFFF00\" flags=\"print\" width=\"1\"><popup flags=\"print,nozoom,norotate\" open=\"no\" page=\"0\" rect=\"0,792,0,792\" /></square></xfdf>"

    fdoc := FDFDocCreateFromXFDF(str)
    inDoc.FDFMerge(fdoc)
    inDoc.Save(outputPath + "numbered_modified.pdf", uint(SDFDocE_linearized))
    fmt.Println("Merge complete.")

    // Extract XFDF as string
    fmt.Println("Extract XFDF as a string.")

    fdocNew := inDoc.FDFExtract(PDFDocE_both)
    xfdfStr := fdocNew.SaveAsXFDF()
    fmt.Println("Extracted XFDF: ")
    fmt.Println(xfdfStr)
    inDoc.Close()
    fmt.Println("Extract complete.") 	
	
    // Example 5
    // Read FDF files directly
    
    fdoc2 := NewFDFDoc(outputPath + "form1_filled_data.fdf")
    
    fitr := fdoc2.GetFieldIterator()
    for fitr.HasNext(){
        fmt.Println("Field name: " + fitr.Current().GetName())
        fmt.Println("Field partial name: " + fitr.Current().GetPartialName())
        fmt.Println("------------------------------")
        fitr.Next()
    }
	
    fdoc2.Close()
    fmt.Println("Done.")
    
    // Example 6
    // Direct generation of FDF
    fdoc2 = NewFDFDoc()
    
    // Create new fields (i.r. key/value pairs
    fdoc2.FieldCreate("Company", FieldE_text, "PDFTron Systems")
    fdoc2.FieldCreate("First Name", FieldE_text, "John")
    fdoc2.FieldCreate("Last Name", FieldE_text, "Doe")
    
    fdoc2.Save(outputPath + "sample_output.fdf")
    fdoc2.Close()
    PDFNetTerminate()
    fmt.Println("Done. Results saved in sample_output.fdf")
}
