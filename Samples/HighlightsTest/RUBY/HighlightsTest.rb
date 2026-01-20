#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true


# ---------------------------------------------------------------------------------------
# This sample illustrates the basic text highlight capabilities of PDFNet.
# It simulates a full-text search engine that finds all occurrences of the word 'Federal'.
# It then highlights those words on the page.
# 
# Note: The TextSearch class is the preferred solution for searching text within a single
# PDF file. TextExtractor provides search highlighting capabilities where a large number
# of documents are indexed using a 3rd party search engine.
# --------------------------------------------------------------------------------------

	# Relative path to the folder containing test files.
	input_path =  "../../TestFiles/paragraphs_and_tables.pdf"
	output_path = "../../TestFiles/Output/"

	
	# The first step in every application using PDFNet is to initialize the
	# library and set the path to common PDF resources. The library is usually
	# initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
	doc = PDFDoc.new(input_path)
	doc.InitSecurityHandler
	
	page = doc.GetPage(1)
	if page.nil?
		print("page no found")
		PDFNet.Terminate
		exit(1)
	end
		
	txt = TextExtractor.new
	txt.Begin(page) # Read the page
	
	# Do not dehyphenate; that would interfere with character offsets
	dehyphen = false
	# Retrieve the page text
	page_text = txt.GetAsText(dehyphen)

	# Simulating a full-text search engine that finds all occurrences of the word 'Federal'.
	# In a real application, plug in your own search engine here.
	search_text = "Federal"
	char_ranges = []

	ofs = page_text.index(search_text)
	while !ofs.nil?
		cr = CharRange.new
		cr.index = ofs
		cr.length = search_text.length
		char_ranges << cr
		ofs = page_text.index(search_text, ofs + 1)
	end

	# Retrieve Highlights object and apply annotations to the page
	hlts = txt.GetHighlights(char_ranges)
	hlts.Begin(doc)

	while hlts.HasNext()
		# In Ruby bindings, quads are typically returned as an array
		quads = hlts.get_current_quads
		quad_count = quads.length

		(0...quad_count).each do |i|
			q = quads[i]

			x1 = [q.p1.x, q.p2.x, q.p3.x, q.p4.x].min
			x2 = [q.p1.x, q.p2.x, q.p3.x, q.p4.x].max
			y1 = [q.p1.y, q.p2.y, q.p3.y, q.p4.y].min
			y2 = [q.p1.y, q.p2.y, q.p3.y, q.p4.y].max

			highlight = HighlightAnnot.create(doc.get_sdf_doc, Rect.new(x1, y1, x2, y2))
			highlight.refresh_appearance
			page.annot_push_back(highlight)

			puts "[#{'%.2f' % x1}, #{'%.2f' % y1}, #{'%.2f' % x2}, #{'%.2f' % y2}]"
		end

		hlts.next
	end

	doc.Save(output_path + "search_highlights.pdf", SDFDoc::E_linearized)

	doc.Close
	puts "Done."
	
	PDFNet.Terminate
