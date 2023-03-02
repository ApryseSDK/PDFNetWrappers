//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "strconv"
    "flag"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func TestPDFPage(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
	// Sample 1 - Split a PDF document into multiple pages    
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 1 - Split a PDF document into multiple pages...")
    fmt.Println("Opening the input pdf...")
    inDoc := NewPDFDoc(inputPath + "newsletter.pdf")
    inDoc.InitSecurityHandler()
	
    pageNum := inDoc.GetPageCount()
	for i := 1; i <= pageNum; i++ {
		iStr := strconv.Itoa(i)
        newDoc := NewPDFDoc()
        newDoc.InsertPages(0, inDoc, i, i, PDFDocE_none)
        newDoc.Save(outputPath + "newsletter_split_page_" + iStr + ".pdf", uint(SDFDocE_remove_unused))
        fmt.Println("Done. Result saved in newsletter_split_page_" + iStr + ".pdf")
        newDoc.Close()
    }
    // Close the open document to free up document memory sooner than waiting for the
    // garbage collector    
    inDoc.Close()
    
    // Sample 2 - Merge several PDF documents into one    
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 2 - Merge several PDF documents into one...")
    newDoc := NewPDFDoc()
    newDoc.InitSecurityHandler()
    
    pageNum = 15
    
	for i := 1; i <= pageNum; i ++ {
        fmt.Println("Opening newsletter_split_page_" + strconv.Itoa(i) + ".pdf")
        inDoc = NewPDFDoc(outputPath + "newsletter_split_page_" + strconv.Itoa(i) + ".pdf")
        newDoc.InsertPages(i, inDoc, 1, inDoc.GetPageCount(), PDFDocE_none)
        inDoc.Close()
    }  
    newDoc.Save(outputPath + "newsletter_merge_pages.pdf", uint(SDFDocE_remove_unused))
    fmt.Println("Done. Result saved in newsletter_merge_pages.pdf");
	
    // Close the open document to free up document memory sooner than waiting for the
    // garbage collector   
    inDoc.Close()
    
    // Sample 3 - Delete every second page    
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 3 - Delete every second page...")
    fmt.Println("Opening the input pdf...")
    inDoc = NewPDFDoc(inputPath +  "newsletter.pdf")
    inDoc.InitSecurityHandler();
    pageNum = inDoc.GetPageCount()
    
	for pageNum >= 1 {
        itr := inDoc.GetPageIterator(uint(pageNum))
        inDoc.PageRemove(itr)
        pageNum = pageNum - 2
	}

    inDoc.Save(outputPath +  "newsletter_page_remove.pdf", uint(0))
    fmt.Println("Done. Result saved in newsletter_page_remove.pdf...")
    
    // Close the open document to free up document memory sooner than waiting for the
    // garbage collector
    inDoc.Close()
       
    // Sample 4 - Inserts a page from one document at different 
    // locations within another document
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 4 - Insert a page at different locations...")
    fmt.Println("Opening the input pdf...")
    
    in1Doc := NewPDFDoc(inputPath +  "newsletter.pdf")
    in1Doc.InitSecurityHandler()
    in2Doc := NewPDFDoc(inputPath +  "fish.pdf")
    in2Doc.InitSecurityHandler()
    
    srcPage := in2Doc.GetPageIterator()
    dstPage := in1Doc.GetPageIterator()
    pageNum = 1
    for dstPage.HasNext(){
        if (pageNum % 3 == 0){
            in1Doc.PageInsert(dstPage, srcPage.Current())
		}
        pageNum = pageNum + 1
        dstPage.Next()
	}
    in1Doc.Save(outputPath +  "newsletter_page_insert.pdf", uint(0))
    fmt.Println("Done. Result saved in newsletter_page_insert.pdf...")
    
    // Close the open document to free up document memory sooner than waiting for the
    // garbage collector
    in1Doc.Close()
    in2Doc.Close()
    
    // Sample 5 - Replicate pages within a single document
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 5 - Replicate pages within a single document...")
    fmt.Println("Opening the input pdf...")
    
    doc := NewPDFDoc(inputPath + "newsletter.pdf")
    doc.InitSecurityHandler()
    
    // Replicate the cover page three times (copy page //1 and place it before the 
    // seventh page in the document page sequence)
    cover := doc.GetPage(1)
    p7 := doc.GetPageIterator(uint(7))
    doc.PageInsert(p7, cover)
    doc.PageInsert(p7, cover)
    doc.PageInsert(p7, cover)
    
    // Replicate the cover page two more times by placing it before and after
    // existing pages.
    doc.PagePushFront(cover);
    doc.PagePushBack(cover)
    
    doc.Save(outputPath +  "newsletter_page_clone.pdf", uint(0))
    fmt.Println("Done. Result saved in newsletter_page_clone.pdf...")
    doc.Close()
    
    // Sample 6 - Use ImportPages() in order to copy multiple pages at once 
    // in order to preserve shared resources between pages (e.g. images, fonts, 
    // colorspaces, etc.)
    fmt.Println("_______________________________________________")
    fmt.Println("Sample 6 - Preserving shared resources using ImportPages...")
    fmt.Println("Opening the input pdf...")
    inDoc = NewPDFDoc(inputPath +  "newsletter.pdf")
    inDoc.InitSecurityHandler()
    newDoc = NewPDFDoc()
	copyPages := NewVectorPage()
    itr := inDoc.GetPageIterator()
    for itr.HasNext(){
        copyPages.Add(itr.Current())
        itr.Next()
    }

    importedPages := newDoc.ImportPages(copyPages)
	for i := 0; i < int(importedPages.Size()); i ++{
		newDoc.PagePushFront(importedPages.Get(i))
	}
    newDoc.Save(outputPath +  "newsletter_import_pages.pdf", uint(0))
    
    // Close the open document to free up document memory sooner than waiting for the
    // garbage collector
    inDoc.Close()
    newDoc.Close()
    
    PDFNetTerminate()
    fmt.Println("Done. Result saved in newsletter_import_pages.pdf...")
    fmt.Println("Note that the output file size is less than half the size")
    fmt.Println("of the file produced using individual page copy operations")
    fmt.Println("between two documents")
}
