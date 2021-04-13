#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#-----------------------------------------------------------------------------------------
# The sample code illustrates how to read and edit existing outline items and create 
# new bookmarks using the high-level API.
#-----------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#-----------------------------------------------------------------------------------------
# The sample code illustrates how to use the ContentReplacer class to make using 
# 'template' pdf documents easier.
#-----------------------------------------------------------------------------------------
	PDFNet.Initialize()
	
	# Example 1) Update a business card template with personalized info
	
	doc = PDFDoc.new(input_path + "BusinessCardTemplate.pdf")
	doc.InitSecurityHandler()
	
	# first, replace the image on the first page
	replacer = ContentReplacer.new()
	page = doc.GetPage(1)
	img = Image.Create(doc.GetSDFDoc(), input_path + "peppers.jpg")
	replacer.AddImage(page.GetMediaBox(), img.GetSDFObj())
	# next, replace the text place holders on the second page
	replacer.AddString("NAME", "John Smith")
	replacer.AddString("QUALIFICATIONS", "Philosophy Doctor")
	replacer.AddString("JOB_TITLE", "Software Developer")
	replacer.AddString("ADDRESS_LINE1", "#100 123 Software Rd")
	replacer.AddString("ADDRESS_LINE2", "Vancouver, BC")
	replacer.AddString("PHONE_OFFICE", "604-730-8989")
	replacer.AddString("PHONE_MOBILE", "604-765-4321")
	replacer.AddString("EMAIL", "info@pdftron.com")
	replacer.AddString("WEBSITE_URL", "http://www.pdftron.com")
	# finally, apply
	replacer.Process(page)
	
	doc.Save(output_path + "BusinessCard.pdf", 0)
	doc.Close()
	puts "Done. Result saved in BusinessCard.pdf"

	# Example 2) Replace text in a region with new text
	
	doc = PDFDoc.new(input_path + "newsletter.pdf")
	doc.InitSecurityHandler()
	
	replacer = ContentReplacer.new()
	page = doc.GetPage(1)
	replacer.AddText(page.GetMediaBox(), "hello hello hello hello hello hello hello hello hello hello")
	replacer.Process(page)
	
	doc.Save(output_path + "ContentReplaced.pdf", SDFDoc::E_linearized)
	doc.Close()
	puts "Done. Result saved in ContentReplaced.pdf"

	puts "Done."
