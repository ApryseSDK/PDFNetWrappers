#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#-----------------------------------------------------------------------------------
# This sample illustrates one approach to PDF image extraction 
# using PDFNet.
# 
# Note: Besides direct image export, you can also convert PDF images 
# to GDI+ Bitmap, or extract uncompressed/compressed image data directly 
# using element.GetImageData() (e.g. as illustrated in ElementReaderAdv 
# sample project).
#-----------------------------------------------------------------------------------

$image_counter = 0

# Relative path to the folder containing the test files.
$input_path = "../../TestFiles/"
$output_path = "../../TestFiles/Output/"

def ImageExtract(reader)
	element = reader.Next()
	while !(element.nil?) do
		if (element.GetType() == Element::E_image or
			element.GetType() == Element::E_inline_image)

			$image_counter =$image_counter + 1
			puts "--> Image: " + $image_counter.to_s()
			puts "    Width: " + element.GetImageWidth().to_s()
			puts "    Height: " + element.GetImageHeight().to_s()
			puts "    BPC: " + element.GetBitsPerComponent().to_s()
			
			ctm = element.GetCTM()
			x2 = 1
			y2 = 1
			pt = Point.new(x2, y2)
			point = ctm.Mult(pt)
			puts "    Coords: x1=%.2f, y1=%.2f, x2=%.2f, y2=%.2f" % [ctm.m_h, ctm.m_v, point.x, point.y]
			
			if element.GetType() == Element::E_image
				image = Image.new(element.GetXObject())
				
				fname = "image_extract1_" + $image_counter.to_s()
				
				path = $output_path + fname
				image.Export(path)
				
				#path = $output_path + fname + ".tif"
				#image.ExportAsTiff(path)
				
				#path = $output_path + fname + ".png"
				#image.ExportAsPng(path)
			end
		elsif element.GetType() == Element::E_form
			reader.FormBegin()
			ImageExtract(reader)
			reader.End()	
		end		
		element = reader.Next()
	end
end

	# Initialize PDFNet
	PDFNet.Initialize()	
	
	# Example 1: 
	# Extract images by traversing the display list for 
	# every page. With this approach it is possible to obtain 
	# image positioning information and DPI.
	
	doc = PDFDoc.new($input_path + "newsletter.pdf")
	doc.InitSecurityHandler()
	
	reader = ElementReader.new()
	
	# Read every page
	itr = doc.GetPageIterator()
	while itr.HasNext() do
		reader.Begin(itr.Current())
		ImageExtract(reader)
		reader.End()
		itr.Next()
	end

	doc.Close()

	puts "Done."	
	puts "----------------------------------------------------------------"
	
	# Example 2: 
	# Extract images by scanning the low-level document.
	
	doc = PDFDoc.new($input_path + "newsletter.pdf")
	doc.InitSecurityHandler()
	$image_counter= 0
	
	cos_doc = doc.GetSDFDoc()
	num_objs = cos_doc.XRefSize()
	i = 1
	while i < num_objs do
		obj = cos_doc.GetObj(i)

		if !(obj.nil?) and !(obj.IsFree()) and obj.IsStream()
			# Process only images
			itr = obj.Find("Type")

			if !(itr.HasNext()) or !(itr.Value().GetName() == "XObject")
				i = i + 1
				next
			end
			
			itr = obj.Find("Subtype")
			if !(itr.HasNext()) or !(itr.Value().GetName() == "Image")
				i = i + 1
				next
			end
			
			image = Image.new(obj)
			$image_counter = $image_counter + 1
			puts "--> Image: " + $image_counter.to_s()
			puts "    Width: " + image.GetImageWidth().to_s()
			puts "    Height: " + image.GetImageHeight().to_s()
			puts "    BPC: " + image.GetBitsPerComponent().to_s()
			
			fname = "image_extract2_" + $image_counter.to_s()
				
			path = $output_path + fname
			image.Export(path)
			
			#path = $output_path + fname + ".tif"
			#image.ExportAsTiff(path)
			
			#path = $output_path + fname + ".png"
			#image.ExportAsPng(path)
		end
		i = i + 1
	end
	doc.Close()
	puts "Done."
