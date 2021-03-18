#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

def AnnotationHighLevelAPI(doc):
    # The following code snippet traverses all annotations in the document
    print("Traversing all annotations in the document...")
    page_num = 1
    itr = doc.GetPageIterator()
    
    while itr.HasNext():
        print("Page " + str(page_num) + ": ")
        page_num = page_num + 1
        page = itr.Current()
        num_annots = page.GetNumAnnots()
        i = 0
        while i < num_annots:
            annot = page.GetAnnot(i)
            if not annot.IsValid():
                continue
            print("Annot Type: " + annot.GetSDFObj().Get("Subtype").Value().GetName())
            
            bbox = annot.GetRect()
            formatter = '{0:g}'
            print("  Position: " + formatter.format(bbox.x1) + 
                  ", " + formatter.format(bbox.y1) +
                  ", " + formatter.format(bbox.x2) + 
                  ", " + formatter.format(bbox.y2))
            
            type = annot.GetType()
            
            if type == Annot.e_Link:
                link = Link(annot)
                action = link.GetAction()
                if not action.IsValid():
                    continue
                if action.GetType() == Action.e_GoTo:
                    dest = action.GetDest()
                    if not dest.IsValid():
                        print("  Destination is not valid.")
                    else:
                        page_n = dest.GetPage().GetIndex()
                        print("  Links to: page number " + str(page_n) + " in this document")
                elif action.GetType() == Action.e_URI:
                    uri = action.GetSDFObj().Get("URI").Value().GetAsPDFText()
                    print("  Links to: " + str(uri))
            elif type == Annot.e_Widget:
                pass
            elif type == Annot.e_FileAttachment:
                pass
            i = i + 1
        itr.Next()

    # Use the high-level API to create new annotations.        
    first_page = doc.GetPage(1)
    
    # Create a hyperlink...
    hyperlink = Link.Create(doc.GetSDFDoc(), Rect(85, 570, 503, 524), Action.CreateURI(doc.GetSDFDoc(), "http://www.pdftron.com"))
    first_page.AnnotPushBack(hyperlink)
    
    # Create an intra-document link...
    goto_page_3 = Action.CreateGoto(Destination.CreateFitH(doc.GetPage(3), 0))
    link = Link.Create(doc.GetSDFDoc(), Rect(85, 458, 503, 502), goto_page_3)
    link.SetColor(ColorPt(0, 0, 1))
    
    # Add the new annotation to the first page
    first_page.AnnotPushBack(link) 
    
    # Create a stamp annotation ...
    stamp = RubberStamp.Create(doc.GetSDFDoc(), Rect(30, 30, 300, 200))
    stamp.SetIcon("Draft")
    first_page.AnnotPushBack(stamp)
    
    # Create a file attachment annotation (embed the 'peppers.jpg').
    file_attach = FileAttachment.Create(doc.GetSDFDoc(), Rect(80, 280, 108, 320), (input_path + "peppers.jpg"))
    first_page.AnnotPushBack(file_attach)


    ink = Ink.Create(doc.GetSDFDoc(), Rect(110, 10, 300, 200))
    pt3 = Point(110, 10)
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
    ink.SetColor(ColorPt(0, 1, 1), 3)
    first_page.AnnotPushBack(ink)

def AnnotationLowLevelAPI(doc):
    itr = doc.GetPageIterator()
    page = itr.Current()
    annots = page.GetAnnots()
    
    if annots == None:
        # If there are no annotations, create a new annotation 
        # array for the page.
        annots = doc.CreateIndirectArray()
        page.GetSDFObj().Put("Annots", annots)

    # Create a Text annotation
    annot = doc.CreateIndirectDict()
    annot.PutName("Subtype", "Text")
    annot.PutBool("Open", True)
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
    
    # Note that PDFNet APi can be used to modify existing annotations. 
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
    
def CreateTestAnnots(doc):
    ew = ElementWriter()
    eb = ElementBuilder()
    
    first_page = doc.PageCreate(Rect(0, 0, 600, 600))
    doc.PagePushBack(first_page)
    ew.Begin(first_page, ElementWriter.e_overlay, False )   # begin writing to this page
    ew.End()    # save changes to the current page
    
    # Test of a free text annotation.
    txtannot = FreeText.Create( doc.GetSDFDoc(), Rect(10, 400, 160, 570)  )
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out " +
                          "of the air by freezing it with an angry glare." +
                          "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 1, 10, 20 ), False )
    txtannot.SetQuaddingFormat(0)
    first_page.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    txtannot = FreeText.Create( doc.GetSDFDoc(), Rect(100, 100, 350, 500)  )
    txtannot.SetContentRect( Rect( 200, 200, 350, 500 ) )
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air "
                            "by freezing it with an angry glare."
                            "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetCalloutLinePoints( Point(200,300), Point(150,290), Point(110,110) )
    txtannot.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 1, 10, 20 ), False )
    txtannot.SetEndingStyle( LineAnnot.e_ClosedArrow )
    txtannot.SetColor( ColorPt( 0, 1, 0 ) )
    txtannot.SetQuaddingFormat(1)
    first_page.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    txtannot = FreeText.Create( doc.GetSDFDoc(), Rect(400, 10, 550, 400)  )    
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air "
                          "by freezing it with an angry glare."
                          "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 1, 10, 20 ), False )
    txtannot.SetColor( ColorPt( 0, 0, 1 ) )
    txtannot.SetOpacity( 0.2 )
    txtannot.SetQuaddingFormat(2)
    first_page.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    page= doc.PageCreate(Rect(0, 0, 600, 600))
    doc.PagePushBack(page)
    ew.Begin(page, ElementWriter.e_overlay, False )    # begin writing to this page
    eb.Reset()  # Reset the GState to default
    ew.End()    # save changes to the current page
    
    # Create a Line annotation...
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(250, 250, 400, 400))
    line.SetStartPoint( Point(350, 270 ) )
    line.SetEndPoint( Point(260,370) )
    line.SetStartStyle(LineAnnot.e_Square)
    line.SetEndStyle(LineAnnot.e_Circle)
    line.SetColor(ColorPt(.3, .5, 0), 3)
    line.SetContents( "Dashed Captioned" )
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.SetBorderStyle( BorderStyle( BorderStyle.e_dashed, 2, 0, 0, [2.0, 2.0] ) )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(347, 377, 600, 600))
    line.SetStartPoint( Point(385, 410 ) )
    line.SetEndPoint( Point(540,555) )
    line.SetStartStyle(LineAnnot.e_Circle)
    line.SetEndStyle(LineAnnot.e_OpenArrow)
    line.SetColor(ColorPt(1, 0, 0), 3)
    line.SetInteriorColor(ColorPt(0, 1, 0), 3)
    line.SetContents( "Inline Caption" )
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Inline )
    line.SetLeaderLineExtensionLength( -4. )
    line.SetLeaderLineLength( -12. )
    line.SetLeaderLineOffset( 2. )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(10, 400, 200, 600))
    line.SetStartPoint( Point(25, 426 ) )
    line.SetEndPoint( Point(180,555) )
    line.SetStartStyle(LineAnnot.e_Circle)
    line.SetEndStyle(LineAnnot.e_Square)
    line.SetColor(ColorPt(0, 0, 1), 3)
    line.SetInteriorColor(ColorPt(1, 0, 0), 3)
    line.SetContents("Offset Caption")
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.SetTextHOffset( -60 )
    line.SetTextVOffset( 10 )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(200, 10, 400, 70))
    line.SetStartPoint( Point(220, 25 ) )
    line.SetEndPoint( Point(370,60) )
    line.SetStartStyle(LineAnnot.e_Butt)
    line.SetEndStyle(LineAnnot.e_OpenArrow)
    line.SetColor(ColorPt(0, 0, 1), 3)
    line.SetContents( "Regular Caption" )
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(200, 70, 400, 130))
    line.SetStartPoint( Point(220, 111 ) )
    line.SetEndPoint( Point(370,78) )
    line.SetStartStyle(LineAnnot.e_Circle)
    line.SetEndStyle(LineAnnot.e_Diamond)
    line.SetContents( "Circle to Diamond" )
    line.SetColor(ColorPt(0, 0, 1), 3)
    line.SetInteriorColor(ColorPt(0, 1, 0), 3)
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect(10, 100, 160, 200))
    line.SetStartPoint( Point(15, 110 ) )
    line.SetEndPoint( Point(150, 190) )
    line.SetStartStyle(LineAnnot.e_Slash)
    line.SetEndStyle(LineAnnot.e_ClosedArrow)
    line.SetContents( "Slash to CArrow" )
    line.SetColor(ColorPt(1, 0, 0), 3)
    line.SetInteriorColor(ColorPt(0, 1, 1), 3)
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect( 270, 270, 570, 433 ))
    line.SetStartPoint( Point(300, 400 ) )
    line.SetEndPoint( Point(550, 300) )
    line.SetStartStyle(LineAnnot.e_RClosedArrow)
    line.SetEndStyle(LineAnnot.e_ROpenArrow)
    line.SetContents( "ROpen & RClosed arrows" )
    line.SetColor(ColorPt(0, 0, 1), 3)
    line.SetInteriorColor(ColorPt(0, 1, 0), 3)
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)

    line=LineAnnot.Create(doc.GetSDFDoc(), Rect( 195, 395, 205, 505 ))
    line.SetStartPoint( Point(200, 400 ) )
    line.SetEndPoint( Point(200, 500) )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect( 55, 299, 150, 301 ))
    line.SetStartPoint( Point(55, 300 ) )
    line.SetEndPoint( Point(155, 300) )
    line.SetStartStyle(LineAnnot.e_Circle)
    line.SetEndStyle(LineAnnot.e_Circle)
    line.SetContents( "Caption that's longer than its line." )
    line.SetColor(ColorPt(1, 0, 1), 3)
    line.SetInteriorColor(ColorPt(0, 1, 0), 3)
    line.SetShowCaption(True)
    line.SetCaptionPosition( LineAnnot.e_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line=LineAnnot.Create(doc.GetSDFDoc(), Rect( 300, 200, 390, 234 ))
    line.SetStartPoint( Point(310, 210 ) )
    line.SetEndPoint( Point(380, 220) )
    line.SetColor(ColorPt(0, 0, 0), 3)
    line.RefreshAppearance()
    page.AnnotPushBack(line)

    page3 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page3)     # begin writing to the page
    ew.End()   # save changes to the current page
    doc.PagePushBack(page3)

    circle=Circle.Create(doc.GetSDFDoc(), Rect( 300, 300, 390, 350 ))
    circle.SetColor(ColorPt(0, 0, 0), 3)
    circle.RefreshAppearance()
    page3.AnnotPushBack(circle)
    
    circle=Circle.Create(doc.GetSDFDoc(), Rect( 100, 100, 200, 200 ))
    circle.SetColor(ColorPt(0, 1, 0), 3)
    circle.SetInteriorColor(ColorPt(0, 0, 1), 3)
    circle.SetBorderStyle( BorderStyle( BorderStyle.e_dashed, 3, 0, 0, [2, 4] ) )
    circle.SetPadding( 2 )
    circle.RefreshAppearance()
    page3.AnnotPushBack(circle)

    sq = Square.Create( doc.GetSDFDoc(), Rect(10,200, 80, 300 ) )
    sq.SetColor(ColorPt(0, 0, 0), 3)
    sq.RefreshAppearance()
    page3.AnnotPushBack( sq )

    sq = Square.Create( doc.GetSDFDoc(), Rect(500,200, 580, 300 ) )
    sq.SetColor(ColorPt(1, 0, 0), 3)
    sq.SetInteriorColor(ColorPt(0, 1, 1), 3)
    sq.SetBorderStyle( BorderStyle( BorderStyle.e_dashed, 6, 0, 0, [4, 2] ) )
    sq.SetPadding( 4 )
    sq.RefreshAppearance()
    page3.AnnotPushBack( sq )
    
    poly = Polygon.Create(doc.GetSDFDoc(), Rect(5, 500, 125, 590))
    poly.SetColor(ColorPt(1, 0, 0), 3)
    poly.SetInteriorColor(ColorPt(1, 1, 0), 3)
    poly.SetVertex(0, Point(12,510) )
    poly.SetVertex(1, Point(100,510) )
    poly.SetVertex(2, Point(100,555) )
    poly.SetVertex(3, Point(35,544) )
    poly.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 4, 0, 0 ) )
    poly.SetPadding( 4 )
    poly.RefreshAppearance()
    page3.AnnotPushBack( poly )
    
    poly = PolyLine.Create(doc.GetSDFDoc(), Rect(400, 10, 500, 90))
    poly.SetColor(ColorPt(1, 0, 0), 3)
    poly.SetInteriorColor(ColorPt(0, 1, 0), 3)
    poly.SetVertex(0, Point(405,20) )
    poly.SetVertex(1, Point(440,40) )
    poly.SetVertex(2, Point(410,60) )
    poly.SetVertex(3, Point(470,80) )
    poly.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 2, 0, 0 ) )
    poly.SetPadding( 4 )
    poly.SetStartStyle( LineAnnot.e_RClosedArrow )
    poly.SetEndStyle( LineAnnot.e_ClosedArrow )
    poly.RefreshAppearance()
    page3.AnnotPushBack( poly )

    lk = Link.Create( doc.GetSDFDoc(), Rect(5,5,55,24) )
    lk.RefreshAppearance()
    page3.AnnotPushBack( lk )

    page4 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page4)    # begin writing to the page
    ew.End()  # save changes to the current page
    doc.PagePushBack(page4)
    
    ew.Begin( page4 )
    font = Font.Create(doc.GetSDFDoc(), Font.e_helvetica)
    element = eb.CreateTextBegin( font, 16 )
    element.SetPathFill(True)
    ew.WriteElement(element)
    element = eb.CreateTextRun( "Some random text on the page", font, 16 )
    element.SetTextMatrix(1, 0, 0, 1, 100, 500 )
    ew.WriteElement(element)
    ew.WriteElement( eb.CreateTextEnd() )
    ew.End()

    hl = HighlightAnnot.Create( doc.GetSDFDoc(), Rect(100,490,150,515) )
    hl.SetColor( ColorPt(0,1,0), 3 )
    hl.RefreshAppearance()
    page4.AnnotPushBack( hl )

    sq = Squiggly.Create( doc.GetSDFDoc(), Rect(100,450,250,600) )
    sq.SetQuadPoint( 0, QuadPoint( Point( 122,455), Point(240, 545), Point(230, 595), Point(101,500 ) ) )
    sq.RefreshAppearance()
    page4.AnnotPushBack( sq )

    cr = Caret.Create( doc.GetSDFDoc(), Rect(100,40,129,69) )
    cr.SetColor( ColorPt(0,0,1), 3 )
    cr.SetSymbol( "P" )
    cr.RefreshAppearance()
    page4.AnnotPushBack( cr )
    
    page5 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page5)    # begin writing to the page
    ew.End()  # save changes to the current page
    doc.PagePushBack(page5)
    fs = FileSpec.Create( doc.GetSDFDoc(), (input_path + "butterfly.png"), False )
    page6 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page6)    # begin writing to the page
    ew.End()  # save changes to the current page
    doc.PagePushBack(page6)
    
        
    txt = Text.Create( doc.GetSDFDoc(), Point(10, 20) )
    txt.SetIcon( "UserIcon" )
    txt.SetContents( "User defined icon, unrecognized by appearance generator" )
    txt.SetColor( ColorPt(0,1,0) )
    txt.RefreshAppearance()
    page6.AnnotPushBack( txt )
    
    ink = Ink.Create( doc.GetSDFDoc(), Rect( 100, 400, 200, 550 ) )
    ink.SetColor( ColorPt(0,0,1) )
    ink.SetPoint( 1, 3, Point( 220, 505) )
    ink.SetPoint( 1, 0, Point( 100, 490) )
    ink.SetPoint( 0, 1, Point( 120, 410) )
    ink.SetPoint( 0, 0, Point( 100, 400) )
    ink.SetPoint( 1, 2, Point( 180, 490) )
    ink.SetPoint( 1, 1, Point( 140, 440) )        
    ink.SetBorderStyle( BorderStyle( BorderStyle.e_solid, 3, 0, 0  ) )
    ink.RefreshAppearance()
    page6.AnnotPushBack( ink )
    
    page7 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page7)    # begin writing to the page
    ew.End()  # save changes to the current page
    doc.PagePushBack(page7)
    
    snd = Sound.Create( doc.GetSDFDoc(), Rect( 100, 500, 120, 520 ) )
    snd.SetColor(  ColorPt(1,1,0) )
    snd.SetIcon( Sound.e_Speaker )
    snd.RefreshAppearance()
    page7.AnnotPushBack( snd )
    
    snd = Sound.Create( doc.GetSDFDoc(), Rect( 200, 500, 220, 520 ) )
    snd.SetColor(  ColorPt(1,1,0) )
    snd.SetIcon( Sound.e_Mic )
    snd.RefreshAppearance()
    page7.AnnotPushBack( snd )
    
    page8 = doc.PageCreate(Rect(0, 0, 600, 600))
    ew.Begin(page8)    # begin writing to the page
    ew.End()  # save changes to the current page
    doc.PagePushBack(page8)
    
    ipage = 0
    while ipage<2:
        px = 5
        py = 520
        istamp = RubberStamp.e_Approved
        while istamp <= RubberStamp.e_Draft:
            st = RubberStamp.Create(doc.GetSDFDoc(), Rect(1,1,100,100))
            st.SetIcon( istamp )
            st.SetContents( st.GetIconName() )
            st.SetRect( Rect(px, py, px+100, py+25 ) )
            py -= 100
            if py < 0:
                py = 520
                px+=200
            if ipage == 0:
                #page7.AnnotPushBack(st)
                pass
            else:
                page8.AnnotPushBack( st )
                st.RefreshAppearance()
            istamp = istamp + 1
        ipage = ipage + 1
    
    st = RubberStamp.Create( doc.GetSDFDoc(), Rect(400,5,550,45) )
    st.SetIcon( "UserStamp" )
    st.SetContents( "User defined stamp" )
    page8.AnnotPushBack( st )
    st.RefreshAppearance()
    
if __name__ == '__main__':
    PDFNet.Initialize()
    
    output_path = "../../TestFiles/Output/"
    input_path = "../../TestFiles/"
    
    doc = PDFDoc(input_path + "numbered.pdf")
    doc.InitSecurityHandler()
    
    # An example of using SDF/Cos API to add any type of annotations.
    AnnotationLowLevelAPI(doc)
    doc.Save(output_path + "annotation_test1.pdf", SDFDoc.e_remove_unused)
    print("Done. Results saved in annotation_test1.pdf")
    
    # An example of using the high-level PDFNet API to read existing annotations,
    # to edit existing annotations, and to create new annotation from scratch.
    AnnotationHighLevelAPI(doc)
    doc.Save((output_path + "annotation_test2.pdf"), SDFDoc.e_linearized)
    doc.Close()
    print("Done. Results saved in annotation_test2.pdf")
    
    doc1 = PDFDoc()
    CreateTestAnnots(doc1)
    outfname = output_path + "new_annot_test_api.pdf"
    doc1.Save(outfname, SDFDoc.e_linearized)
    print("Saved new_annot_test_api.pdf")




