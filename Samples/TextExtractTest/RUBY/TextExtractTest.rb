#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

def PrintStyle (style)
    sans_serif_str = ""
    if style.IsSerif()
		sans_serif_str = " sans-serif;"
	end 
    rgb = style.GetColor
    rgb_hex =  "%02X%02X%02X;" % [rgb[0], rgb[1], rgb[2]]
    font_str = '%g' % style.GetFontSize
	print " style=\"font-family:" + style.GetFontName + "; font-size:" + font_str + ";" + sans_serif_str + " color:#" + rgb_hex + "\""
end

def DumpAllText (reader)
	element = reader.Next
	while !element.nil? do
		case element.GetType
		when Element::E_text_begin
			puts "Text Block Begin"
		when Element::E_text_end
			puts "Text Block End"
		when Element::E_text
			bbox = element.GetBBox
			puts "BBox: " + bbox.GetX1.to_s + ", " + bbox.GetY1.to_s + ", " +
				bbox.GetX2.to_s + ", " + bbox.GetY2.to_s
			puts element.GetTextString
		when Element::E_text_new_line
			puts "New Line"
		when Element::E_form
			reader.FormBegin
			DumpAllText(reader)
			reader.End
		end
		element = reader.Next
	end
end

# A utility method used to extract all text content from
# a given selection rectangle. The recnagle coordinates are
# expressed in PDF user/page coordinate system.
def ReadTextFromRect (page, pos, reader)
	reader.Begin(page)
	srch_str = RectTextSearch(reader, pos)
	reader.End
	return srch_str
end

#A helper method for ReadTextFromRect
def RectTextSearch (reader, pos)
	element = reader.Next
	srch_str2 = ""
	while !element.nil? do
		case element.GetType
		when Element::E_text
			bbox = element.GetBBox
			if bbox.IntersectRect(bbox, pos)
				arr = element.GetTextString
				srch_str2 += arr
				srch_str2 += "\n"
			end
		when Element::E_text_new_line
		when Element::E_form
			reader.FormBegin
			srch_str2 += RectTextSearch(reader, pos)
			puts srch_str2
			reader.End
		end
		element = reader.Next
	end
	return srch_str2
end			
	
	PDFNet.Initialize
	
	# Relative path to the folder containing test files.
	input_path =  "../../TestFiles/newsletter.pdf"
	example1_basic = false
	example2_xml = false
	example3_wordlist = false
	example4_advanced = true
	example5_low_level = false
   
	# Sample code showing how to use high-level text extraction APIs.
	doc = PDFDoc.new(input_path)
	doc.InitSecurityHandler
	
	page = doc.GetPage(1)
	if page.nil?
		print("page no found")
	end
		
	txt = TextExtractor.new
	txt.Begin(page) # Read the page
	
	# Example 1. Get all text on the page in a single string.
	# Words will be separated witht space or new line characters.
	if example1_basic
		puts "Word count: " + txt.GetWordCount.to_s
		puts "- GetAsText --------------------------" + txt.GetAsText
		puts "-----------------------------------------------------------"
	end
   
	# Example 2. Get XML logical structure for the page.
	if example2_xml
		text = txt.GetAsXML(TextExtractor::E_words_as_elements | 
					TextExtractor::E_output_bbox | 
					TextExtractor::E_output_style_info)	   
		puts "- GetAsXML  --------------------------" + text
		puts "-----------------------------------------------------------"
	end
		
	
	
	# Example 3. Extract words one by one.
	if example3_wordlist
		word = Word.new
		line = txt.GetFirstLine
		while line.IsValid do
			word = line.GetFirstWord
			while word.IsValid do
				puts word.GetString
				word = word.GetNextWord
			end
			line = line.GetNextLine
		end
		puts "-----------------------------------------------------------"
	end
			

	# Example 4. A more advanced text extraction example. 
	# The output is XML structure containing paragraphs, lines, words, 
	# as well as style and positioning information.
	if example4_advanced
		bbox = Rect.new
		cur_flow_id = -1
		cur_para_id = -1
		
		puts "<PDFText>"
		# For each line on the page...
		line = txt.GetFirstLine
		while line.IsValid do
			word_num = line.GetNumWords
			if word_num == 0
				line = line.GetNextLine			
				next
			end
			word = line.GetFirstWord
			if cur_flow_id != line.GetFlowID
				if cur_flow_id != -1
					if cur_para_id != -1
						cur_para_id = -1
						puts "</Para>"
					end
					puts "</Flow>"
				end
				cur_flow_id = line.GetFlowID
				puts "<Flow id=\"" + cur_flow_id.to_s + "\">"
			end
					
			if cur_para_id != line.GetParagraphID
				if cur_para_id != -1
					puts "</Para>"
				end
				cur_para_id= line.GetParagraphID
				puts "<Para id=\"" + cur_para_id.to_s + "\">"
			end
				
			bbox = line.GetBBox
			line_style = line.GetStyle
			print "<Line box=\"%.2f, %.2f, %.2f, %.2f\""% [bbox.GetX1(), bbox.GetY1(), bbox.GetX2(), bbox.GetY2()]
			PrintStyle (line_style)
			print " cur_num=\"" + "%d" % line.GetCurrentNum + "\"" + ">\n"
			
			# For each word in the line...
			word = line.GetFirstWord
			while word.IsValid do
				# Output the bounding box for the word
				bbox = word.GetBBox
				print "<Word box=\"%.2f, %.2f, %.2f, %.2f\""% [bbox.GetX1(), bbox.GetY1(), bbox.GetX2(), bbox.GetY2()]
				print " cur_num=\"" + "%d" % word.GetCurrentNum + "\"";
				sz = word.GetStringLen
				if sz == 0
					word = word.GetNextWord				
					next
				end
				# If the word style is different from the parent style, output the new style.
				s = word.GetStyle
				if s != line_style
					PrintStyle (s)
				end
				print ">" + word.GetString + "</Word>\n"
				word = word.GetNextWord
			end
			puts "</Line>"
			line = line.GetNextLine
		end
			
		if cur_flow_id != -1
			if cur_para_id != -1
				cur_para_id = -1
				puts "</Para>"
			end
			puts "</Flow>"
		end
		
		txt.Destroy
		doc.Close			
		puts "</PDFText>"
	end

	# Sample code showing how to use low-level text extraction APIs.
	if example5_low_level
		doc = PDFDoc.new(input_path)
		doc.InitSecurityHandler

		# Example 1. Extract all text content from the document
		
		reader = ElementReader.new
		itr = doc.GetPageIterator
		while itr.HasNext do
			reader.Begin(itr.Current)
			DumpAllText(reader)
			reader.End
			itr.Next
		end
			
		# Example 2. Extract text content based on the 
		# selection rectangle.
		
		puts "----------------------------------------------------"
		puts "Extract text based on the selection rectangle."
		puts "----------------------------------------------------"
		
		itr = doc.GetPageIterator
		first_page = itr.Current
		s1 = ReadTextFromRect(first_page, Rect.new(27, 392, 563, 534), reader)
		puts "Field 1: " + s1

		s1 = ReadTextFromRect(first_page, Rect.new(28, 551, 106, 623), reader);
		puts "Field 2: " + s1

		s1 = ReadTextFromRect(first_page, Rect.new(208, 550, 387, 621), reader);
		puts "Field 3: " + s1
		
		doc.Close
		puts "Done."
	end
