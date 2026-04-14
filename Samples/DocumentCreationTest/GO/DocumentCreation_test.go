//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main

import (
	"flag"
	"fmt"
	"testing"

	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
	flag.StringVar(&licenseKey, "license", "", "Apryse SDK license")
	flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse resources")
}

//-----------------------------------------------------------------------------------------
// The sample code illustrates how to create a PDF document from scratch using the
// flow docoment API. It also demonstrates how to create tables and lists, and how to modify
// the content tree.
//-----------------------------------------------------------------------------------------

// Relattive path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func modifyContentTree(node ContentNode) {
	bold := false
	itr := node.GetContentNodeIterator()

	for itr.HasNext() {
		el := itr.Current()
		itr.Next()

		tr := el.AsTextRun()
		if tr != nil {
			st := tr.GetTextStyledElement()
			if bold {
				st.SetBold(true)
				st.SetFontSize(st.GetFontSize() * 0.8)
			}
			bold = !bold
			continue
		}

		cn := el.AsContentNode()
		if cn != nil {
			modifyContentTree(cn)
		}
	}
}

func TestDocumentCreation(t *testing.T) {
	PDFNetInitialize(licenseKey)
	PDFNetSetResourcesPath(modulePath)
	defer PDFNetTerminate()

	result := true

	outputPath := "../TestFiles/Output/"
	outputName := "created_doc.pdf"

	paraText := "Lorem ipsum dolor " +
		"sit amet, consectetur adipisicing elit, sed " +
		"do eiusmod tempor incididunt ut labore " +
		"et dolore magna aliqua. Ut enim ad " +
		"minim veniam, quis nostrud exercitation " +
		"ullamco laboris nisi ut aliquip ex ea " +
		"commodo consequat. Duis aute irure " +
		"dolor in reprehenderit in voluptate velit " +
		"esse cillum dolore eu fugiat nulla pariatur. " +
		"Excepteur sint occaecat cupidatat " +
		"non proident, sunt in culpa qui officia " +
		"deserunt mollit anim id est laborum."

	defer func() {
		if !result {
			fmt.Println("Tests FAILED!!!\n==========")
		} else {
			fmt.Println("Tests successful.\n==========")
		}
	}()

	flowdoc := NewFlowDocument()

	// ------------------------------------------------
	// First styled paragraph
	// ------------------------------------------------
	para := flowdoc.AddParagraph()
	stPara := para.GetTextStyledElement()

	stPara.SetFontSize(24)
	stPara.SetTextColor(255, 0, 0)
	para.AddText("Start \tRed \tText\n")

	para.AddTabStop(150)
	para.AddTabStop(250)
	stPara.SetTextColor(0, 0, 255)
	para.AddText("Start \tBlue \tText\n")

	lastRun := para.AddText("Start Green Text\n")

	start := true
	itr := para.GetContentNodeIterator()
	for itr.HasNext() {
		el := itr.Current()
		run := el.AsTextRun()
		if run != nil {
			st := run.GetTextStyledElement()
			st.SetFontSize(12)
			if start {
				start = false
				run.SetText(run.GetText() + "(restored \tred \tcolor)\n")
				st.SetTextColor(255, 0, 0)
			}
		}
		itr.Next()
	}

	stLast := lastRun.GetTextStyledElement()
	stLast.SetTextColor(0, 255, 0)
	stLast.SetItalic(true)
	stLast.SetFontSize(18)

	para.GetTextStyledElement().SetBold(true)
	para.SetBorder(0.2, 0, 127, 0)
	stLast.SetBold(false)

	// ------------------------------------------------
	// Create lists
	// ------------------------------------------------
	flowdoc.AddParagraph("Simple list creation process. All elements are added in their natural order\n\n")

	list := flowdoc.AddList()
	list.SetNumberFormat(ListE_upper_letter)
	list.SetStartIndex(4)

	item := list.AddItem()
	item.AddParagraph("item 0[0]")
	px := item.AddParagraph("item 0[1]")
	xx := px.GetTextStyledElement()
	xx.SetTextColor(255, 99, 71)
	px.AddText(" Some More Text!")

	item2 := list.AddItem()
	item2List := item2.AddList()
	item2List.SetStartIndex(0)
	item2List.SetNumberFormat(ListE_decimal, "", true)

	item2List.AddItem().AddParagraph("item 1[0].0")
	pp := item2List.AddItem().AddParagraph("item 1[0].1")
	sx := pp.GetTextStyledElement()
	sx.SetTextColor(0, 0, 255)
	pp.AddText(" Some More Text")
	item2List.AddItem().AddParagraph("item 1[0].2")

	item2List1 := item2List.AddItem().AddList()
	item2List1.SetStartIndex(7)
	item2List1.SetNumberFormat(ListE_upper_roman, ")", true)
	item2List1.AddItem().AddParagraph("item 1[0].3.0")
	item2List1.AddItem().AddParagraph("item 1[0].3.1")

	extraItem := item2List1.AddItem()
	extraItem.AddParagraph("item 1[0].3.2[0]")
	extraItem.AddParagraph("item 1[0].3.2[1]")
	fourth := extraItem.AddList()
	fourth.SetNumberFormat(ListE_decimal, "", true)
	fourth.AddItem().AddParagraph("Fourth Level")

	fourth = item2List1.AddItem().AddList()
	fourth.SetNumberFormat(ListE_lower_letter, "", true)
	fourth.AddItem().AddParagraph("Fourth Level (again)")

	item2.AddParagraph("item 1[1]")
	item2List2 := item2.AddList()
	item2List2.SetStartIndex(10)
	item2List2.SetNumberFormat(ListE_lower_roman)
	item2List2.AddItem().AddParagraph("item 1[2].0")
	item2List2.AddItem().AddParagraph("item 1[2].1")
	item2List2.AddItem().AddParagraph("item 1[2].2")

	list.AddItem().AddParagraph("item 2") // creates "F."
	list.AddItem().AddParagraph("item 3") // creates "G."
	list.AddItem().AddParagraph("item 4") // creates "H."

	itr = flowdoc.GetBody().GetContentNodeIterator()
	for itr.HasNext() {
		el := itr.Current()

		if ls := el.AsList(); ls != nil {
			if ls.GetIndentationLevel() == 1 {
				p := ls.AddItem().AddParagraph("Item added during iteration")
				ps := p.GetTextStyledElement()
				ps.SetTextColor(0, 127, 0)
			}
		}

		if li := el.AsListItem(); li != nil {
			if li.GetIndentationLevel() == 2 {
				p := li.AddParagraph("* Paragraph added during iteration")
				ps := p.GetTextStyledElement()
				ps.SetTextColor(0, 0, 255)
			}
		}

		itr.Next()
	}

	flowdoc.AddParagraph("\f")

	// ------------------------------------------------------------------------
	// Nonlinear list creation flow
	// ------------------------------------------------------------------------

	flowdoc.AddParagraph(
		"Nonlinear list creation flow. Items are added randomly." +
			" List body separated by a paragraph, does not belong to the list\n\n",
	)

	nllist := flowdoc.AddList()
	nllist.SetNumberFormat(ListE_upper_letter)
	nllist.SetStartIndex(4)

	// ---- Item D
	nlitem := nllist.AddItem() // creates "D."
	nlitem.AddParagraph("item 0[0]")
	nlpx := nlitem.AddParagraph("item 0[1]")
	nlxxPara := nlpx.GetTextStyledElement()
	nlxxPara.SetTextColor(255, 99, 71)
	nlpx.AddText(" Some More Text!")
	nlitem.AddParagraph("item 0[2]")
	nlpx = nlitem.AddParagraph("item 0[3]")
	nlitem.AddParagraph("item 0[4]")
	nlxxPara = nlpx.GetTextStyledElement()
	nlxxPara.SetTextColor(255, 99, 71)

	// ---- Item E
	nlitem2 := nllist.AddItem() // creates "E."
	nlitem2List := nlitem2.AddList()
	nlitem2List.SetStartIndex(0)
	nlitem2List.SetNumberFormat(ListE_decimal, "", true)

	nlitem2List.AddItem().AddParagraph("item 1[0].0")
	nlpp := nlitem2List.AddItem().AddParagraph("item 1[0].1")
	nlsxPara := nlpp.GetTextStyledElement()
	nlsxPara.SetTextColor(0, 0, 255)
	nlpp.AddText(" Some More Text")

	// ---- Item F (added before finishing item E lists)
	nlitem3 := nllist.AddItem() // creates "F."
	nlitem3.AddParagraph("item 2")

	// Continue nested list under item E
	nlitem2List.AddItem().AddParagraph("item 1[0].2")

	nlitem2.AddParagraph("item 1[1]")
	nlitem2List2 := nlitem2.AddList()
	nlitem2List2.SetStartIndex(10)
	nlitem2List2.SetNumberFormat(ListE_lower_roman)
	nlitem2List2.AddItem().AddParagraph("item 1[2].0")
	nlitem2List2.AddItem().AddParagraph("item 1[2].1")
	nlitem2List2.AddItem().AddParagraph("item 1[2].2")

	// ---- Item G
	nlitem4 := nllist.AddItem() // creates "G."
	nlitem4.AddParagraph("item 3")

	// ---- Deeper nesting inside item2List
	nlitem2List1 := nlitem2List.AddItem().AddList()
	nlitem2List1.SetStartIndex(7)
	nlitem2List1.SetNumberFormat(ListE_upper_roman, ")", true)
	nlitem2List1.AddItem().AddParagraph("item 1[0].3.0")

	// Split list flow with a separating paragraph
	flowdoc.AddParagraph(
		"---------------------------------- splitting paragraph ----------------------------------",
	)

	// Continue the same list after the paragraph
	nlitem2List1.ContinueList()

	nlitem2List1.AddItem().AddParagraph("item 1[0].3.1 (continued)")
	nlextraItem := nlitem2List1.AddItem()
	nlextraItem.AddParagraph("item 1[0].3.2[0]")
	nlextraItem.AddParagraph("item 1[0].3.2[1]")

	nlfourth := nlextraItem.AddList()
	nlfourth.SetNumberFormat(ListE_decimal, "", true)
	nlfourth.AddItem().AddParagraph("FOURTH LEVEL")

	// ---- Item H
	nlitem5 := nllist.AddItem() // creates "H."
	nlitem5.AddParagraph("item 4 (continued)")

	flowdoc.AddParagraph(" ")

	// ------------------------------------------------------------------------
	// Page setup
	// ------------------------------------------------------------------------
	flowdoc.SetDefaultMargins(72.0, 72.0, 144.0, 228.0)
	flowdoc.SetDefaultPageSize(650, 750)

	flowdoc.AddParagraph(paraText)

	// ------------------------------------------------
	// Style demo paragraphs
	// ------------------------------------------------
	clr1 := [3]byte{50, 50, 199}
	clr2 := [3]byte{30, 199, 30}

	for i := 0; i < 50; i++ {
		para := flowdoc.AddParagraph()
		st := para.GetTextStyledElement()
		pointSize := float64((17*i*i*i)%13 + 5)

		if i%2 == 0 {
			st.SetItalic(true)
			st.SetTextColor(clr1[0], clr1[1], clr1[2])
			st.SetBackgroundColor(200, 200, 200)
			para.SetSpaceBefore(20)
			para.SetStartIndent(20)
			para.SetJustificationMode(ParagraphE_text_justify_left)
		} else {
			st.SetTextColor(clr2[0], clr2[1], clr2[2])
			para.SetSpaceBefore(50)
			para.SetEndIndent(20)
			para.SetJustificationMode(ParagraphE_text_justify_right)
		}

		para.AddText(paraText)
		para.AddText(" " + paraText)
		st.SetFontSize(pointSize)
	}

	// ------------------------------------------------
	// Table creation
	// ------------------------------------------------
	newTable := flowdoc.AddTable()
	newTable.SetDefaultColumnWidth(100)
	newTable.SetDefaultRowHeight(15)

	for i := 0; i < 4; i++ {
		row := newTable.AddTableRow()
		row.SetRowHeight(newTable.GetDefaultRowHeight() + float64(i*5))

		for j := 0; j < 5; j++ {
			cell := row.AddTableCell()
			cell.SetBorder(0.5, 255, 0, 0)

			if i == 3 {
				if j%2 != 0 {
					cell.SetVerticalAlignment(TableCellE_alignment_center)
				} else {
					cell.SetVerticalAlignment(TableCellE_alignment_bottom)
				}
			}

			if i == 3 && j == 4 {
				p := cell.AddParagraph("Table title")
				p.SetJustificationMode(ParagraphE_text_justify_center)

				nested := cell.AddTable()
				nested.SetDefaultColumnWidth(33)
				nested.SetDefaultRowHeight(5)
				nested.SetBorder(0.5, 0, 0, 0)

				for r := 0; r < 3; r++ {
					nr := nested.AddTableRow()
					for c := 0; c < 3; c++ {
						nc := nr.AddTableCell()
						nc.SetBackgroundColor(200, 200, 255)
						nc.SetBorder(0.1, 0, 255, 0)
						np := nc.AddParagraph(fmt.Sprintf("%d/%d", r, c))
						np.SetJustificationMode(ParagraphE_text_justify_right)
					}
				}
			} else if i == 2 && j == 2 {
				p := cell.AddParagraph(fmt.Sprintf("Cell %d x %d\n", j, i))
				p.AddText("to be bold text 1\n")
				p.AddText("still normal text\n")
				p.AddText("to be bold text 2")
				cell.AddParagraph("Second Paragraph")
			} else {
				cell.AddParagraph(fmt.Sprintf("Cell %d x %d", j, i))
			}
		}
	}

	// ------------------------------------------------
	// Modify content tree
	// ------------------------------------------------
	modifyContentTree(flowdoc.GetBody())

	// ------------------------------------------------
	// Merge table cells
	// ------------------------------------------------
	merged := newTable.GetTableCell(2, 0).MergeCellsRight(1)
	merged.SetHorizontalAlignment(TableCellE_alignment_middle)

	newTable.GetTableCell(0, 0).MergeCellsDown(1).SetVerticalAlignment(TableCellE_alignment_center)

	// ------------------------------------------------
	// Walk table rows and adjust colors + text
	// ------------------------------------------------
	rowIdx := 0
	clrRow1 := [3]byte{175, 240, 240}
	clrRow2 := [3]byte{250, 250, 175}

	tableItr := newTable.GetContentNodeIterator()
	for tableItr.HasNext() {
		row := tableItr.Current().AsTableRow()
		if row != nil {
			rowItr := row.GetContentNodeIterator()
			for rowItr.HasNext() {
				cell := rowItr.Current().AsTableCell()
				if cell != nil {
					if rowIdx%2 != 0 {
						cell.SetBackgroundColor(clrRow1[0], clrRow1[1], clrRow1[2])
					} else {
						cell.SetBackgroundColor(clrRow2[0], clrRow2[1], clrRow2[2])
					}

					cellItr := cell.GetContentNodeIterator()
					for cellItr.HasNext() {
						element := cellItr.Current()

						if p := element.AsParagraph(); p != nil {
							st := p.GetTextStyledElement()
							st.SetTextColor(255, 0, 0)
							st.SetFontSize(12)
						} else if nt := element.AsTable(); nt != nil {
							nestedCell := nt.GetTableCell(1, 1)
							nestedCell.SetBackgroundColor(255, 127, 127)
						}

						cellItr.Next()
					}
				}
				rowItr.Next()
			}
		}
		rowIdx++
		tableItr.Next()
	}

	// ------------------------------------------------
	// Finish and save
	// ------------------------------------------------
	pdf := flowdoc.PaginateToPDF()
	pdf.Save(outputPath+outputName, uint(SDFDocE_linearized))
}
