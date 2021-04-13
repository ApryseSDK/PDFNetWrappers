#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# This sample project illustrates how to recompress bi-tonal images in an 
# existing PDF document using JBIG2 compression. The sample is not intended 
# to be a generic PDF optimization tool.
#
# You can download the entire document using the following link:
#   http://www.pdftron.com/net/samplecode/data/US061222892.pdf

	PDFNet.Initialize
	
	pdf_doc = PDFDoc.new("../../TestFiles/US061222892-a.pdf")
	pdf_doc.InitSecurityHandler
	
	cos_doc = pdf_doc.GetSDFDoc
	num_objs = cos_doc.XRefSize
	
	i = 1
	while i < num_objs do
		obj = cos_doc.GetObj(i)
		if !obj.nil? and !obj.IsFree and obj.IsStream
			# Process only images
			itr = obj.Find("Subtype")
			if !itr.HasNext or !itr.Value.GetName == "Image"
				i = i + 1
				next
			end
			
			input_image = Image.new(obj)
			# Process only gray-scale images
			if input_image.GetComponentNum != 1
				i = i + 1
				next
			end			

			# Skip images that are already compressed using JBIG2
			itr = obj.Find("Filter")
			if itr.HasNext and itr.Value.IsName and itr.Value.GetName == "JBIG2Decode"
				i = i + 1
				next
			end
			
			filter = obj.GetDecodedStream
			reader = FilterReader.new(filter)
			
			hint_set = ObjSet.new	 # hint to image encoder to use JBIG2 compression
			hint = hint_set.CreateArray
			
			hint.PushBackName("JBIG2")
			hint.PushBackName("Lossless")
			
			new_image = Image.Create(cos_doc, reader, 
						input_image.GetImageWidth, 
						input_image.GetImageHeight, 
						1, 
						ColorSpace.CreateDeviceGray, 
						hint)
			
			new_img_obj = new_image.GetSDFObj
			itr = obj.Find("Decode")
			
			if itr.HasNext
				new_img_obj.Put("Decode", itr.Value)
			end
			itr = obj.Find("ImageMask")
			if itr.HasNext
				new_img_obj.Put("ImageMask", itr.Value)
			end
			itr = obj.Find("Mask")
			if itr.HasNext
				new_img_obj.Put("Mask", itr.Value)
			end
				
			cos_doc.Swap(i, new_img_obj.GetObjNum)
		end
		i = i + 1
	end
			
	pdf_doc.Save("../../TestFiles/Output/US061222892_JBIG2.pdf", SDFDoc::E_remove_unused)
	pdf_doc.Close
