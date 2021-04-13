#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# The following sample illustrates how to read/write a PDF document from/to 
# a memory buffer.  This is useful for applications that work with dynamic PDF
# documents that don't need to be saved/read from a disk.

	PDFNet.Initialize
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Read a PDF document in a memory buffer.
	file = MappedFile.new((input_path + "tiger.pdf"))
	file_sz = file.FileSize
	
	file_reader = FilterReader.new(file)
	
	mem = file_reader.Read(file_sz)
	doc = PDFDoc.new(mem, file_sz)
	doc.InitSecurityHandler
	num_pages = doc.GetPageCount
	
	writer = ElementWriter.new
	reader = ElementReader.new
	element = Element.new
	
	# Create a duplicate of every page but copy only path objects
	
	i = 1
	while i <= num_pages do
		itr = doc.GetPageIterator(2*i - 1)
		
		reader.Begin(itr.Current)
		new_page = doc.PageCreate(itr.Current.GetMediaBox)
		next_page = itr
		next_page.Next
		doc.PageInsert(next_page, new_page)
		
		writer.Begin(new_page)
		element = reader.Next
		while !element.nil? do	# Read page contents
			#if element.GetType == Element::E_path
            writer.WriteElement(element)
			#end
			element = reader.Next
		end
		writer.End
		reader.End		   
		i = i + 1
	end
	
	doc.Save(output_path + "doc_memory_edit.pdf", SDFDoc::E_remove_unused)
	
	# Save the document to a memory buffer
	buffer = doc.Save(SDFDoc::E_remove_unused)
	
	# Write the contents of the buffer to the disk
    File.open(output_path + "doc_memory_edit.txt", 'w') { |file| file.write(buffer) }
	
	# Read some data from the file stored in memory
	reader.Begin(doc.GetPage(1))
	element = reader.Next
	while !element.nil? do
		if element.GetType == Element::E_path
			print "Path, "
		end
		element = reader.Next
	end
	reader.End
	
	puts "\n\nDone. Result saved in doc_memory_edit.pdf and doc_memory_edit.txt ..."

