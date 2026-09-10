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
// The following sample illustrates how to use the FlowDocument API to create documents from
// scratch. Instead of positioning every element on a page, the content is described as a
// tree of paragraphs, tables, lists, shapes, charts and floats, which is then paginated
// into a PDF document.
//
// Each function below produces one document:
//   * an invoice          - tables, cell merging, styling, headers/footers, images
//   * a report            - sections, page setup, lists, charts, page numbers
//   * a newsletter        - shapes, shape text boxes, floats, hyperlinks, tab stops
//   * a content tree walk - post-processing of an existing content tree
//-----------------------------------------------------------------------------------------

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func moneyToString(val float64) string {
	return fmt.Sprintf("$%.2f", val)
}

//-----------------------------------------------------------------------------------
// Small helpers shared by the samples below.
//-----------------------------------------------------------------------------------

// Adds a paragraph with the given text and applies a simple heading style.
func addHeading(container ContentContainer, text string, fontSize float64,
	red byte, green byte, blue byte) Paragraph {
	heading := container.AddParagraph(text)
	style := heading.GetTextStyledElement()
	style.SetFontSize(fontSize)
	style.SetBold(true)
	style.SetTextColor(red, green, blue)
	heading.SetSpaceBefore(12)
	heading.SetSpaceAfter(6)
	return heading
}

// Adds a single table row filled with the given texts.
func addTableRowWithText(table Table, texts []string, bold bool,
	backRed byte, backGreen byte, backBlue byte) TableRow {
	row := table.AddTableRow()
	for i, text := range texts {
		cell := row.AddTableCell()
		cell.SetBackgroundColor(backRed, backGreen, backBlue)
		cell.SetVerticalAlignment(TableCellE_alignment_center)

		para := cell.AddParagraph(text)
		para.SetStartIndent(3)
		style := para.GetTextStyledElement()
		style.SetFontSize(10)
		style.SetBold(bold)

		// Right align everything but the first (description) column.
		if i == 0 {
			para.SetJustificationMode(ParagraphE_text_justify_left)
		} else {
			para.SetJustificationMode(ParagraphE_text_justify_right)
		}
	}
	return row
}

// Adds a "Page X of Y" footer to the given section, for all page groups.
func addPageNumberFooter(section Section, title string) {
	groups := []PdftronLayoutSectionPageGroup{
		SectionE_first_page, SectionE_even_pages, SectionE_odd_pages}

	for _, group := range groups {
		footer := section.GetOrCreateFooter(group)

		para := footer.AddParagraph()
		para.SetJustificationMode(ParagraphE_text_justify_center)

		style := para.GetTextStyledElement()
		style.SetFontSize(9)
		style.SetTextColor(120, 120, 120)
		style.SetItalic(true)

		para.AddText(title + "   |   Page ")
		para.AddPageNumber(PageNumberE_current_page)
		para.AddText(" of ")
		para.AddPageNumber(PageNumberE_total_pages)
	}
}

//-----------------------------------------------------------------------------------
// (1) An invoice: a header with a logo float, an addresses table, a line item table
// with merged cells and a totals block.
//-----------------------------------------------------------------------------------

func createInvoice() {
	doc := NewFlowDocument()
	doc.SetDefaultPageSize(612, 792) // US Letter, in points.
	doc.SetDefaultMargins(54, 54, 54, 54)

	section := doc.GetCurrentSection()

	// --- Header ---------------------------------------------------------------
	header := section.GetOrCreateHeader(SectionE_odd_pages)
	headerPara := header.AddParagraph("SYH Supply Co.")
	headerPara.SetJustificationMode(ParagraphE_text_justify_right)
	headerPara.GetTextStyledElement().SetFontSize(9)
	headerPara.GetTextStyledElement().SetTextColor(120, 120, 120)

	addPageNumberFooter(section, "Invoice INV-2025-0042")

	// --- Title, with the company logo floated to the right --------------------
	title := doc.AddParagraph()

	// A float takes its content out of the main flow and positions it relative to
	// a reference point, with the document content wrapped around it.
	logoFloat := title.AddFloat()
	logoFloat.SetHorizontalReferencePoint(FloatE_reference_page)
	logoFloat.SetVerticalReferencePoint(FloatE_reference_paragraph)
	logoFloat.SetPositionX(400)
	logoFloat.SetPositionY(0)
	logoFloat.SetObstructionType(FloatE_square)
	// AddImage is overloaded, so the sizes need an explicit float64 type here.
	logoFloat.AddParagraph().AddImage(float64(96), float64(96), inputPath+"logo_red.png")

	title.AddText("INVOICE")
	titleStyle := title.GetTextStyledElement()
	titleStyle.SetFontSize(28)
	titleStyle.SetBold(true)
	titleStyle.SetTextColor(0, 51, 102)

	subtitle := doc.AddParagraph(
		"Invoice #INV-2025-0042\nIssued: March 14, 2025\nDue: April 13, 2025")
	subtitle.GetTextStyledElement().SetFontSize(10)
	subtitle.SetSpaceAfter(18)

	// --- Bill to / ship to ----------------------------------------------------
	addresses := doc.AddTable()
	addresses.SetDefaultColumnWidth(240)
	addresses.SetDefaultRowHeight(16)

	addressRow := addresses.AddTableRow()
	addressTitles := []string{"BILL TO", "SHIP TO"}
	addressBodies := []string{
		"Contoso Ltd.\n123 Maple Street\nVancouver, BC V6B 1A1\nCanada",
		"Contoso Warehouse #4\n980 Industrial Way\nBurnaby, BC V5J 3J1\nCanada"}

	for i := 0; i < 2; i++ {
		cell := addressRow.AddTableCell()
		cell.SetBackgroundColor(240, 244, 248)
		cell.SetBorder(0.5, 200, 210, 220)

		caption := cell.AddParagraph(addressTitles[i])
		caption.SetStartIndent(3)
		captionStyle := caption.GetTextStyledElement()
		captionStyle.SetFontSize(9)
		captionStyle.SetBold(true)
		captionStyle.SetTextColor(0, 51, 102)

		body := cell.AddParagraph(addressBodies[i])
		body.SetStartIndent(3)
		body.GetTextStyledElement().SetFontSize(10)
	}

	doc.AddParagraph(" ")

	// --- Line items -----------------------------------------------------------
	items := doc.AddTable()
	items.SetDefaultColumnWidth(120)
	items.SetDefaultRowHeight(18)
	items.SetBorder(0.75, 0, 51, 102)

	headers := []string{"Description", "Qty", "Unit price", "Amount"}
	headerRow := addTableRowWithText(items, headers, true, 0, 51, 102)

	// Make the header row text white by walking the row we have just created.
	cellItr := headerRow.GetContentNodeIterator()
	for cellItr.HasNext() {
		if cell := cellItr.Current().AsTableCell(); cell != nil {
			paraItr := cell.GetContentNodeIterator()
			for paraItr.HasNext() {
				if para := paraItr.Current().AsParagraph(); para != nil {
					para.GetTextStyledElement().SetTextColor(255, 255, 255)
				}
				paraItr.Next()
			}
		}
		cellItr.Next()
	}

	lineDescriptions := []string{
		"Height adjustable desk, oak finish",
		"Ergonomic office chair",
		"Meeting room whiteboard, 180 cm",
		"On-site assembly and delivery"}
	lineQuantities := []int{2, 5, 1, 1}
	linePrices := []float64{4800.00, 950.00, 1200.00, 2500.00}
	numLineItems := len(lineDescriptions)

	subtotal := 0.0
	for i := 0; i < numLineItems; i++ {
		amount := float64(lineQuantities[i]) * linePrices[i]
		subtotal += amount

		cells := []string{
			lineDescriptions[i],
			fmt.Sprintf("%d", lineQuantities[i]),
			moneyToString(linePrices[i]),
			moneyToString(amount)}

		// Alternating row background for readability.
		if i%2 == 0 {
			addTableRowWithText(items, cells, false, 255, 255, 255)
		} else {
			addTableRowWithText(items, cells, false, 240, 244, 248)
		}
	}

	tax := subtotal * 0.12

	totalLabels := []string{"Subtotal", "GST/PST (12%)", "Total due (CAD)"}
	totalValues := []float64{subtotal, tax, subtotal + tax}
	totalBold := []bool{false, false, true}

	for i := 0; i < len(totalLabels); i++ {
		cells := []string{"", "", totalLabels[i], moneyToString(totalValues[i])}
		addTableRowWithText(items, cells, totalBold[i], 255, 255, 255)

		// Merge the two empty leading cells of the totals row.
		items.GetTableCell(0, uint(numLineItems+1+i)).MergeCellsRight(1)
	}

	notes := doc.AddParagraph(
		"Payment is due within 30 days. Late payments are subject to a 1.5% monthly " +
			"interest charge. Please reference the invoice number with your payment.")
	notes.SetSpaceBefore(24)
	notes.GetTextStyledElement().SetFontSize(9)
	notes.GetTextStyledElement().SetItalic(true)
	notes.GetTextStyledElement().SetTextColor(90, 90, 90)

	signature := doc.AddParagraph()
	signature.SetSpaceBefore(18)
	signature.AddImage(float64(140), float64(50), inputPath+"signature.jpg")
	signature.AddText("\nAuthorized signature")

	pdf := doc.PaginateToPDF()
	pdf.Save(outputPath+"created_invoice.pdf", uint(SDFDocE_linearized))
	pdf.Close()
	fmt.Println("Saved created_invoice.pdf")
}

//-----------------------------------------------------------------------------------
// (2) A two page report. The first page (portrait) holds a data table, the second one
// is a separate landscape section holding a chart.
//-----------------------------------------------------------------------------------

func createReportWithChart() {
	doc := NewFlowDocument()
	doc.SetDefaultPageSize(612, 792)
	doc.SetDefaultMargins(72, 72, 72, 72)

	//--- Page 1: portrait section with the data table --------------------------
	dataSection := doc.GetCurrentSection()
	addPageNumberFooter(dataSection, "Quarterly Revenue Report")

	addHeading(doc, "Quarterly Revenue Report 2025", 22, 0, 51, 102)

	intro := doc.AddParagraph(
		"The table below summarizes the revenue by region for the first three quarters " +
			"of the fiscal year. All figures are given in thousands of Canadian dollars " +
			"and exclude intercompany transactions.")
	intro.GetTextStyledElement().SetFontSize(11)
	intro.SetSpaceAfter(12)

	table := doc.AddTable()
	table.SetDefaultColumnWidth(90)
	table.SetDefaultRowHeight(18)
	table.SetBorder(0.75, 120, 120, 120)

	headerCells := []string{"Region", "Q1", "Q2", "Q3", "Total"}
	addTableRowWithText(table, headerCells, true, 220, 230, 240)

	regionNames := []string{"North America", "Europe", "Asia Pacific", "Latin America"}
	regionValues := [][]int{
		{1250, 1410, 1580},
		{910, 980, 1120},
		{640, 720, 905},
		{310, 355, 390}}

	totals := []int{0, 0, 0}
	for i := 0; i < len(regionNames); i++ {
		totals[0] += regionValues[i][0]
		totals[1] += regionValues[i][1]
		totals[2] += regionValues[i][2]

		rowTotal := regionValues[i][0] + regionValues[i][1] + regionValues[i][2]
		cells := []string{
			regionNames[i],
			fmt.Sprintf("%d", regionValues[i][0]),
			fmt.Sprintf("%d", regionValues[i][1]),
			fmt.Sprintf("%d", regionValues[i][2]),
			fmt.Sprintf("%d", rowTotal)}
		addTableRowWithText(table, cells, false, 255, 255, 255)
	}

	totalCells := []string{"All regions",
		fmt.Sprintf("%d", totals[0]),
		fmt.Sprintf("%d", totals[1]),
		fmt.Sprintf("%d", totals[2]),
		fmt.Sprintf("%d", totals[0]+totals[1]+totals[2])}
	addTableRowWithText(table, totalCells, true, 240, 240, 240)

	addHeading(doc, "Key observations", 14, 0, 51, 102)

	observations := doc.AddList()
	observations.SetNumberFormat(ListE_decimal, ".", true)
	observations.GetLabelStyle().SetBold(true)
	observations.AddItem().AddParagraph(
		"Revenue grew in every region, with Asia Pacific showing the strongest " +
			"quarter over quarter growth.")
	observations.AddItem().AddParagraph(
		"North America remains the largest market, contributing roughly 40% of " +
			"the total revenue.")

	risks := observations.AddItem()
	risks.AddParagraph("Risks that may affect the Q4 forecast:")
	riskList := risks.AddList()
	riskList.SetNumberFormat(ListE_lower_letter, ")", true)
	riskList.AddItem().AddParagraph("Currency fluctuations in Latin America.")
	riskList.AddItem().AddParagraph("Longer sales cycles in the enterprise segment.")

	//--- Page 2: landscape section with the chart ------------------------------
	chartSection := doc.AddSection()
	chartSection.SetPageSize(792, 612) // landscape
	chartSection.SetMargins(54, 54, 54, 54)
	addPageNumberFooter(chartSection, "Quarterly Revenue Report")

	addHeading(doc, "Revenue by region and quarter", 18, 0, 51, 102)

	// A chart is described by a JSON definition string.
	chartDefinition := `{
		"chartType": "bar",
		"title": "Revenue by region (thousands CAD)",
		"theme": "vivid",
		"data": {
			"categories": { "data": ["Q1", "Q2", "Q3"] },
			"series": [
				{ "name": { "data": ["North America"] }, "data": { "data": [1250, 1410, 1580] } },
				{ "name": { "data": ["Europe"] }, "data": { "data": [910, 980, 1120] } },
				{ "name": { "data": ["Asia Pacific"] }, "data": { "data": [640, 720, 905] } },
				{ "name": { "data": ["Latin America"] }, "data": { "data": [310, 355, 390] } }
			]
		}
	}`

	chartPara := doc.AddParagraph()
	chartPara.SetJustificationMode(ParagraphE_text_justify_center)
	chart := chartPara.AddChart(560, 340, chartDefinition)
	chart.SetWidth(600)
	chart.SetHeight(360)

	caption := doc.AddParagraph(
		"Figure 1: revenue distribution across the four sales regions.")
	caption.SetJustificationMode(ParagraphE_text_justify_center)
	caption.GetTextStyledElement().SetItalic(true)
	caption.GetTextStyledElement().SetFontSize(10)

	fmt.Printf("Report sections: %d, second section page width: %g\n",
		doc.GetNumSections(), doc.GetSection(1).GetPageWidth())

	pdf := doc.PaginateToPDF()
	pdf.Save(outputPath+"created_report.pdf", uint(SDFDocE_linearized))
	pdf.Close()
	fmt.Println("Saved created_report.pdf")
}

//-----------------------------------------------------------------------------------
// (3) A newsletter demonstrating shapes, shape text boxes, floats, hyperlinks and
// paragraph styling such as indents, tab stops and justification.
//-----------------------------------------------------------------------------------

func createNewsletter() {
	bodyText := "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod " +
		"tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, " +
		"quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo " +
		"consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse " +
		"cillum dolore eu fugiat nulla pariatur."

	doc := NewFlowDocument()
	doc.SetDefaultPageSize(612, 792)
	doc.SetDefaultMargins(60, 60, 60, 60)

	section := doc.GetCurrentSection()
	addPageNumberFooter(section, "The Monthly Dispatch")

	// Masthead built from a rounded rectangle shape with a text box inside.
	mastheadPara := doc.AddParagraph()
	masthead := mastheadPara.AddShape(ShapeE_rectangle_rounded_corners, 492, 70)
	masthead.SetCornerRadius(10)
	masthead.SetBackgroundColor(0, 51, 102)
	masthead.SetOutlineColor(0, 31, 62)
	masthead.SetOutlineThickness(1.5)

	mastheadText := masthead.GetTextBox()
	mastheadTitle := mastheadText.AddParagraph("The Monthly Dispatch")
	mastheadTitle.SetJustificationMode(ParagraphE_text_justify_center)
	mastheadStyle := mastheadTitle.GetTextStyledElement()
	mastheadStyle.SetFontSize(24)
	mastheadStyle.SetBold(true)
	mastheadStyle.SetTextColor(255, 255, 255)

	mastheadSub := mastheadText.AddParagraph("Issue 42 - March 2025")
	mastheadSub.SetJustificationMode(ParagraphE_text_justify_center)
	mastheadSub.GetTextStyledElement().SetFontSize(10)
	mastheadSub.GetTextStyledElement().SetTextColor(200, 215, 230)

	// Lead story with a pull quote floated next to it.
	addHeading(doc, "Documents, assembled", 16, 0, 51, 102)

	lead := doc.AddParagraph()
	lead.SetJustificationMode(ParagraphE_text_justify_left)
	lead.SetTextIndent(18)
	lead.SetSpaceAfter(10)

	pullQuote := lead.AddFloat()
	pullQuote.SetHorizontalReferencePoint(FloatE_reference_page)
	pullQuote.SetVerticalReferencePoint(FloatE_reference_paragraph)
	pullQuote.SetPositionX(380)
	pullQuote.SetPositionY(10)
	pullQuote.SetObstructionType(FloatE_square)

	quoteHolder := pullQuote.AddParagraph()
	quoteBox := quoteHolder.AddShape(ShapeE_rectangle_rounded_corners, 190, 70)
	quoteBox.SetCornerRadius(6)
	quoteBox.SetBackgroundColor(240, 246, 255)
	quoteBox.SetOutlineColor(0, 51, 102)
	quoteBox.SetOutlineThickness(1.0)

	quoteText := quoteBox.GetTextBox()
	quote := quoteText.AddParagraph(
		"\"The content tree lets you describe a document, not a page.\"")
	quote.SetStartIndent(6)
	quote.SetEndIndent(6)
	quoteStyle := quote.GetTextStyledElement()
	quoteStyle.SetFontSize(12)
	quoteStyle.SetItalic(true)
	quoteStyle.SetTextColor(0, 51, 102)

	lead.AddText(bodyText)
	lead.AddText(" Read more about the API at ")
	link := lead.AddHyperlink("apryse.com", "https://www.apryse.com")
	link.GetTextStyledElement().SetTextColor(0, 102, 204)
	lead.AddText(".")

	// Two "columns" of text, created with complementary indents.
	columnLeft := doc.AddParagraph(bodyText)
	columnLeft.SetStartIndent(0)
	columnLeft.SetEndIndent(260)
	columnLeft.GetTextStyledElement().SetFontSize(10)

	columnRight := doc.AddParagraph(bodyText)
	columnRight.SetStartIndent(260)
	columnRight.SetEndIndent(0)
	columnRight.GetTextStyledElement().SetFontSize(10)

	// A schedule built with tab stops instead of a table.
	addHeading(doc, "Upcoming webinars", 14, 0, 51, 102)

	schedule := [][]string{
		{"Apr 02", "Building documents from scratch", "R. Fischer"},
		{"Apr 16", "Charts and data visualization", "M. Okafor"},
		{"Apr 30", "Accessible PDF output", "L. Tanaka"}}

	for _, webinar := range schedule {
		row := doc.AddParagraph()
		row.AddTabStop(80)
		row.AddTabStop(360)
		row.GetTextStyledElement().SetFontSize(10)
		row.AddText(webinar[0] + "\t" + webinar[1] + "\t" + webinar[2])
	}

	// A decorative arrow and a photo, both anchored in a single paragraph.
	gallery := doc.AddParagraph()
	gallery.SetSpaceBefore(16)
	gallery.SetJustificationMode(ParagraphE_text_justify_center)

	arrow := gallery.AddShape(ShapeE_arrow, 90, 40)
	arrow.SetBackgroundColor(0, 153, 102)
	arrow.SetOutlineColor(0, 102, 68)
	arrow.SetOutlineThickness(1)
	arrow.SetArrowHeadSize(18)

	gallery.AddText("   ")
	gallery.AddImage(float64(160), float64(120), inputPath+"butterfly.png")

	pdf := doc.PaginateToPDF()
	pdf.Save(outputPath+"created_newsletter.pdf", uint(SDFDocE_linearized))
	pdf.Close()
	fmt.Println("Saved created_newsletter.pdf")
}

//-----------------------------------------------------------------------------------
// (4) Post-processing: build a simple document and then walk its content tree,
// restyling the elements that are found along the way.
//-----------------------------------------------------------------------------------

// Recursively walks the content tree, highlighting every second text run and
// outlining the cells of any table that is encountered.
func restyleContentTree(node ContentNode, highlight bool) bool {
	itr := node.GetContentNodeIterator()
	for itr.HasNext() {
		el := itr.Current()
		itr.Next()

		if textRun := el.AsTextRun(); textRun != nil {
			if highlight {
				style := textRun.GetTextStyledElement()
				style.SetBold(true)
				style.SetBackgroundColor(255, 245, 180)
			}
			highlight = !highlight
			continue
		}

		if cell := el.AsTableCell(); cell != nil {
			cell.SetBorder(0.5, 150, 150, 150)
		}

		if child := el.AsContentNode(); child != nil {
			highlight = restyleContentTree(child, highlight)
		}
	}
	return highlight
}

func restyleExistingContent() {
	doc := NewFlowDocument()
	doc.SetDefaultPageSize(612, 792)
	doc.SetDefaultMargins(72, 72, 72, 72)

	addHeading(doc, "Content tree post-processing", 18, 0, 51, 102)

	for i := 0; i < 4; i++ {
		para := doc.AddParagraph()
		para.SetSpaceAfter(8)
		para.AddText(fmt.Sprintf("Sentence %d. ", i*2))
		para.AddText(fmt.Sprintf("Sentence %d. ", i*2+1))
		para.AddText("The style of these runs is decided after the fact.")
	}

	table := doc.AddTable()
	table.SetDefaultColumnWidth(150)
	table.SetDefaultRowHeight(16)

	for rowIndex := 0; rowIndex < 3; rowIndex++ {
		row := table.AddTableRow()
		for colIndex := 0; colIndex < 3; colIndex++ {
			cell := row.AddTableCell()
			cell.AddParagraph(fmt.Sprintf("R%d / C%d", rowIndex, colIndex))
		}
	}

	restyleContentTree(doc, false)

	fmt.Printf("Table has %d rows and %d columns.\n",
		table.GetNumRows(), table.GetNumColumns())

	pdf := doc.PaginateToPDF()
	pdf.Save(outputPath+"created_restyled.pdf", uint(SDFDocE_linearized))
	pdf.Close()
	fmt.Println("Saved created_restyled.pdf")
}

func TestDocumentCreation(t *testing.T) {
	PDFNetInitialize(licenseKey)
	PDFNetSetResourcesPath(modulePath)
	defer PDFNetTerminate()

	createInvoice()
	createReportWithChart()
	createNewsletter()
	restyleExistingContent()

	fmt.Println("Done.")
}
