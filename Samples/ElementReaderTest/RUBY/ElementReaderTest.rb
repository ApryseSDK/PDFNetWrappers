#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"

def ProcessElements(reader)
	element = reader.Next()
	while !element.nil? do	# Read page contents
		if element.GetType() == Element::E_path	# Process path data...
			data = element.GetPathData()
			points = data.GetPoints()
		elsif element.GetType() == Element::E_text	# Process text strings...
			data = element.GetTextString()
			puts data
		elsif element.GetType() == Element::E_form	# Process form XObjects
			reader.FormBegin()
			ProcessElements(reader)
			reader.End()
		end
		element = reader.Next()
	end
end

	PDFNet.Initialize()
	
	# Extract text data from all pages in the document
	puts "-------------------------------------------------"
	puts "Sample 1 - Extract text data from all pages in the document."
	puts "Opening the input pdf..."
	
	doc = PDFDoc.new(input_path + "newsletter.pdf")
	doc.InitSecurityHandler()
	
	page_reader = ElementReader.new()
	
	itr = doc.GetPageIterator()
	
	# Read every page
	while itr.HasNext() do
		page_reader.Begin(itr.Current())
		ProcessElements(page_reader)
		page_reader.End()
		itr.Next()
	end
	
	# Close the open document to free up document memory sooner.	
	doc.Close()
	puts "Done."
