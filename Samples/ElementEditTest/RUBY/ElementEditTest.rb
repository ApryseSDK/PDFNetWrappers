#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The sample code shows how to edit the page display list and how to modify graphics state 
# attributes on existing Elements. In particular the sample program strips all images from 
# the page and changes text color to blue. 
#---------------------------------------------------------------------------------------

def ProcessElements(reader, writer, map)
	element = reader.Next()	 # Read page contents
	while !element.nil? do
		type = element.GetType()
		case type
		when Element::E_image
		# remove all images by skipping them
		when Element::E_inline_image	
			# remove all images by skipping them
		when Element::E_path
			# Set all paths to red color.
			gs = element.GetGState()
			gs.SetFillColorSpace(ColorSpace.CreateDeviceRGB())
			gs.SetFillColor(ColorPt.new(1, 0, 0))
			writer.WriteElement(element)
		when Element::E_text	# Process text strings...
			# Set all text to blue color.
			gs = element.GetGState()
			gs.SetFillColorSpace(ColorSpace.CreateDeviceRGB())
			cp = ColorPt.new(0, 0, 1)
			gs.SetFillColor(cp)
			writer.WriteElement(element)
		when Element::E_form	# Recursively process form XObjects
			o = element.GetXObject()
			map[o.GetObjNum()] = o
			writer.WriteElement(element)
		else
			writer.WriteElement(element)
		end
		element = reader.Next()
	end
end

	PDFNet.Initialize()
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	input_filename = "newsletter.pdf"
	output_filename = "newsletter_edited.pdf"
	
	
	# Open the test file
	puts "Opening the input file..."
	doc = PDFDoc.new(input_path + input_filename)
	doc.InitSecurityHandler()
	
	writer = ElementWriter.new()
	reader = ElementReader.new()
	
	itr = doc.GetPageIterator()
	
	while itr.HasNext() do
		page = itr.Current()
		reader.Begin(page)
		writer.Begin(page, ElementWriter::E_replacement, false)
		map1 = {}
		ProcessElements(reader, writer, map1)
		writer.End()
		reader.End()
		
		map2 = {}
		while (not(map1.empty? and map2.empty?)) do
			map1.each do |k, v|
				obj = v
				writer.Begin(obj)
				reader.Begin(obj, page.GetResourceDict())
				ProcessElements(reader, writer, map2)
				reader.End()
				writer.End()

				map1.delete(k)
			end
			if (map1.empty? and not map2.empty?)
				map1.update(map2)
				map2.clear
			end
		end
		itr.Next()
	end
		
	doc.Save(output_path + output_filename, SDFDoc::E_remove_unused)
	doc.Close()
	puts "Done. Result saved in " + output_filename + "..."
	
