//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "strconv"
    "testing"
    "flag"
    . "math"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// This sample illustrates the basic text search capabilities of PDFNet.

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func TestTextSearch(t *testing.T){
    // Initialize PDFNet
    PDFNetInitialize(licenseKey)
    doc := NewPDFDoc(inputPath + "credit card numbers.pdf")
    doc.InitSecurityHandler()
    
    txtSearch := NewTextSearch()
    mode := TextSearchE_whole_word | TextSearchE_page_stop
    
    pattern := "joHn sMiTh"
    
    // call Begin() method to initialize the text search.
    txtSearch.Begin(doc, pattern, uint(mode))

    step := 0
    
    // call Run() method iteratively to find all matching instances.
    for true{
        searchResult := txtSearch.Run()
        if searchResult.IsFound(){
            if step == 0{
                // step 0: found "John Smith"
                // note that, here, 'ambient_string' and 'hlts' are not written to, 
                // as 'e_ambient_string' and 'e_highlight' are not set.
                
                fmt.Println(searchResult.GetMatch() + "'s credit card number is: ")
                // now switch to using regular expressions to find John's credit card number
                mode := PdftronPDFTextSearchTextSearchModes(txtSearch.GetMode())
                mode = mode | TextSearchE_reg_expression | TextSearchE_highlight
                txtSearch.SetMode(uint(mode))
                pattern := "\\d{4}-\\d{4}-\\d{4}-\\d{4}"     //or "(\\d{4}-){3}\\d{4}"
                txtSearch.SetPattern(pattern)
                step = step + 1
            }else if step == 1{
                // step 1: found John's credit card number
                fmt.Println("  " + searchResult.GetMatch())
                
                // note that, here, 'hlts' is written to, as 'e_highligh' has been set.
                // output the highlight info of the credit card number
                hlts := searchResult.GetHighlights()
                hlts.Begin(doc)
                for hlts.HasNext(){
                    fmt.Println("The current highlight is from page: " + strconv.Itoa(hlts.GetCurrentPageNumber()))
                    hlts.Next()
                }
                // see if there is an AMEX card number
                pattern := "\\d{4}-\\d{6}-\\d{5}"
                txtSearch.SetPattern(pattern)
                
                step = step + 1
            }else if step == 2{
                // found an AMEX card number
                fmt.Println("\nThere is an AMEX card number:\n  " + searchResult.GetMatch())
                
                // change mode to find the owner of the credit card; supposedly, the owner's
                // name proceeds the number
                mode := PdftronPDFTextSearchTextSearchModes(txtSearch.GetMode())
                mode = mode | TextSearchE_search_up
                txtSearch.SetMode(uint(mode))
                pattern := "[A-z]++ [A-z]++"
                txtSearch.SetPattern(pattern)
                step = step + 1
            }else if step == 3{
                // found the owner's name of the AMEX card
                fmt.Println("Is the owner's name:\n  " + searchResult.GetMatch() + "?")
                
                // add a link annotation based on the location of the found instance
                hlts := searchResult.GetHighlights()
                hlts.Begin(doc)
                
                for hlts.HasNext(){
                    curPage := doc.GetPage(uint(hlts.GetCurrentPageNumber()))
                    quadsInfo := hlts.GetCurrentQuads()
                    
                    i := 0
                    for i < int(quadsInfo.Size()){
                        q := quadsInfo.Get(i)
                        // assume each quad is an axis-aligned rectangle 
                        x1 := Min(Min(Min(q.GetP1().GetX(), q.GetP2().GetX()), q.GetP3().GetX()), q.GetP4().GetX())
                        x2 := Max(Max(Max(q.GetP1().GetX(), q.GetP2().GetX()), q.GetP3().GetX()), q.GetP4().GetX())
                        y1 := Min(Min(Min(q.GetP1().GetY(), q.GetP2().GetY()), q.GetP3().GetY()), q.GetP4().GetY())
                        y2 := Max(Max(Max(q.GetP1().GetY(), q.GetP2().GetY()), q.GetP3().GetY()), q.GetP4().GetY())
                        hyperLink := LinkCreate(doc.GetSDFDoc(), NewRect(x1, y1, x2, y2), ActionCreateURI(doc.GetSDFDoc(), "http://www.pdftron.com"))
                        curPage.AnnotPushBack(hyperLink)
                        i = i + 1
					}
                    hlts.Next()
				}
                doc.Save(outputPath + "credit card numbers_linked.pdf", uint(SDFDocE_linearized))
                break
			}
        }else if searchResult.IsPageEnd(){
            //you can update your UI here, if needed
        }else{
            break
		}
    }    
    doc.Close()
    PDFNetTerminate()
}
