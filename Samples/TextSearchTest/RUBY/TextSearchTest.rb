#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# This sample illustrates the basic text search capabilities of PDFNet.

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

	# Initialize PDFNet
	PDFNet.Initialize
	doc = PDFDoc.new(input_path + "credit card numbers.pdf")
	doc.InitSecurityHandler
	
	txt_search = TextSearch.new
	mode = TextSearch::E_whole_word | TextSearch::E_page_stop
	
	pattern = "joHn sMiTh"
	
	# call Begin method to initialize the text search.
	txt_search.Begin(doc, pattern, mode)

	step = 0

	# call Run method iteratively to find all matching instances.
	while true do
		searchResult = txt_search.Run
		if searchResult.IsFound
			case step
			when 0
				# step 0: found "John Smith"
				# note that, here, 'ambient_string' and 'hlts' are not written to, 
				# as 'e_ambient_string' and 'e_highlight' are not set.
				
				puts searchResult.GetMatch + "'s credit card number is: "
				
				# now switch to using regular expressions to find John's credit card number
				mode = txt_search.GetMode
				mode |= TextSearch::E_reg_expression | TextSearch::E_highlight
				txt_search.SetMode(mode)
				pattern = "\\d{4}-\\d{4}-\\d{4}-\\d{4}"	 #or "(\\d{4}-){3}\\d{4}"
				txt_search.SetPattern(pattern)
				step = step + 1
			when 1
				# step 1: found John's credit card number
				puts "  " + searchResult.GetMatch
				
				# note that, here, 'hlts' is written to, as 'e_highligh' has been set.
				# output the highlight info of the credit card number
				hlts = searchResult.GetHighlights
				hlts.Begin(doc)
				while hlts.HasNext
					puts "The current highlight is from page: " + hlts.GetCurrentPageNumber.to_s
					hlts.Next
				end
					
				# see if there is an AMEX card number
				pattern = "\\d{4}-\\d{6}-\\d{5}"
				txt_search.SetPattern(pattern)
				
				step = step + 1
			when 2
				# found an AMEX card number
				puts "\nThere is an AMEX card number:\n  " + searchResult.GetMatch
				
				# change mode to find the owner of the credit card; supposedly, the owner's
				# name proceeds the number
				mode = txt_search.GetMode
				mode |= TextSearch::E_search_up
				txt_search.SetMode(mode)
				pattern = "[A-z]++ [A-z]++"
				txt_search.SetPattern(pattern)
				step = step + 1
			when 3
				# found the owner's name of the AMEX card
				puts "Is the owner's name:\n  " + searchResult.GetMatch + "?"
				
				# add a link annotation based on the location of the found instance
				hlts = searchResult.GetHighlights
				hlts.Begin(doc)
				
				while hlts.HasNext do
					cur_page = doc.GetPage(hlts.GetCurrentPageNumber)
					quadsInfo = hlts.GetCurrentQuads

					i = 0
					while i < quadsInfo.size do
						q = quadsInfo[i]
						# assume each quad is an axis-aligned rectangle						
						x1 = [q.p1.x, q.p2.x, q.p3.x, q.p4.x].min
						x2 = [q.p1.x, q.p2.x, q.p3.x, q.p4.x].max
						y1 = [q.p1.y, q.p2.y, q.p3.y, q.p4.y].min
						y2 = [q.p1.y, q.p2.y, q.p3.y, q.p4.y].max
						hyper_link = Link.Create(doc.GetSDFDoc, Rect.new(x1, y1, x2, y2), Action.CreateURI(doc.GetSDFDoc, "http://www.pdftron.com"))
						cur_page.AnnotPushBack(hyper_link)
						i = i + 1
					end			
					hlts.Next
				end
				doc.Save(output_path + "credit card numbers_linked.pdf", SDFDoc::E_linearized)
				break
			end
		elsif code == TextSearch::E_page
		else
			break
		end
	end	
	doc.Close
