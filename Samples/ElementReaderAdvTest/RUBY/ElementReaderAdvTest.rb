#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

def ProcessPath(reader, path)
	if path.IsClippingPath
		puts "This is a clipping path"
	end
	
	pathData = path.GetPathData
	data = pathData.GetPoints
	opr = pathData.GetOperators

	opr_index = 0
	opr_end = opr.size
	data_index = 0
	data_end = data.size

	# Use path.GetCTM if you are interested in CTM (current transformation matrix).
	print "Path Data Points := \""
	
	while opr_index < opr_end
		case opr[opr_index].ord
		when PathData::E_moveto
			x1 = data[data_index] 
			data_index = data_index + 1
			y1 = data[data_index]
			data_index = data_index + 1
			puts "M" + x1.to_s + " " + y1.to_s
		when PathData::E_lineto
			x1 = data[data_index] 
			data_index = data_index + 1
			y1 = data[data_index]
			data_index = data_index + 1
			print " L" + x1.to_s + " " + y1.to_s
		when PathData::E_cubicto
			x1 = data[data_index]
			data_index = data_index + 1
			y1 = data[data_index]
			data_index = data_index + 1
			x2 = data[data_index]
			data_index = data_index + 1
			y2 = data[data_index]
			data_index = data_index + 1
			x3 = data[data_index]
			data_index = data_index + 1
			y3 = data[data_index]
			data_index = data_index + 1
			print " C" + x1.to_s + " " + y1.to_s + " " + x2.to_s + 
				" " + y2.to_s + " " + x3.to_s + " " + y3.to_s
		when PathData::E_rect
			x1 = data[data_index]
			data_index = data_index + 1
			y1 = data[data_index]
			data_index = data_index + 1
			w = data[data_index]
			data_index = data_index + 1
			h = data[data_index]
			data_index = data_index + 1
			x2 = x1 + w
			y2 = y1
			x3 = x2
			y3 = y1 + h
			x4 = x1
			y4 = y3
			print "M" + x1.to_s + " " + y1.to_s + " L " + x2.to_s + " " + y2.to_s + " L " + 
				x3.to_s + " " + y3.to_s + " L " + x4.to_s + " " + y4.to_s + " Z"
		when PathData::E_closepath
			puts " Close Path"
		else
			raise "Assert: false"
		end
		opr_index = opr_index + 1
	end
	
	print "\" "
	gs = path.GetGState
	
	# Set Path State 0 (stroke, fill, fill-rule) -----------------------------------
	if path.IsStroked
		puts "Stroke path"
		
		if gs.GetStrokeColorSpace.GetType == ColorSpace::E_pattern
			puts "Path has associated pattern"
		else
			# Get stroke color (you can use PDFNet color conversion facilities)
			# rgb = gs.GetStrokeColorSpace.Convert2RGB(gs.GetStrokeColor)
		end
	else
		# Do not stroke path
	end
		
	if path.IsFilled
		puts "Fill path"
		
		if gs.GetFillColorSpace.GetType == ColorSpace::E_pattern
			puts "Path has associated pattern"
		else
			# rgb = gs.GetFillColorSpace.Convert2RGB(gs.GetFillColor)
		end
	else
		# Do not fill path
	end
	
	# Process any changes in graphics state  ---------------------------------
	gs_itr = reader.GetChangesIterator
	while gs_itr.HasNext do
		case gs_itr.Current
		when GState::E_transform
			# Get transform matrix for this element. Unlike path.GetCTM 
			# that return full transformation matrix gs.GetTransform return 
			# only the transformation matrix that was installed for this element.
			#
			# gs.GetTransform
		when GState::E_line_width
			# gs.GetLineWidth
		when GState::E_line_cap
			# gs.GetLineCap
		when GState::E_line_join
			# gs.GetLineJoin
		when GState::E_flatness
		when GState::E_miter_limit
			# gs.GetMiterLimit
		when GState::E_dash_pattern
			# dashes = gs.GetDashes
			# gs.GetPhase
		when GState::E_fill_color
			if (gs.GetFillColorSpace.GetType == ColorSpace::E_pattern and
				gs.GetFillPattern.GetType != PatternColor::E_shading )
				# process the pattern data
				reader.PatternBegin(true)
				ProcessElements(reader)
				reader.End
			end
		end
		gs_itr.Next
	end
	reader.ClearChangeList
end
	
def ProcessText (page_reader)
	# Begin text element
	puts "Begin Text Block:"
	
	element = page_reader.Next
	
	while !element.nil?
		type = element.GetType
		if type == Element::E_text_end
			# Finish the text block
			puts "End Text Block."
			return
		elsif type == Element::E_text
			gs = element.GetGState
			
			cs_fill = gs.GetFillColorSpace
			fill = gs.GetFillColor
			
			out = cs_fill.Convert2RGB(fill)
			
			cs_stroke = gs.GetStrokeColorSpace
			stroke = gs.GetStrokeColor
			
			font = gs.GetFont
			puts "Font Name: " + font.GetName
			# font.IsFixedWidth
			# font.IsSerif
			# font.IsSymbolic
			# font.IsItalic
			# ... 

			# font_size = gs.GetFontSize
			# word_spacing = gs.GetWordSpacing
			# char_spacing = gs.GetCharSpacing
			# txt = element.GetTextString
			if font.GetType == Font::E_Type3
				# type 3 font, process its data
				itr = element.GetCharIterator
				while itr.HasNext do
					page_reader.Type3FontBegin(itr.Current)
					ProcessElements(page_reader)
					page_reader.End
				end
			else
				text_mtx = element.GetTextMatrix
				
				itr = element.GetCharIterator
				while itr.HasNext do
					char_code = itr.Current.char_code
					if char_code>=32 and char_code<=255	 # Print if in ASCII range...
						a = font.MapToUnicode(char_code)
						print a[0]
					end
						
					pt = Point.new   
					pt.x = itr.Current.x	 # character positioning information
					pt.y = itr.Current.y
					
					# Use element.GetCTM if you are interested in the CTM 
					# (current transformation matrix).
					ctm = element.GetCTM
					
					# To get the exact character positioning information you need to 
					# concatenate current text matrix with CTM and then multiply 
					# relative positioning coordinates with the resulting matrix.
					mtx = ctm.Multiply(text_mtx)
					mtx.Mult(pt)
					itr.Next
				end
			end
			puts ""
		end
		element = page_reader.Next
	end
end
	
def ProcessImage (image)
	image_mask = image.IsImageMask
	interpolate = image.IsImageInterpolate
	width = image.GetImageWidth
	height = image.GetImageHeight
	out_data_sz = width * height * 3
	
	puts "Image: width=\"" + width.to_s + "\"" + " height=\"" + height.to_s
	
	# mtx = image.GetCTM # image matrix (page positioning info)

	# You can use GetImageData to read the raw (decoded) image data
	#image.GetBitsPerComponent	
	#image.GetImageData	# get raw image data
	# .... or use Image2RGB filter that converts every image to RGB format,
	# This should save you time since you don't need to deal with color conversions, 
	# image up-sampling, decoding etc.
	
	img_conv = Image2RGB.new(image)	 # Extract and convert image to RGB 8-bps format
	reader = FilterReader.new(img_conv)

	image_data_out = reader.Read(out_data_sz)
	
	# Note that you don't need to read a whole image at a time. Alternatively
	# you can read a chuck at a time by repeatedly calling reader.Read(buf, buf_sz) 
	# until the function returns 0. 
end

def ProcessElements(reader)
	element = reader.Next	 # Read page contents
	while !element.nil?
		type = element.GetType
		case type
		when Element::E_path	  # Process path data...
			ProcessPath(reader, element)
		when Element::E_text_begin	  # Process text block...
			ProcessText(reader)
		when Element::E_form	# Process form XObjects
			reader.FormBegin
			ProcessElements(reader)
			reader.End
		when Element::E_image	# Process Images
			ProcessImage(element)
		end
		element = reader.Next
	end
end

	PDFNet.Initialize
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Extract text data from all pages in the document
	
	puts "__________________________________________________"
	puts "Extract page element information from all "
	puts "pages in the document."
	

	doc = PDFDoc.new(input_path + "newsletter.pdf")
	doc.InitSecurityHandler
	pgnum = doc.GetPageCount
	page_begin = doc.GetPageIterator
	page_reader = ElementReader.new
	
	itr = page_begin
	while itr.HasNext do	# Read every page
		puts "Page " + itr.Current.GetIndex.to_s + "----------------------------------------"
		page_reader.Begin(itr.Current)
		ProcessElements(page_reader)
		page_reader.End
		itr.Next
	end
	doc.Close
	puts "Done."

