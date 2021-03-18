#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample shows how to add new content (or watermark) PDF pages
# using 'pdftron.PDF.Stamper' utility class. 
#
# Stamper can be used to PDF pages with text, images, or with other PDF content 
# in only a few lines of code. Although Stamper is very simple to use compared 
# to ElementBuilder/ElementWriter it is not as powerful or flexible. In case you 
# need full control over PDF creation use ElementBuilder/ElementWriter to add 
# new content to existing PDF pages as shown in the ElementBuilder sample project.
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"
input_filename = "newsletter"

	# Initialize PDFNet
	PDFNet.Initialize
	
	#--------------------------------------------------------------------------------
	# Example 1) Add text stamp to all pages, then remove text stamp from odd pages. 
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	s = Stamper.new(Stamper::E_relative_scale, 0.5, 0.5)
	
	s.SetAlignment(Stamper::E_horizontal_center, Stamper::E_vertical_center)
	red = ColorPt.new(1, 0, 0) # set text color to red
	s.SetFontColor(red)
	s.StampText(doc, "If you are reading this\nthis is an even page", PageSet.new(1, doc.GetPageCount))
	# delete all text stamps in odd pages
	Stamper.DeleteStamps(doc, PageSet.new(1, doc.GetPageCount, PageSet::E_odd))
	
	doc.Save(output_path + input_filename + ".ex1.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 2) Add Image stamp to first 2 pages. 
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	s = Stamper.new(Stamper::E_relative_scale, 0.05, 0.05)
	img = Image.Create(doc.GetSDFDoc, input_path + "peppers.jpg")
	s.SetSize(Stamper::E_relative_scale, 0.5, 0.5)
	
	# set position of the image to the center, left of PDF pages
	s.SetAlignment(Stamper::E_horizontal_left, Stamper::E_vertical_center)
	pt = ColorPt.new(0, 0, 0, 0)
	s.SetFontColor(pt)
	s.SetRotation(180)
	s.SetAsBackground(false)
	# only stamp first 2 pages
	ps = PageSet.new(1, 2)
	s.StampImage(doc, img, ps)
	
	doc.Save(output_path + input_filename + ".ex2.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 3) Add Page stamp to all pages. 
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	
	fish_doc = PDFDoc.new(input_path + "fish.pdf")
	fish_doc.InitSecurityHandler
	s = Stamper.new(Stamper::E_relative_scale, 0.5, 0.5)
	src_page = fish_doc.GetPage(1)
	page_one_crop = src_page.GetCropBox
	# set size of the image to 10% of the original while keep the old aspect ratio
	s.SetSize(Stamper::E_absolute_size, page_one_crop.Width * 0.1, -1)
	s.SetOpacity(0.4)
	s.SetRotation(-67)
	# put the image at the bottom right hand corner
	s.SetAlignment(Stamper::E_horizontal_right, Stamper::E_vertical_bottom)
	ps = PageSet.new(1, doc.GetPageCount)
	s.StampPage(doc, src_page, ps)
	doc.Save(output_path + input_filename + ".ex3.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 4) Add Image stamp to first 20 odd pages.
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	
	s = Stamper.new(Stamper::E_absolute_size, 20, 20)
	s.SetOpacity(1)
	s.SetRotation(45)
	s.SetAsBackground(true)
	s.SetPosition(30, 40)
	img = Image.Create(doc.GetSDFDoc, input_path + "peppers.jpg")
	ps = PageSet.new(1, 20, PageSet::E_odd)
	s.StampImage(doc, img, ps)
	
	doc.Save(output_path + input_filename + ".ex4.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 5) Add text stamp to first 20 even pages
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	s = Stamper.new(Stamper::E_relative_scale, 0.05, 0.05)
	s.SetPosition(0, 0)
	s.SetOpacity(0.7)
	s.SetRotation(90)
	s.SetSize(Stamper::E_font_size, 80, -1)
	s.SetTextAlignment(Stamper::E_align_center)
	ps = PageSet.new(1, 20, PageSet::E_even)
	s.StampText(doc, "Goodbye\nMoon", ps)
	
	doc.Save(output_path + input_filename + ".ex5.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 6) Add first page as stamp to all even pages
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	
	fish_doc = PDFDoc.new(input_path + "fish.pdf");
	fish_doc.InitSecurityHandler
	
	s = Stamper.new(Stamper::E_relative_scale, 0.3, 0.3)
	s.SetOpacity(1)
	s.SetRotation(270)
	s.SetAsBackground(true)
	s.SetPosition(0.5, 0.5, true)
	s.SetAlignment(Stamper::E_horizontal_left, Stamper::E_vertical_bottom)
	page_one = fish_doc.GetPage(1)
	ps = PageSet.new(1, doc.GetPageCount, PageSet::E_even)
	s.StampPage(doc, page_one, ps)
	
	doc.Save(output_path + input_filename + ".ex6.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 7) Add image stamp at top left corner in every pages
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	
	s = Stamper.new(Stamper::E_relative_scale, 0.1, 0.1)
	s.SetOpacity(0.8)
	s.SetRotation(135)
	s.SetAsBackground(false)
	s.ShowsOnPrint(false)
	s.SetAlignment(Stamper::E_horizontal_left, Stamper::E_vertical_top)
	s.SetPosition(10, 10)
	img = Image.Create(doc.GetSDFDoc, input_path + "peppers.jpg")
	ps = PageSet.new(1, doc.GetPageCount, PageSet::E_all)
	s.StampImage(doc, img, ps)
	doc.Save(output_path + input_filename + ".ex7.pdf", SDFDoc::E_linearized)
	doc.Close

	#--------------------------------------------------------------------------------
	# Example 8) Add Text stamp to first 2 pages, and image stamp to first page.
	#          Because text stamp is set as background, the image is top of the text
	#          stamp. Text stamp on the first page is not visible.
	
	doc = PDFDoc.new(input_path + input_filename + ".pdf")
	doc.InitSecurityHandler
	
	s = Stamper.new(Stamper::E_relative_scale, 0.07, -0.1)
	s.SetAlignment(Stamper::E_horizontal_right, Stamper::E_vertical_bottom)
	s.SetAlignment(Stamper::E_horizontal_center, Stamper::E_vertical_top)
	s.SetFont(Font.Create(doc.GetSDFDoc, Font::E_courier, true))
	red = ColorPt.new(1, 0, 0) 
	s.SetFontColor(red) # set text color to red
	s.SetTextAlignment(Stamper::E_align_right)
	s.SetAsBackground(true) # set text stamp as background
	ps = PageSet.new(1, 2)
	s.StampText(doc, "This is a title!", ps)
	
	img = Image.Create(doc.GetSDFDoc, input_path + "peppers.jpg")
	s.SetAsBackground(false)    # set image stamp as foreground
	first_page_ps = PageSet.new(1)
	s.StampImage(doc, img, first_page_ps)

	doc.Save(output_path + input_filename + ".ex8.pdf", SDFDoc::E_linearized)
	doc.Close
