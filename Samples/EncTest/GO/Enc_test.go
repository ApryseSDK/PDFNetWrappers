//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package EncTest
import (
    "fmt"
    "strconv"
    "testing"
    . "github.com/pdftron/pdftron-go/v2"
    "flag"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// This sample shows encryption support in PDFNet. The sample reads an encrypted document and 
// sets a new SecurityHandler. The sample also illustrates how password protection can 
// be removed from an existing PDF document.
//---------------------------------------------------------------------------------------

func TestEnc(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    // Example 1: 
    // secure a PDF document with password protection and adjust permissions
    
    // Open the test file
    fmt.Println("Securing an existing document...")
    
    doc := NewPDFDoc(inputPath + "fish.pdf")
    doc.InitSecurityHandler()
    
    // Perform some operation on the document. In this case we use low level SDF API
    // to replace the content stream of the first page with contents of file 'my_stream.txt'
    if true{    // Optional
        fmt.Println("Replacing the content stream, use Flate compression...")
        
        // Get the page dictionary using the following path: trailer/Root/Pages/Kids/0
        pageDict := (doc.GetTrailer().Get("Root").Value().Get("Pages").Value().Get("Kids").Value().GetAt(0))
        
        // Embed a custom stream (file mystream.txt) using Flate compression.
        embedFile := NewMappedFile(inputPath + "my_stream.txt")
        mystm := NewFilterReader(embedFile)
        pageDict.Put("Contents", doc.CreateIndirectStream(mystm, NewFilter()))
    }   
    // encrypt the document
    
    // Apply a new security handler with given security settings.
    // In order to open saved PDF you will need a user password 'test'.
    newHandler := NewSecurityHandler()
    
    // Set a new password required to open a document
    userPassword := "test"
    newHandler.ChangeUserPassword(userPassword)
    
    // Set permissions
    newHandler.SetPermission(SecurityHandlerE_print, true)
    newHandler.SetPermission(SecurityHandlerE_extract_content, false)
    
    // Note: document takes the ownership of newHandler.
    doc.SetSecurityHandler(newHandler)
    
    // save the changes.
    fmt.Println("Saving modified file...")
    doc.Save(outputPath + "secured.pdf", uint(0))
    doc.Close()
    
    // Example 2:
    // Opens an encrypted PDF document and removes its security.
    
    doc = NewPDFDoc(outputPath + "secured.pdf")
    
    // If the document is encrypted prompt for the password
    if !doc.InitSecurityHandler(){
        success := false
        fmt.Println("The password is: test")
        count := 0
        for count < 3{
            fmt.Println("A password required to open the document.")
            var password string
            fmt.Print("Please enter the password: \n")
            fmt.Scanf("%s", &password)
            fmt.Println(password)
                
            if doc.InitStdSecurityHandler(password, len(password)){
                success = true
                fmt.Println("The password is correct.")
                break
            }else if count < 3{
                fmt.Println("The password is incorrect, please try again")
            }
            count = count + 1
        }    
        if !success{
            fmt.Println("Document authentication error....")
            return
        }
        hdlr := doc.GetSecurityHandler()
        fmt.Println("Document Open Password: " + strconv.FormatBool(hdlr.IsUserPasswordRequired()))
        fmt.Println("Permissions Password: " + strconv.FormatBool(hdlr.IsMasterPasswordRequired()))
        fmt.Println(("Permissions: " + 
                "\n\tHas 'owner' permissions: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_owner)) + 
                "\n\tOpen and decrypt the document: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_doc_open)) +
                "\n\tAllow content extraction: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_extract_content)) +
                "\n\tAllow full document editing: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_doc_modify) ) +
                "\n\tAllow printing: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_print)) + 
                "\n\tAllow high resolution printing: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_print_high)) + 
                "\n\tAllow annotation editing: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_mod_annot)) + 
                "\n\tAllow form fill: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_fill_forms)) + 
                "\n\tAllow content extraction for accessibility: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_access_support)) + 
                "\n\tAllow document assembly: " + strconv.FormatBool(hdlr.GetPermission(SecurityHandlerE_assemble_doc))))
    }
    
    // remove all security on the document
    doc.RemoveSecurity()
    doc.Save(outputPath + "not_secured.pdf", uint(0))
    doc.Close()
    
    PDFNetTerminate()
    fmt.Println("Test completed.")
}
