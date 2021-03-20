#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# This sample shows encryption support in PDFNet. The sample reads an encrypted document and 
# sets a new SecurityHandler. The sample also illustrates how password protection can 
# be removed from an existing PDF document.
#---------------------------------------------------------------------------------------

	PDFNet.Initialize()
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Example 1: 
	# secure a PDF document with password protection and adjust permissions
	
	# Open the test file
	puts "Securing an existing document..."
	
	doc = PDFDoc.new(input_path + "fish.pdf")
	doc.InitSecurityHandler()
	
	# Perform some operation on the document. In this case we use low level SDF API
	# to replace the content stream of the first page with contents of file 'my_stream.txt'
	if true	# Optional
		puts "Replacing the content stream, use Flate compression..."
		
		# Get the page dictionary using the following path: trailer/Root/Pages/Kids/0
		page_dict = (doc.GetTrailer().Get("Root").Value()
					 .Get("Pages").Value()
					 .Get("Kids").Value()
					 .GetAt(0))
		
		# Embed a custom stream (file mystream.txt) using Flate compression.
		embed_file = MappedFile.new(input_path + "my_stream.txt")
		mystm = FilterReader.new(embed_file)
		page_dict.Put("Contents", doc.CreateIndirectStream(mystm, FlateEncode.new(Filter.new())))
	end
		
	# encrypt the document
	
	# Apply a new security handler with given security settings.
	# In order to open saved PDF you will need a user password 'test'.
	new_handler = SecurityHandler.new()
	
	# Set a new password required to open a document
	user_password = "test"
	new_handler.ChangeUserPassword(user_password)
	
	# Set permissions
	new_handler.SetPermission(SecurityHandler::E_print, true)
	new_handler.SetPermission(SecurityHandler::E_extract_content, false)
	
	# Note: document takes the ownership of new_handler.
	doc.SetSecurityHandler(new_handler)
	
	# save the changes.
	puts "Saving modified file..."
	doc.Save(output_path + "secured.pdf", 0)
	doc.Close()
	
	# Example 2:
	# Opens an encrypted PDF document and removes its security.
	
	doc = PDFDoc.new(output_path + "secured.pdf")
	
	# If the document is encrypted prompt for the password
	if !doc.InitSecurityHandler()
		success = false
		puts "The password is: test"
		count = 0
		while count < 3 do
			puts "A password required to open the document."
			puts "Please enter the password:"
			password = gets.chomp
			if doc.InitStdSecurityHandler(password, password.length)
				success = true
				puts "The password is correct."
				break
			elsif count < 3
				puts "The password is incorrect, please try again"
			end
			count = count + 1
		end
			
		if !success
			puts "Document authentication error...."
			return
		end
		
		hdlr = doc.GetSecurityHandler()
		puts "Document Open Password: " + hdlr.IsUserPasswordRequired().to_s()
		puts "Permissions Password: " + hdlr.IsMasterPasswordRequired().to_s()
		puts ("Permissions:  " +
				"\n\tHas 'owner' permissions: " + hdlr.GetPermission(SecurityHandler::E_owner).to_s() +
				"\n\tOpen and decrypt the document: " + hdlr.GetPermission(SecurityHandler::E_doc_open).to_s() +
				"\n\tAllow content extraction: " + hdlr.GetPermission(SecurityHandler::E_extract_content).to_s() +
				"\n\tAllow full document editing: " + hdlr.GetPermission(SecurityHandler::E_doc_modify).to_s() +
				"\n\tAllow printing: " + hdlr.GetPermission(SecurityHandler::E_print).to_s() +
				"\n\tAllow high resolution printing: " + hdlr.GetPermission(SecurityHandler::E_print_high).to_s() +
				"\n\tAllow annotation editing: " + hdlr.GetPermission(SecurityHandler::E_mod_annot).to_s() +
				"\n\tAllow form fill: " + hdlr.GetPermission(SecurityHandler::E_fill_forms).to_s() +
				"\n\tAllow content extraction for accessibility: " + hdlr.GetPermission(SecurityHandler::E_access_support).to_s() +
				"\n\tAllow document assembly: " + hdlr.GetPermission(SecurityHandler::E_assemble_doc).to_s())
	end
		
	# remove all security on the document
	doc.RemoveSecurity()
	doc.Save(output_path + "not_secured.pdf", 0)
	doc.Close()

	# Example 3:
	# Encrypt/Decrypt a PDF using PDFTron custom security handler
	puts "-------------------------------------------------"
	puts "Encrypt a document using PDFTron Custom Security handler with a custom id and password..."
	doc = PDFDoc.new(input_path + "BusinessCardTemplate.pdf")

	# Create PDFTron custom security handler with a custom id. Replace this with your own integer
	custom_id = 123456789
	custom_handler = PDFTronCustomSecurityHandler.new(custom_id)

	# Add a password to the custom security handler
	password = "test"
	custom_handler.ChangeUserPassword(password)

	# Save the encrypted document
	doc.SetSecurityHandler(custom_handler)
	doc.Save(output_path + "BusinessCardTemplate_enc.pdf", 0)
	doc.Close()

	puts "Decrypt the PDFTron custom security encrypted document above..."
	# Register the PDFTron Custom Security handler with the same custom id used in encryption
	PDFNet.AddPDFTronCustomHandler(custom_id)

	doc_enc = PDFDoc.new(output_path + "BusinessCardTemplate_enc.pdf")
	doc_enc.InitStdSecurityHandler(password)
	doc_enc.RemoveSecurity()
	# Save the decrypted document
	doc_enc.Save(output_path + "BusinessCardTemplate_enc_dec.pdf", 0)
	doc_enc.Close()
	puts "Done. Result saved in BusinessCardTemplate_enc_dec.pdf"
	puts "-------------------------------------------------"
	puts "Test completed."
		
