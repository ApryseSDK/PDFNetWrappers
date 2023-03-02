//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "flag"
    "strconv"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func AnnotationLowLevelAPI(doc PDFDoc){
    itr := doc.GetPageIterator()
    page := itr.Current()
    annots := page.GetAnnots()
    if (page.GetNumAnnots() == 0){
        // If there are no annotations, create a new annotation 
        // array for the page.
        annots = doc.CreateIndirectArray()
        page.GetSDFObj().Put("Annots", annots)
	}

    // Create a Text annotation
    annot := doc.CreateIndirectDict()
    annot.PutName("Subtype", "Text")
    annot.PutBool("Open", true)
    annot.PutString("Contents", "The quick brown fox ate the lazy mouse.")
    annot.PutRect("Rect", 266.0, 116.0, 430.0, 204.0)

    // Insert the annotation in the page annotation array
    annots.PushBack(annot)   
   
    // Create a Link annotation
    link1 := doc.CreateIndirectDict()
    link1.PutName("Subtype", "Link")
    dest := DestinationCreateFit(doc.GetPage(2))
    link1.Put("Dest", dest.GetSDFObj())
    link1.PutRect("Rect", 85.0, 705.0, 503.0, 661.0)
    annots.PushBack(link1)

    // Create another Link annotation
    link2 := doc.CreateIndirectDict()
    link2.PutName("Subtype", "Link")
    dest2 := DestinationCreateFit((doc.GetPage(3)))
    link2.Put("Dest", dest2.GetSDFObj())
    link2.PutRect("Rect", 85.0, 638.0, 503.0, 594.0)
    annots.PushBack(link2)
    
    // Note that PDFNet APi can be used to modify existing annotations. 
    // In the following example we will modify the second link annotation 
    // (link2) so that it points to the 10th page. We also use a different 
    // destination page fit type.
    
    // link2 = annots.GetAt(annots.Size()-1)
    link2.Put("Dest", DestinationCreateXYZ(doc.GetPage(10), 100, 792-70, 10).GetSDFObj())
    
    // Create a third link annotation with a hyperlink action (all other 
    // annotation types can be created in a similar way)
    link3 := doc.CreateIndirectDict()
    link3.PutName("Subtype", "Link")
    link3.PutRect("Rect", 85.0, 570.0, 503.0, 524.0)
    
    // Create a URI action 
    action := link3.PutDict("A")
    action.PutName("S", "URI")
    action.PutString("URI", "http://www.pdftron.com")
    
    annots.PushBack(link3)
}

func AnnotationHighLevelAPI(doc PDFDoc){
    // The following code snippet traverses all annotations in the document
    fmt.Println("Traversing all annotations in the document...")
    pageNum := 1
    itr := doc.GetPageIterator()
    
    for itr.HasNext(){
        fmt.Println("Page " + strconv.Itoa(pageNum) + ": ")
        pageNum = pageNum + 1
        page := itr.Current()
        numAnnots := page.GetNumAnnots()
        i := uint(0)
        for i < numAnnots{
            annot := page.GetAnnot(i)
            if (!annot.IsValid()){
                continue
			}
            fmt.Println("Annot Type: " + annot.GetSDFObj().Get("Subtype").Value().GetName())
            
            bbox := annot.GetRect()
            fmt.Println("  Position: " + fmt.Sprintf("%.0f", bbox.GetX1()) + 
						", " + fmt.Sprintf("%.0f", bbox.GetY1()) + 
						", " + fmt.Sprintf("%.0f", bbox.GetX2()) + 
						", " + fmt.Sprintf("%.0f", bbox.GetY2()))
            
            atype := annot.GetType()
            
            if (atype == AnnotE_Link){
                link := NewLink(annot)
                action := link.GetAction()
                if (!action.IsValid()){
                    continue
				}
                if (action.GetType() == ActionE_GoTo){
                    dest := action.GetDest()
                    if (!dest.IsValid()){
                        fmt.Println("  Destination is not valid.")
					}else{
                        pageN := dest.GetPage().GetIndex()
                        fmt.Println("  Links to: page number " + strconv.Itoa(pageN) + " in this document")
					}
				}else if (action.GetType() == ActionE_URI){
                    uri := action.GetSDFObj().Get("URI").Value().GetAsPDFText()
                    fmt.Println("  Links to: " + uri)
				}
            }else if (atype == AnnotE_Widget){
                //handle Widget here
			}else if (atype == AnnotE_FileAttachment){
                //handle FileAttachment here
			}
            i = i + 1
		}
        itr.Next()
	}
    // Use the high-level API to create new annotations.        
    firstPage := doc.GetPage(1)
    
    // Create a hyperlink...
    hyperlink := LinkCreate(doc.GetSDFDoc(), NewRect(85.0, 570.0, 503.0, 524.0), ActionCreateURI(doc.GetSDFDoc(), "http://www.pdftron.com"))
    firstPage.AnnotPushBack(hyperlink)
    
    // Create an intra-document link...
    gotoPage3 := ActionCreateGoto(DestinationCreateFitH(doc.GetPage(3), 0))
    link := LinkCreate(doc.GetSDFDoc(), NewRect(85.0, 458.0, 503.0, 502.0), gotoPage3)
    link.SetColor(NewColorPt(0.0, 0.0, 1.0))
    
    // Add the new annotation to the first page
    firstPage.AnnotPushBack(link) 
    
    // Create a stamp annotation ...
    stamp := RubberStampCreate(doc.GetSDFDoc(), NewRect(30.0, 30.0, 300.0, 200.0))
    stamp.SetIcon("Draft")
    firstPage.AnnotPushBack(stamp)
    
    // Create a file attachment annotation (embed the 'peppers.jpg').
    file_attach := FileAttachmentCreate(doc.GetSDFDoc(), NewRect(80.0, 280.0, 108.0, 320.0), (inputPath + "peppers.jpg"))
    firstPage.AnnotPushBack(file_attach)


    ink := InkCreate(doc.GetSDFDoc(), NewRect(110.0, 10.0, 300.0, 200.0))
    pt3 := NewPoint(110.0, 10.0)
    pt3.SetX(110)
    pt3.SetY(10)
    ink.SetPoint(0, 0, pt3)
    pt3.SetX(150) 
    pt3.SetY(50)
    ink.SetPoint(0, 1, pt3)
    pt3.SetX(190) 
    pt3.SetY(60)
    ink.SetPoint(0, 2, pt3)
    pt3.SetX(180) 
    pt3.SetY(90)
    ink.SetPoint(1, 0, pt3)
    pt3.SetX(190) 
    pt3.SetY(95)
    ink.SetPoint(1, 1, pt3)
    pt3.SetX(200) 
    pt3.SetY(100)
    ink.SetPoint(1, 2, pt3)
    pt3.SetX(166) 
    pt3.SetY(86)
    ink.SetPoint(2, 0, pt3)
    pt3.SetX(196) 
    pt3.SetY(96)
    ink.SetPoint(2, 1, pt3)
    pt3.SetX(221) 
    pt3.SetY(121)
    ink.SetPoint(2, 2, pt3)
    pt3.SetX(288) 
    pt3.SetY(188)
    ink.SetPoint(2, 3, pt3)
    ink.SetColor(NewColorPt(0.0, 1.0, 1.0), 3)
    firstPage.AnnotPushBack(ink)
}

func CreateTestAnnots(doc PDFDoc){
    ew := NewElementWriter()
    eb := NewElementBuilder()
    
    firstPage := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    doc.PagePushBack(firstPage)
    ew.Begin(firstPage, ElementWriterE_overlay, false )   // begin writing to this page
    ew.End()    // save changes to the current page
    
    // Test of a free text annotation.
    txtannot := FreeTextCreate( doc.GetSDFDoc(), NewRect(10.0, 400.0, 160.0, 570.0)  )
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out " +
                          "of the air by freezing it with an angry glare." +
                          "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 1.0, 10.0, 20.0 ), false )
    txtannot.SetQuaddingFormat(0)
    firstPage.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    txtannot = FreeTextCreate( doc.GetSDFDoc(), NewRect(100.0, 100.0, 350.0, 500.0)  )
    txtannot.SetContentRect( NewRect(200.0, 200.0, 350.0, 500.0 ) )
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air " +
                            "by freezing it with an angry glare." +
                            "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetCalloutLinePoints( NewPoint(200.0,300.0), NewPoint(150.0,290.0), NewPoint(110.0,110.0) )
    txtannot.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 1.0, 10.0, 20.0 ), false )
    txtannot.SetEndingStyle( LineAnnotE_ClosedArrow )
    txtannot.SetColor( NewColorPt( 0.0, 1.0, 0.0 ) )
    txtannot.SetQuaddingFormat(1)
    firstPage.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    txtannot = FreeTextCreate( doc.GetSDFDoc(), NewRect(400.0, 10.0, 550.0, 400.0) )    
    txtannot.SetContents( "\n\nSome swift brown fox snatched a gray hare out of the air " +
                          "by freezing it with an angry glare." +
                          "\n\nAha!\n\nAnd there was much rejoicing!"    )
    txtannot.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 1.0, 10.0, 20.0 ), false )
    txtannot.SetColor( NewColorPt( 0.0, 0.0, 1.0 ) )
    txtannot.SetOpacity( 0.2 )
    txtannot.SetQuaddingFormat(2)
    firstPage.AnnotPushBack(txtannot)
    txtannot.RefreshAppearance()
    
    page := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    doc.PagePushBack(page)
    ew.Begin(page, ElementWriterE_overlay, false )    // begin writing to this page
    eb.Reset() // Reset the GState to default
    ew.End()    // save changes to the current page
    
    // Create a Line annotation...
    line := LineAnnotCreate(doc.GetSDFDoc(), NewRect(250.0, 250.0, 400.0, 400.0))
    line.SetStartPoint( NewPoint(350.0, 270.0 ) )
    line.SetEndPoint( NewPoint(260.0,370.0) )
    line.SetStartStyle(LineAnnotE_Square)
    line.SetEndStyle(LineAnnotE_Circle)
    line.SetColor(NewColorPt(.3, .5, 0.0), 3)
    line.SetContents( "Dashed Captioned" )
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
	var dash = NewVectorDouble()
	dash.Add(2.0)
	dash.Add(2.0)
    line.SetBorderStyle( NewBorderStyle( BorderStyleE_dashed, 2.0, 0.0, 0.0, dash ) )
	dash.Clear()
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(347.0, 377.0, 600.0, 600.0))
    line.SetStartPoint( NewPoint(385.0, 410.0 ) )
    line.SetEndPoint( NewPoint(540.0,555.0) )
    line.SetStartStyle(LineAnnotE_Circle)
    line.SetEndStyle(LineAnnotE_OpenArrow)
    line.SetColor(NewColorPt(1.0, 0.0, 0.0), 3)
    line.SetInteriorColor(NewColorPt(0.0, 1.0, 0.0), 3)
    line.SetContents( "Inline Caption" )
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Inline )
    line.SetLeaderLineExtensionLength( -4. )
    line.SetLeaderLineLength( -12. )
    line.SetLeaderLineOffset( 2. )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(10.0, 400.0, 200.0, 600.0))
    line.SetStartPoint( NewPoint(25.0, 426.0 ) )
    line.SetEndPoint( NewPoint(180.0,555.0) )
    line.SetStartStyle(LineAnnotE_Circle)
    line.SetEndStyle(LineAnnotE_Square)
    line.SetColor(NewColorPt(0.0, 0.0, 1.0), 3)
    line.SetInteriorColor(NewColorPt(1.0, 0.0, 0.0), 3)
    line.SetContents("Offset Caption")
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.SetTextHOffset( -60 )
    line.SetTextVOffset( 10 )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(200.0, 10.0, 400.0, 70.0))
    line.SetStartPoint( NewPoint(222.0, 25.0 ) )
    line.SetEndPoint( NewPoint(370.0,60.0) )
    line.SetStartStyle(LineAnnotE_Butt)
    line.SetEndStyle(LineAnnotE_OpenArrow)
    line.SetColor(NewColorPt(0.0, 0.0, 1.0), 3)
    line.SetContents( "Regular Caption" )
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(200.0, 70.0, 400.0, 130.0))
    line.SetStartPoint( NewPoint(220.0, 111.0 ) )
    line.SetEndPoint( NewPoint(370.0,78.0) )
    line.SetStartStyle(LineAnnotE_Circle)
    line.SetEndStyle(LineAnnotE_Diamond)
    line.SetContents( "Circle to Diamond" )
    line.SetColor(NewColorPt(0.0, 0.0, 1.0), 3)
    line.SetInteriorColor(NewColorPt(0.0, 1.0, 0.0), 3)
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(10.0, 100.0, 160.0, 200.0))
    line.SetStartPoint( NewPoint(15.0, 110.0 ) )
    line.SetEndPoint( NewPoint(150.0, 190.0) )
    line.SetStartStyle(LineAnnotE_Slash)
    line.SetEndStyle(LineAnnotE_ClosedArrow)
    line.SetContents( "Slash to CArrow" )
    line.SetColor(NewColorPt(1.0, 0.0, 0.0), 3)
    line.SetInteriorColor(NewColorPt(0.0, 1.0, 1.0), 3)
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(270.0, 270.0, 570.0, 433.0 ))
    line.SetStartPoint( NewPoint(300.0, 400.0 ) )
    line.SetEndPoint( NewPoint(550.0, 300.0) )
    line.SetStartStyle(LineAnnotE_RClosedArrow)
    line.SetEndStyle(LineAnnotE_ROpenArrow)
    line.SetContents( "ROpen & RClosed arrows" )
    line.SetColor(NewColorPt(0.0, 0.0, 1.0), 3)
    line.SetInteriorColor(NewColorPt(0.0, 1.0, 0.0), 3)
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)

    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(195.0, 395.0, 205.0, 505.0 ))
    line.SetStartPoint( NewPoint(200.0, 400.0 ) )
    line.SetEndPoint( NewPoint(200.0, 500.0) )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(55.0, 299.0, 150.0, 301.0 ))
    line.SetStartPoint( NewPoint(55.0, 300.0 ) )
    line.SetEndPoint( NewPoint(155.0, 300.0) )
    line.SetStartStyle(LineAnnotE_Circle)
    line.SetEndStyle(LineAnnotE_Circle)
    line.SetContents( "Caption that's longer than its line." )
    line.SetColor(NewColorPt(1.0, 0.0, 1.0), 3)
    line.SetInteriorColor(NewColorPt(0.0, 1.0, 0.0), 3)
    line.SetShowCaption(true)
    line.SetCaptionPosition( &LineAnnotE_Top )
    line.RefreshAppearance()
    page.AnnotPushBack(line)
    
    line = LineAnnotCreate(doc.GetSDFDoc(), NewRect(300.0, 200.0, 390.0, 234.0 ))
    line.SetStartPoint( NewPoint(310.0, 210.0 ) )
    line.SetEndPoint( NewPoint(380.0, 220.0) )
    line.SetColor(NewColorPt(0.0, 0.0, 0.0), 3)
    line.RefreshAppearance()
    page.AnnotPushBack(line)

    page3 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page3)     // begin writing to the page
    ew.End()   // save changes to the current page
    doc.PagePushBack(page3)

    circle := CircleCreate(doc.GetSDFDoc(), NewRect(300.0, 300.0, 390.0, 350.0 ))
    circle.SetColor(NewColorPt(0.0, 0.0, 0.0), 3)
    circle.RefreshAppearance()
    page3.AnnotPushBack(circle)
    
    circle = CircleCreate(doc.GetSDFDoc(), NewRect(100.0, 100.0, 200.0, 200.0 ))
    circle.SetColor(NewColorPt(0.0, 1.0, 0.0), 3)
    circle.SetInteriorColor(NewColorPt(0.0, 0.0, 1.0), 3)
	dash.Add(2.0)
	dash.Add(4.0)
    circle.SetBorderStyle( NewBorderStyle( BorderStyleE_dashed, 3.0, 0.0, 0.0, dash ) )
	dash.Clear()
    circle.SetPadding( 2.0 )
    circle.RefreshAppearance()
    page3.AnnotPushBack(circle)

    sq := SquareCreate( doc.GetSDFDoc(), NewRect(10.0, 200.0, 80.0, 300.0 ) )
    sq.SetColor(NewColorPt(0.0, 0.0, 0.0), 3)
    sq.RefreshAppearance()
    page3.AnnotPushBack( sq )

    sq = SquareCreate( doc.GetSDFDoc(), NewRect(500.0, 200.0, 580.0, 300.0 ) )
    sq.SetColor(NewColorPt(1.0, 0.0, 0.0), 3)
    sq.SetInteriorColor(NewColorPt(0.0, 1.0, 1.0), 3)
	dash.Add(4.0)
	dash.Add(2.0)
    sq.SetBorderStyle( NewBorderStyle( BorderStyleE_dashed, 6.0, 0.0, 0.0, dash ) )
	dash.Clear()
    sq.SetPadding( 4.0 )
    sq.RefreshAppearance()
    page3.AnnotPushBack( sq )
    
	polygon := PolygonCreate(doc.GetSDFDoc(), NewRect(5.0, 500.0, 125.0, 590.0))
	polygon.SetColor(NewColorPt(1.0, 0.0, 0.0), 3)
	polygon.SetInteriorColor(NewColorPt(1.0, 1.0, 0.0), 3)
	polygon.SetVertex(0, NewPoint(12.0,510.0) )
	polygon.SetVertex(1, NewPoint(100.0,510.0) )
	polygon.SetVertex(2, NewPoint(100.0,555.0) )
	polygon.SetVertex(3, NewPoint(35.0,544.0) )
	polygon.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 4.0, 0.0, 0.0 ) )
	polygon.SetPadding( 4.0 )
	polygon.RefreshAppearance()
	page3.AnnotPushBack( polygon )
	polyline := PolyLineCreate(doc.GetSDFDoc(), NewRect(400.0, 10.0, 500.0, 90.0))
	polyline.SetColor(NewColorPt(1.0, 0.0, 0.0), 3)
	polyline.SetInteriorColor(NewColorPt(0.0, 1.0, 0.0), 3)
	polyline.SetVertex(0, NewPoint(405.0,20.0) )
	polyline.SetVertex(1, NewPoint(440.0,40.0) )
	polyline.SetVertex(2, NewPoint(410.0,60.0) )
	polyline.SetVertex(3, NewPoint(470.0,80.0) )
	polyline.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 2.0, 0.0, 0.0 ) )
	polyline.SetPadding( 4.0 )
	polyline.SetStartStyle( LineAnnotE_RClosedArrow )
	polyline.SetEndStyle( LineAnnotE_ClosedArrow )
	polyline.RefreshAppearance()
	page3.AnnotPushBack( polyline )
    lk := LinkCreate( doc.GetSDFDoc(), NewRect(5.0, 5.0, 55.0, 24.0) )
    lk.RefreshAppearance()
    page3.AnnotPushBack( lk )

    page4 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page4)    // begin writing to the page
    ew.End()  // save changes to the current page
    doc.PagePushBack(page4)
    
    ew.Begin( page4 )
    font := FontCreate(doc.GetSDFDoc(), FontE_helvetica)
    element := eb.CreateTextBegin( font, 16.0 )
    element.SetPathFill(true)
    ew.WriteElement(element)
    element = eb.CreateTextRun( "Some random text on the page", font, 16.0 )
    element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 100.0, 500.0 )
    ew.WriteElement(element)
    ew.WriteElement( eb.CreateTextEnd() )
    ew.End()

    hl := HighlightAnnotCreate( doc.GetSDFDoc(), NewRect(100.0, 490.0, 150.0, 515.0) )
    hl.SetColor( NewColorPt(0.0,1.0,0.0), 3 )
    hl.RefreshAppearance()
    page4.AnnotPushBack( hl )

    sqly := SquigglyCreate( doc.GetSDFDoc(), NewRect(100.0, 450.0, 250.0, 600.0) )
    sqly.SetQuadPoint( 0, NewQuadPoint(NewPoint(122.0,455.0), NewPoint(240.0, 545.0), NewPoint(230.0, 595.0), NewPoint(101.0,500.0) ) )
    sqly.RefreshAppearance()
    page4.AnnotPushBack( sqly )

    cr := CaretCreate( doc.GetSDFDoc(), NewRect(100.0, 40.0, 129.0, 69.0) )
    cr.SetColor( NewColorPt(0.0,0.0,1.0), 3 )
    cr.SetSymbol( "P" )
    cr.RefreshAppearance()
    page4.AnnotPushBack( cr )
    
    page5 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page5)    // begin writing to the page
    ew.End()  // save changes to the current page
    doc.PagePushBack(page5)
    //fs := FileSpecCreate( doc.GetSDFDoc(), (inputPath + "butterfly.png"), false )
    page6 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page6)    // begin writing to the page
    ew.End()  // save changes to the current page
    doc.PagePushBack(page6)
    
        
    txt := TextCreate( doc.GetSDFDoc(), NewPoint(10.0, 20.0) )
    txt.SetIcon( "UserIcon" )
    txt.SetContents( "User defined icon, unrecognized by appearance generator" )
    txt.SetColor( NewColorPt(0.0,1.0,0.0) )
    txt.RefreshAppearance()
    page6.AnnotPushBack( txt )
    
    ink := InkCreate( doc.GetSDFDoc(), NewRect(100.0, 400.0, 200.0, 550.0 ) )
    ink.SetColor( NewColorPt(0.0,0.0,1.0) )
    ink.SetPoint( 1, 3, NewPoint( 220.0, 505.0) )
    ink.SetPoint( 1, 0, NewPoint( 100.0, 490.0) )
    ink.SetPoint( 0, 1, NewPoint( 120.0, 410.0) )
    ink.SetPoint( 0, 0, NewPoint( 100.0, 400.0) )
    ink.SetPoint( 1, 2, NewPoint( 180.0, 490.0) )
    ink.SetPoint( 1, 1, NewPoint( 140.0, 440.0) )        
    ink.SetBorderStyle( NewBorderStyle( BorderStyleE_solid, 3.0, 0.0, 0.0 ))
    ink.RefreshAppearance()
    page6.AnnotPushBack( ink )
    
    page7 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page7)    // begin writing to the page
    ew.End()  // save changes to the current page
    doc.PagePushBack(page7)
    
    snd := SoundCreate( doc.GetSDFDoc(), NewRect(100.0, 500.0, 120.0, 520.0 ) )
    snd.SetColor(  NewColorPt(1.0,1.0,0.0) )
    snd.SetIcon( SoundE_Speaker )
    snd.RefreshAppearance()
    page7.AnnotPushBack( snd )
    
    snd = SoundCreate( doc.GetSDFDoc(), NewRect(200.0, 500.0, 220.0, 520.0 ) )
    snd.SetColor(  NewColorPt(1.0,1.0,0.0) )
    snd.SetIcon( SoundE_Mic )
    snd.RefreshAppearance()
    page7.AnnotPushBack( snd )
    
    page8 := doc.PageCreate(NewRect(0.0, 0.0, 600.0, 600.0))
    ew.Begin(page8)    // begin writing to the page
    ew.End()  // save changes to the current page
    doc.PagePushBack(page8)
    
    ipage := 0
    for ipage<2{
        px := 5
        py := 520
        istamp := RubberStampE_Approved
        for istamp <= RubberStampE_Draft{
            st := RubberStampCreate(doc.GetSDFDoc(), NewRect(1.0, 1.0, 100.0, 100.0))
            st.SetIcon( istamp )
            st.SetContents( st.GetIconName() )
            st.SetRect( NewRect(float64(px), float64(py), float64(px+100), float64(py+25) ) )
            py -= 100
            if py < 0{
                py = 520
                px+=200
			}
            if ipage == 0{
                //page7.AnnotPushBack(st)
			}else{
                page8.AnnotPushBack( st )
                st.RefreshAppearance()
			}
            istamp = istamp + 1
		}
        ipage = ipage + 1
    }

    st := RubberStampCreate( doc.GetSDFDoc(), NewRect(400.0, 5.0, 550.0, 45.0) )
    st.SetIcon( "UserStamp" )
    st.SetContents( "User defined stamp" )
    page8.AnnotPushBack( st )
    st.RefreshAppearance()
}    

func TestAnnotation(t *testing.T){
    PDFNetInitialize(licenseKey)
   
    doc := NewPDFDoc(inputPath + "numbered.pdf")
    doc.InitSecurityHandler()
    
    // An example of using SDF/Cos API to add any type of annotations.
    AnnotationLowLevelAPI(doc)
    doc.Save(outputPath + "annotation_test1.pdf", uint(SDFDocE_remove_unused))
    fmt.Println("Done. Results saved in annotation_test1.pdf")
    // An example of using the high-level PDFNet API to read existing annotations,
    // to edit existing annotations, and to create new annotation from scratch.
    AnnotationHighLevelAPI(doc)
    doc.Save((outputPath + "annotation_test2.pdf"), uint(SDFDocE_linearized))
    doc.Close()
    fmt.Println("Done. Results saved in annotation_test2.pdf")
    
    doc1 := NewPDFDoc()
    CreateTestAnnots(doc1)
    outfname := outputPath + "new_annot_test_api.pdf"
    doc1.Save(outfname, uint(SDFDocE_linearized))
    fmt.Println("Saved new_annot_test_api.pdf")
    PDFNetTerminate()
}

