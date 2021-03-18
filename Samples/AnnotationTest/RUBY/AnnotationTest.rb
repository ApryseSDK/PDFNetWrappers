#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

$output_path = "../../TestFiles/Output/"
$input_path = "../../TestFiles/"

def FloatToStr(float)
	if float.to_i() == float.to_f()
		return float.to_i().to_s()
	else
		return float.to_f().to_s()
	end
end

def AnnotationHighLevelAPI(doc)
	# The following code snippet traverses all annotations in the document
	puts "Traversing all annotations in the document..."
	page_num = 1
	itr = doc.GetPageIterator()
	
	while itr.HasNext() do
		puts "Page " + page_num.to_s() + ": "
		page_num = page_num + 1
		page = itr.Current()
		num_annots = page.GetNumAnnots()
		i = 0
		while i < num_annots do
			annot = page.GetAnnot(i)
			if !(annot.IsValid())
				i = i + 1
				next
			end
			puts "Annot Type: " + annot.GetSDFObj().Get("Subtype").Value().GetName()
			
			bbox = annot.GetRect()
			puts "  Position: " + FloatToStr(bbox.x1.to_s()) + 
				  ", " + FloatToStr(bbox.y1.to_s()) +
				  ", " + FloatToStr(bbox.x2.to_s()) + 
				  ", " + FloatToStr(bbox.y2.to_s())
			
			type = annot.GetType()			
			case type
			when Annot::E_Link
				link = Link.new(annot)
				action = link.GetAction()
				if !(action.IsValid())
					i = i + 1
					next
				end
				if action.GetType() == Action::E_GoTo
					dest = action.GetDest()
					if !(dest.IsValid())
						puts "  Destination is not valid."
					else
						page_n = dest.GetPage().GetIndex()
						puts "  Links to: page number " + page_n.to_s() + " in this document"
					end
				elsif action.GetType() == Action::E_URI
					uri = action.GetSDFObj().Get("URI").Value().GetAsPDFText()
					puts "  Links to: " + uri.to_s()
				end
			when Annot::E_Widget
			when Annot::E_FileAttachment
			end
			i = i + 1
		end
		itr.Next()
	end

	# Use the high-level API to create new annotations.		
	first_page = doc.GetPage(1)
	
	# Create a hyperlink...
	hyperlink = Link.Create(doc.GetSDFDoc(), Rect.new(85, 570, 503, 524), Action.CreateURI(doc.GetSDFDoc(), "http://www.pdftron.com"))
	first_page.AnnotPushBack(hyperlink)
	
	# Create an intra-document link...
	goto_page_3 = Action.CreateGoto(Destination.CreateFitH(doc.GetPage(3), 0))
	link = Link.Create(doc.GetSDFDoc(), Rect.new(85, 458, 503, 502), goto_page_3)
	link.SetColor(ColorPt.new(0, 0, 1))
	
	# Add the new annotation to the first page
	first_page.AnnotPushBack(link) 
	
	# Create a stamp annotation ...
	stamp = RubberStamp.Create(doc.GetSDFDoc(), Rect.new(30, 30, 300, 200))
	stamp.SetIcon("Draft")
	first_page.AnnotPushBack(stamp)

	# Create a file attachment annotation (embed the 'peppers.jpg').
	file_attach = FileAttachment.Create(doc.GetSDFDoc(), Rect.new(80, 280, 108, 320), $input_path + "peppers.jpg")
	first_page.AnnotPushBack(file_attach)

	ink = Ink.Create(doc.GetSDFDoc(), Rect.new(110, 10, 300, 200))
	pt3 = Point.new(110, 10)
	pt3.x = 110 
	pt3.y = 10
	ink.SetPoint(0, 0, pt3)
	pt3.x = 150 
	pt3.y = 50
	ink.SetPoint(0, 1, pt3)
	pt3.x = 190 
	pt3.y = 60
	ink.SetPoint(0, 2, pt3)
	pt3.x = 180 
	pt3.y = 90
	ink.SetPoint(1, 0, pt3)
	pt3.x = 190 
	pt3.y = 95
	ink.SetPoint(1, 1, pt3)
	pt3.x = 200 
	pt3.y = 100
	ink.SetPoint(1, 2, pt3)
	pt3.x = 166 
	pt3.y = 86
	ink.SetPoint(2, 0, pt3)
	pt3.x = 196 
	pt3.y = 96
	ink.SetPoint(2, 1, pt3)
	pt3.x = 221 
	pt3.y = 121
	ink.SetPoint(2, 2, pt3)
	pt3.x = 288 
	pt3.y = 188
	ink.SetPoint(2, 3, pt3)
	ink.SetColor(ColorPt.new(0, 1, 1), 3)
	first_page.AnnotPushBack(ink)
end

def AnnotationLowLevelAPI(doc)
	itr = doc.GetPageIterator()
	page = itr.Current()
	annots = page.GetAnnots()
	
	if annots.nil?
		# If there are no annotations, create a new annotation 
		# array for the page.
		annots = doc.CreateIndirectArray()
		page.GetSDFObj().Put("Annots", annots)
	end

	# Create a Text annotation
	annot = doc.CreateIndirectDict()
	annot.PutName("Subtype", "Text")
	annot.PutBool("Open", true)
	annot.PutString("Contents", "The quick brown fox ate the lazy mouse.")
	annot.PutRect("Rect", 266, 116, 430, 204)

	# Insert the annotation in the page annotation array
	annots.PushBack(annot)   
	
	# Create a Link annotation
	link1 = doc.CreateIndirectDict()
	link1.PutName("Subtype", "Link")
	dest = Destination.CreateFit(doc.GetPage(2))
	link1.Put("Dest", dest.GetSDFObj())
	link1.PutRect("Rect", 85, 705, 503, 661)
	annots.PushBack(link1)

	# Create another Link annotation
	link2 = doc.CreateIndirectDict()
	link2.PutName("Subtype", "Link")
	dest2 = Destination.CreateFit((doc.GetPage(3)))
	link2.Put("Dest", dest2.GetSDFObj())
	link2.PutRect("Rect", 85, 638, 503, 594)
	annots.PushBack(link2)
	
	# Note that PDFNet API can be used to modify existing annotations. 
	# In the following example we will modify the second link annotation 
	# (link2) so that it points to the 10th page. We also use a different 
	# destination page fit type.
	
	# link2 = annots.GetAt(annots.Size()-1)
	link2.Put("Dest", Destination.CreateXYZ(doc.GetPage(10), 100, 792-70, 10).GetSDFObj())
	
	# Create a third link annotation with a hyperlink action (all other 
	# annotation types can be created in a similar way)
	link3 = doc.CreateIndirectDict()
	link3.PutName("Subtype", "Link")
	link3.PutRect("Rect", 85, 570, 503, 524)
	
	# Create a URI action 
	action = link3.PutDict("A")
	action.PutName("S", "URI")
	action.PutString("URI", "http://www.pdftron.com")
	
	annots.PushBack(link3)
end
	
def CreateTestAnnots(doc)
	ew = ElementWriter.new()
	eb = ElementBuilder.new()
	
	first_page = doc.PageCreate(Rect.new(0, 0, 600, 600))
	doc.PagePushBack(first_page)
	ew.Begin(first_page, ElementWriter::E_overlay, false )   # begin writing to this page
	ew.End()	# save changes to the current page
	
	# Test of a free text annotation.
	txtannot = FreeText.Create( doc.GetSDFDoc(), Rect.new(10, 400, 160, 570)  )
	txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out " +
						  "of the air by freezing it with an angry glare." +
						  "\n\nAha!\n\nAnd there was much rejoicing!"	)
	txtannot.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 1, 10, 20 ), false )
	txtannot.SetQuaddingFormat(0)
	first_page.AnnotPushBack(txtannot)
	txtannot.RefreshAppearance()
	
	txtannot = FreeText.Create( doc.GetSDFDoc(), Rect.new(100, 100, 350, 500)  )
	txtannot.SetContentRect( Rect.new( 200, 200, 350, 500 ) )
	txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air " +
				"by freezing it with an angry glare." +
				"\n\nAha!\n\nAnd there was much rejoicing!")
	txtannot.SetCalloutLinePoints( Point.new(200,300), Point.new(150,290), Point.new(110,110) )
	txtannot.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 1, 10, 20 ), false )
	txtannot.SetEndingStyle( LineAnnot::E_ClosedArrow )
	txtannot.SetColor( ColorPt.new( 0, 1, 0 ) )
	txtannot.SetQuaddingFormat(1)
	first_page.AnnotPushBack(txtannot)
	txtannot.RefreshAppearance()
	
	txtannot = FreeText.Create(doc.GetSDFDoc(), Rect.new(400, 10, 550, 400))	
	txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air " +
				"by freezing it with an angry glare." +
				"\n\nAha!\n\nAnd there was much rejoicing!")
	txtannot.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 1, 10, 20 ), false )
	txtannot.SetColor( ColorPt.new( 0, 0, 1 ) )
	txtannot.SetOpacity( 0.2 )
	txtannot.SetQuaddingFormat(2)
	first_page.AnnotPushBack(txtannot)
	txtannot.RefreshAppearance()
	
	page= doc.PageCreate(Rect.new(0, 0, 600, 600))
	doc.PagePushBack(page)
	ew.Begin(page, ElementWriter::E_overlay, false )	# begin writing to this page
	eb.Reset()	# Reset the GState to default
	ew.End()	# save changes to the current page
	
	# Create a Line annotation...
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(250, 250, 400, 400))
	line.SetStartPoint( Point.new(350, 270 ) )
	line.SetEndPoint( Point.new(260,370) )
	line.SetStartStyle(LineAnnot::E_Square)
	line.SetEndStyle(LineAnnot::E_Circle)
	line.SetColor(ColorPt.new(0.3, 0.5, 0), 3)
	line.SetContents( "Dashed Captioned" )
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.SetBorderStyle( BorderStyle.new( BorderStyle::E_dashed, 2, 0, 0, [2.0, 2.0] ) )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(347, 377, 600, 600))
	line.SetStartPoint( Point.new(385, 410 ) )
	line.SetEndPoint( Point.new(540,555) )
	line.SetStartStyle(LineAnnot::E_Circle)
	line.SetEndStyle(LineAnnot::E_OpenArrow)
	line.SetColor(ColorPt.new(1, 0, 0), 3)
	line.SetInteriorColor(ColorPt.new(0, 1, 0), 3)
	line.SetContents( "Inline Caption" )
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Inline )
	line.SetLeaderLineExtensionLength( -4 )
	line.SetLeaderLineLength( -12 )
	line.SetLeaderLineOffset( 2 )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(10, 400, 200, 600))
	line.SetStartPoint( Point.new(25, 426 ) )
	line.SetEndPoint( Point.new(180,555) )
	line.SetStartStyle(LineAnnot::E_Circle)
	line.SetEndStyle(LineAnnot::E_Square)
	line.SetColor(ColorPt.new(0, 0, 1), 3)
	line.SetInteriorColor(ColorPt.new(1, 0, 0), 3)
	line.SetContents("Offset Caption")
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.SetTextHOffset( -60 )
	line.SetTextVOffset( 10 )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(200, 10, 400, 70))
	line.SetStartPoint( Point.new(220, 25 ) )
	line.SetEndPoint( Point.new(370,60) )
	line.SetStartStyle(LineAnnot::E_Butt)
	line.SetEndStyle(LineAnnot::E_OpenArrow)
	line.SetColor(ColorPt.new(0, 0, 1), 3)
	line.SetContents( "Regular Caption" )
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(200, 70, 400, 130))
	line.SetStartPoint( Point.new(220, 111 ) )
	line.SetEndPoint( Point.new(370,78) )
	line.SetStartStyle(LineAnnot::E_Circle)
	line.SetEndStyle(LineAnnot::E_Diamond)
	line.SetContents( "Circle to Diamond" )
	line.SetColor(ColorPt.new(0, 0, 1), 3)
	line.SetInteriorColor(ColorPt.new(0, 1, 0), 3)
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new(10, 100, 160, 200))
	line.SetStartPoint( Point.new(15, 110 ) )
	line.SetEndPoint( Point.new(150, 190) )
	line.SetStartStyle(LineAnnot::E_Slash)
	line.SetEndStyle(LineAnnot::E_ClosedArrow)
	line.SetContents( "Slash to CArrow" )
	line.SetColor(ColorPt.new(1, 0, 0), 3)
	line.SetInteriorColor(ColorPt.new(0, 1, 1), 3)
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new( 270, 270, 570, 433 ))
	line.SetStartPoint( Point.new(300, 400 ) )
	line.SetEndPoint( Point.new(550, 300) )
	line.SetStartStyle(LineAnnot::E_RClosedArrow)
	line.SetEndStyle(LineAnnot::E_ROpenArrow)
	line.SetContents( "ROpen & RClosed arrows" )
	line.SetColor(ColorPt.new(0, 0, 1), 3)
	line.SetInteriorColor(ColorPt.new(0, 1, 0), 3)
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.RefreshAppearance()
	page.AnnotPushBack(line)

	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new( 195, 395, 205, 505 ))
	line.SetStartPoint( Point.new(200, 400 ) )
	line.SetEndPoint( Point.new(200, 500) )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new( 55, 299, 150, 301 ))
	line.SetStartPoint( Point.new(55, 300 ) )
	line.SetEndPoint( Point.new(155, 300) )
	line.SetStartStyle(LineAnnot::E_Circle)
	line.SetEndStyle(LineAnnot::E_Circle)
	line.SetContents( "Caption that's longer than its line." )
	line.SetColor(ColorPt.new(1, 0, 1), 3)
	line.SetInteriorColor(ColorPt.new(0, 1, 0), 3)
	line.SetShowCaption(true)
	line.SetCaptionPosition( LineAnnot::E_Top )
	line.RefreshAppearance()
	page.AnnotPushBack(line)
	
	line=LineAnnot.Create(doc.GetSDFDoc(), Rect.new( 300, 200, 390, 234 ))
	line.SetStartPoint( Point.new(310, 210 ) )
	line.SetEndPoint( Point.new(380, 220) )
	line.SetColor(ColorPt.new(0, 0, 0), 3)
	line.RefreshAppearance()
	page.AnnotPushBack(line)

	page3 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page3)	# begin writing to the page
	ew.End()	# save changes to the current page
	doc.PagePushBack(page3)

	circle=Circle.Create(doc.GetSDFDoc(), Rect.new( 300, 300, 390, 350 ))
	circle.SetColor(ColorPt.new(0, 0, 0), 3)
	circle.RefreshAppearance()
	page3.AnnotPushBack(circle)
	
	circle=Circle.Create(doc.GetSDFDoc(), Rect.new( 100, 100, 200, 200 ))
	circle.SetColor(ColorPt.new(0, 1, 0), 3)
	circle.SetInteriorColor(ColorPt.new(0, 0, 1), 3)
	circle.SetBorderStyle( BorderStyle.new( BorderStyle::E_dashed, 3, 0, 0, [2, 4] ) )
	circle.SetPadding( 2 )
	circle.RefreshAppearance()
	page3.AnnotPushBack(circle)

	sq = Square.Create( doc.GetSDFDoc(), Rect.new(10,200, 80, 300 ) )
	sq.SetColor(ColorPt.new(0, 0, 0), 3)
	sq.RefreshAppearance()
	page3.AnnotPushBack( sq )

	sq = Square.Create( doc.GetSDFDoc(), Rect.new(500,200, 580, 300 ) )
	sq.SetColor(ColorPt.new(1, 0, 0), 3)
	sq.SetInteriorColor(ColorPt.new(0, 1, 1), 3)
	sq.SetBorderStyle( BorderStyle.new( BorderStyle::E_dashed, 6, 0, 0, [4, 2] ) )
	sq.SetPadding( 4 )
	sq.RefreshAppearance()
	page3.AnnotPushBack( sq )
	
	poly = Polygon.Create(doc.GetSDFDoc(), Rect.new(5, 500, 125, 590))
	poly.SetColor(ColorPt.new(1, 0, 0), 3)
	poly.SetInteriorColor(ColorPt.new(1, 1, 0), 3)
	poly.SetVertex(0, Point.new(12,510) )
	poly.SetVertex(1, Point.new(100,510) )
	poly.SetVertex(2, Point.new(100,555) )
	poly.SetVertex(3, Point.new(35,544) )
	poly.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 4, 0, 0 ) )
	poly.SetPadding( 4 )
	poly.RefreshAppearance()
	page3.AnnotPushBack( poly )
	
	poly = PolyLine.Create(doc.GetSDFDoc(), Rect.new(400, 10, 500, 90))
	poly.SetColor(ColorPt.new(1, 0, 0), 3)
	poly.SetInteriorColor(ColorPt.new(0, 1, 0), 3)
	poly.SetVertex(0, Point.new(405,20) )
	poly.SetVertex(1, Point.new(440,40) )
	poly.SetVertex(2, Point.new(410,60) )
	poly.SetVertex(3, Point.new(470,80) )
	poly.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 2, 0, 0 ) )
	poly.SetPadding( 4 )
	poly.SetStartStyle( LineAnnot::E_RClosedArrow )
	poly.SetEndStyle( LineAnnot::E_ClosedArrow )
	poly.RefreshAppearance()
	page3.AnnotPushBack( poly )

	lk = Link.Create( doc.GetSDFDoc(), Rect.new(5,5,55,24) )
	lk.RefreshAppearance()
	page3.AnnotPushBack( lk )

	page4 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page4)	# begin writing to the page
	ew.End()  # save changes to the current page
	doc.PagePushBack(page4)
	
	ew.Begin( page4 )
	font = Font.Create(doc.GetSDFDoc(), Font::E_helvetica)
	element = eb.CreateTextBegin( font, 16 )
	element.SetPathFill(true)
	ew.WriteElement(element)
	element = eb.CreateTextRun( "Some random text on the page", font, 16 )
	element.SetTextMatrix(1, 0, 0, 1, 100, 500 )
	ew.WriteElement(element)
	ew.WriteElement( eb.CreateTextEnd() )
	ew.End()

	hl = HighlightAnnot.Create( doc.GetSDFDoc(), Rect.new(100,490,150,515) )
	hl.SetColor( ColorPt.new(0,1,0), 3 )
	hl.RefreshAppearance()
	page4.AnnotPushBack( hl )

	sq = Squiggly.Create( doc.GetSDFDoc(), Rect.new(100,450,250,600) )
	sq.SetQuadPoint( 0, QuadPoint.new( Point.new(122,455), Point.new(240, 545), Point.new(230, 595), Point.new(101,500 ) ) )
	sq.RefreshAppearance()
	page4.AnnotPushBack( sq )

	cr = Caret.Create( doc.GetSDFDoc(), Rect.new(100,40,129,69) )
	cr.SetColor( ColorPt.new(0,0,1), 3 )
	cr.SetSymbol( "P" )
	cr.RefreshAppearance()
	page4.AnnotPushBack( cr )
	
	page5 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page5)	# begin writing to the page
	ew.End()  # save changes to the current page
	doc.PagePushBack(page5)
	fs = FileSpec.Create( doc.GetSDFDoc(), ($input_path + "butterfly.png"), false )
	page6 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page6)	# begin writing to the page
	ew.End()  # save changes to the current page
	doc.PagePushBack(page6)
	
		
	txt = Text.Create( doc.GetSDFDoc(), Rect.new( 10, 20, 30, 40 ) )
	txt.SetIcon( "UserIcon" )
	txt.SetContents( "User defined icon, unrecognized by appearance generator" )
	txt.SetColor( ColorPt.new(0,1,0) )
	txt.RefreshAppearance()
	page6.AnnotPushBack( txt )
	
	ink = Ink.Create( doc.GetSDFDoc(), Rect.new( 100, 400, 200, 550 ) )
	ink.SetColor( ColorPt.new(0,0,1) )
	ink.SetPoint( 1, 3, Point.new( 220, 505) )
	ink.SetPoint( 1, 0, Point.new( 100, 490) )
	ink.SetPoint( 0, 1, Point.new( 120, 410) )
	ink.SetPoint( 0, 0, Point.new( 100, 400) )
	ink.SetPoint( 1, 2, Point.new( 180, 490) )
	ink.SetPoint( 1, 1, Point.new( 140, 440) )		
	ink.SetBorderStyle( BorderStyle.new( BorderStyle::E_solid, 3, 0, 0  ) )
	ink.RefreshAppearance()
	page6.AnnotPushBack( ink )
	
	page7 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page7)	# begin writing to the page
	ew.End()  # save changes to the current page
	doc.PagePushBack(page7)
	
	snd = Sound.Create( doc.GetSDFDoc(), Rect.new( 100, 500, 120, 520 ) )
	snd.SetColor(  ColorPt.new(1,1,0) )
	snd.SetIcon( Sound::E_Speaker )
	snd.RefreshAppearance()
	page7.AnnotPushBack( snd )
	
	snd = Sound.Create( doc.GetSDFDoc(), Rect.new( 200, 500, 220, 520 ) )
	snd.SetColor(  ColorPt.new(1,1,0) )
	snd.SetIcon( Sound::E_Mic )
	snd.RefreshAppearance()
	page7.AnnotPushBack( snd )
	
	page8 = doc.PageCreate(Rect.new(0, 0, 600, 600))
	ew.Begin(page8)	# begin writing to the page
	ew.End()	# save changes to the current page
	doc.PagePushBack(page8)
	
	ipage = 0
	while ipage<2 do
		px = 5
		py = 520
		istamp = RubberStamp::E_Approved
		while istamp <= RubberStamp::E_Draft do
			st = RubberStamp.Create(doc.GetSDFDoc(), Rect.new(1,1,100,100))
			st.SetIcon( istamp )
			st.SetContents( st.GetIconName() )
			st.SetRect( Rect.new(px, py, px+100, py+25 ) )
			py -= 100
			if py < 0
				py = 520
				px+=200
			end
			if ipage == 0
				#page7.AnnotPushBack( st )
			else
				page8.AnnotPushBack( st )
				st.RefreshAppearance()
			end
			istamp = istamp + 1
		end
		ipage = ipage + 1
	end
	
	st = RubberStamp.Create( doc.GetSDFDoc(), Rect.new(400,5,550,45) )
	st.SetIcon( "UserStamp" )
	st.SetContents( "User defined stamp" )
	page8.AnnotPushBack( st )
	st.RefreshAppearance()
end

	PDFNet.Initialize()
	
	doc = PDFDoc.new($input_path + "numbered.pdf")
	doc.InitSecurityHandler()
	
	# An example of using SDF/Cos API to add any type of annotations.
	AnnotationLowLevelAPI(doc)
	doc.Save($output_path + "annotation_test1.pdf", SDFDoc::E_remove_unused)
	puts "Done. Results saved in annotation_test1.pdf"
	
	# An example of using the high-level PDFNet API to read existing annotations,
	# to edit existing annotations, and to create new annotation from scratch.
	AnnotationHighLevelAPI(doc)
	doc.Save(($output_path + "annotation_test2.pdf"), SDFDoc::E_linearized)
	doc.Close()
	puts "Done. Results saved in annotation_test2.pdf"
	
	doc1 = PDFDoc.new()
	CreateTestAnnots(doc1)
	outfname = $output_path + "new_annot_test_api.pdf"
	doc1.Save(outfname, SDFDoc::E_linearized)
	doc1.Close()
	puts "Saved new_annot_test_api.pdf"
