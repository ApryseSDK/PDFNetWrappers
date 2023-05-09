//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "flag"
    "strconv"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to parse and check if a PDF document meets the
//    PDFA standard, using the PDFACompliance class object. 
//---------------------------------------------------------------------------------------

func PrintResults(pdfa PDFACompliance, filename string){
    errCnt := pdfa.GetErrorCount()
    if errCnt == 0{
        fmt.Println(filename + ": OK.")
    }else{
        fmt.Println(filename + " is NOT a valid PDFA.")
        i := int64(0)
        for i < errCnt{
            c := pdfa.GetError(i)
            str1 := " - e_PDFA " + strconv.Itoa(int(c)) + ": " + PDFAComplianceGetPDFAErrorMessage(c) + "."
            if true{
                num_refs := pdfa.GetRefObjCount(c)
                if num_refs > int64(0){
                    str1 = str1 + "\n   Objects: "
                    j := int64(0)
                    for j < num_refs{
                        str1 = str1 + strconv.Itoa(int(pdfa.GetRefObj(c, j)))
                        if j < num_refs-1{
                            str1 = str1 + ", "
                        }
                        j = j + 1
                    }
                }
            }
            fmt.Println(str1)
            i = i + 1
        }
        fmt.Println("")
    }
}

func TestPDFA(t *testing.T){
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    PDFNetInitialize(licenseKey)
    PDFNetSetColorManagement()     // Enable color management (required for PDFA validation).
    
    //-----------------------------------------------------------
    // Example 1: PDF/A Validation
    //-----------------------------------------------------------
    filename := "newsletter.pdf"
    var cErrorCode PdftronPDFPDFAPDFAComplianceErrorCode
    // The max_ref_objs parameter to the PDFACompliance constructor controls the maximum number 
    // of object numbers that are collected for particular error codes. The default value is 10 
    // in order to prevent spam. If you need all the object numbers, pass 0 for max_ref_objs.
    pdfa := NewPDFACompliance(false, inputPath + filename, "", PDFAComplianceE_Level2B, &cErrorCode, 0, 10)
    PrintResults(pdfa, filename)
    pdfa.Destroy()
    
    //-----------------------------------------------------------
    // Example 2: PDF/A Conversion
    //-----------------------------------------------------------
    filename = "fish.pdf"
    pdfa = NewPDFACompliance(true, inputPath + filename, "", PDFAComplianceE_Level2B, &cErrorCode, 0, 10)
    filename = "pdfa.pdf"
    pdfa.SaveAs(outputPath + filename, false)
    pdfa.Destroy()
    
    // Re-validate the document after the conversion...
    pdfa = NewPDFACompliance(false, outputPath + filename, "", PDFAComplianceE_Level2B, &cErrorCode, 0, 10)
    PrintResults(pdfa, filename)
    pdfa.Destroy()

    PDFNetTerminate()
    fmt.Println("PDFACompliance test completed.")
}
