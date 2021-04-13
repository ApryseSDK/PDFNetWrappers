#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#---------------------------------------------------------------------------------------
# This sample shows encryption support in PDFNet. The sample reads an encrypted document and 
# sets a new SecurityHandler. The sample also illustrates how password protection can 
# be removed from an existing PDF document.
#---------------------------------------------------------------------------------------

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Example 1: 
    # secure a PDF document with password protection and adjust permissions
    
    # Open the test file
    print("Securing an existing document...")
    
    doc = PDFDoc(input_path + "fish.pdf")
    doc.InitSecurityHandler()
    
    # Perform some operation on the document. In this case we use low level SDF API
    # to replace the content stream of the first page with contents of file 'my_stream.txt'
    if True:    # Optional
        print("Replacing the content stream, use Flate compression...")
        
        # Get the page dictionary using the following path: trailer/Root/Pages/Kids/0
        page_dict = (doc.GetTrailer().Get("Root").Value()
                     .Get("Pages").Value()
                     .Get("Kids").Value()
                     .GetAt(0))
        
        # Embed a custom stream (file mystream.txt) using Flate compression.
        embed_file = MappedFile(input_path + "my_stream.txt")
        mystm = FilterReader(embed_file)
        page_dict.Put("Contents", doc.CreateIndirectStream(mystm, FlateEncode(Filter())))
        
    # encrypt the document
    
    # Apply a new security handler with given security settings.
    # In order to open saved PDF you will need a user password 'test'.
    new_handler = SecurityHandler()
    
    # Set a new password required to open a document
    user_password = "test"
    new_handler.ChangeUserPassword(user_password)
    
    # Set permissions
    new_handler.SetPermission(SecurityHandler.e_print, True)
    new_handler.SetPermission(SecurityHandler.e_extract_content, False)
    
    # Note: document takes the ownership of new_handler.
    doc.SetSecurityHandler(new_handler)
    
    # save the changes.
    print("Saving modified file...")
    doc.Save(output_path + "secured.pdf", 0)
    doc.Close()
    
    # Example 2:
    # Opens an encrypted PDF document and removes its security.
    
    doc = PDFDoc(output_path + "secured.pdf")
    
    # If the document is encrypted prompt for the password
    if not doc.InitSecurityHandler():
        success = False
        print("The password is: test")
        count = 0
        while count < 3:
            print("A password required to open the document.")
            if sys.version_info.major >= 3:
                password = input("Please enter the password: \n")
            else:
                password = raw_input("Please enter the password: \n")
                
            if doc.InitStdSecurityHandler(password, len(password)):
                success = True
                print("The password is correct.")
                break
            elif count < 3:
                print("The password is incorrect, please try again")
            count = count + 1
            
        if not success:
            print("Document authentication error....")
            return
        
        hdlr = doc.GetSecurityHandler()
        print("Document Open Password: " + str(hdlr.IsUserPasswordRequired()))
        print("Permissions Password: " + str(hdlr.IsMasterPasswordRequired()))
        print(("Permissions: " 
                + "\n\tHas 'owner' permissions: " + str(hdlr.GetPermission(SecurityHandler.e_owner))
                + "\n\tOpen and decrypt the document: " + str(hdlr.GetPermission(SecurityHandler.e_doc_open))
                + "\n\tAllow content extraction: " + str(hdlr.GetPermission(SecurityHandler.e_extract_content)) 
                + "\n\tAllow full document editing: " + str(hdlr.GetPermission(SecurityHandler.e_doc_modify) )
                + "\n\tAllow printing: " + str(hdlr.GetPermission(SecurityHandler.e_print)) 
                + "\n\tAllow high resolution printing: " + str(hdlr.GetPermission(SecurityHandler.e_print_high)) 
                + "\n\tAllow annotation editing: " + str(hdlr.GetPermission(SecurityHandler.e_mod_annot)) 
                + "\n\tAllow form fill: " + str(hdlr.GetPermission(SecurityHandler.e_fill_forms)) 
                + "\n\tAllow content extraction for accessibility: " + str(hdlr.GetPermission(SecurityHandler.e_access_support)) 
                + "\n\tAllow document assembly: " + str(hdlr.GetPermission(SecurityHandler.e_assemble_doc))))
        
    # remove all security on the document
    doc.RemoveSecurity()
    doc.Save(output_path + "not_secured.pdf", 0)
    doc.Close()

    # Example 3:
    # Encrypt/Decrypt a PDF using PDFTron custom security handler
    print("-------------------------------------------------")
    print("Encrypt a document using PDFTron Custom Security handler with a custom id and password...")
    doc = PDFDoc(input_path + "BusinessCardTemplate.pdf")

    # Create PDFTron custom security handler with a custom id. Replace this with your own integer
    custom_id = 123456789
    custom_handler = PDFTronCustomSecurityHandler(custom_id)

    # Add a password to the custom security handler
    password = "test"
    custom_handler.ChangeUserPassword(password)

    # Save the encrypted document
    doc.SetSecurityHandler(custom_handler)
    doc.Save(output_path + "BusinessCardTemplate_enc.pdf", 0)
    doc.Close()

    print("Decrypt the PDFTron custom security encrypted document above...")
    # Register the PDFTron Custom Security handler with the same custom id used in encryption
    PDFNet.AddPDFTronCustomHandler(custom_id)

    doc_enc = PDFDoc(output_path + "BusinessCardTemplate_enc.pdf")
    doc_enc.InitStdSecurityHandler(password)
    doc_enc.RemoveSecurity()
    # Save the decrypted document
    doc_enc.Save(output_path + "BusinessCardTemplate_enc_dec.pdf", 0)
    doc_enc.Close()
    print("Done. Result saved in BusinessCardTemplate_enc_dec.pdf")
    print("-------------------------------------------------");
    print("Test completed.")
        
if __name__ == '__main__':
    main()
        
        
        
        
        
        
        
