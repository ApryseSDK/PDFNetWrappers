#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# This sample illustrates how to use basic SDF API (also known as Cos) to edit an 
# existing document.

	PDFNet.Initialize
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	puts "Opening the test file..."
	
	# Here we create a SDF/Cos document directly from PDF file. In case you have 
	# PDFDoc you can always access SDF/Cos document using PDFDoc.GetSDFDoc method.
	doc = SDFDoc.new(input_path + "fish.pdf")
	doc.InitSecurityHandler
	
	puts "Modifying info dictionary, adding custom properties, embedding a stream..."
	trailer = doc.GetTrailer  # Get the trailer
	
	# Now we will change PDF document information properties using SDF API
	
	# Get the Info dictionary
	itr = trailer.Find("Info")
	info = Obj.new
	if itr.HasNext
		info = itr.Value
		# Modify 'Producer' entry
		info.PutString("Producer", "PDFTron PDFNet")
		
		# Read title entry (if it is present)
		itr = info.Find("Author")
		if itr.HasNext
			oldstr = itr.Value.GetAsPDFTest
			info.PutText("Author", oldstr + "- Modified")
		else
			info.PutString("Author", "Me, myself, and I")
		end
	else
		# Info dict is missing.
		info = trailer.PutDict("Info")
		info.PutString("Producer", "PDFTron PDFNet")
		info.PutString("Title", "My document")
	end
		
	# Create a custom inline dictionary within Info dictionary
	custom_dict = info.PutDict("My Direct Dict")
	custom_dict.PutNumber("My Number", 100)	 # Add some key/value pairs
	custom_dict.PutArray("My Array")
	
	# Create a custom indirect array within Info dictionary
	custom_array = doc.CreateIndirectArray
	info.Put("My Indirect Array", custom_array)	# Add some entries
	
	# Create indirect link to root
	custom_array.PushBack(trailer.Get("Root").Value)
	
	# Embed a custom stream (file mystream.txt).
	embed_file = MappedFile.new(input_path + "my_stream.txt")
	mystm = FilterReader.new(embed_file)
	custom_array.PushBack( doc.CreateIndirectStream(mystm) )
	
	# Save the changes.
	puts "Saving modified test file..."
	doc.Save(output_path + "sdftest_out.pdf", 0, "%PDF-1.4")
	doc.Close
	
	puts "Test Completed"
	
