#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the FlowDocument API to create documents
# from scratch. Instead of positioning every element on a page, the content is described
# as a tree of paragraphs, tables, lists, shapes, charts and floats, which is then
# paginated into a PDF document.
#
# Each function below produces one document:
#   * an invoice          - tables, cell merging, styling, headers/footers, images
#   * a report            - sections, page setup, lists, charts, page numbers
#   * a newsletter        - shapes, shape text boxes, floats, hyperlinks, tab stops
#   * a content tree walk - post-processing of an existing content tree
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"


def money_to_string(val):
    return "$%.2f" % val


#-----------------------------------------------------------------------------------
# Small helpers shared by the samples below.
#-----------------------------------------------------------------------------------

# Adds a paragraph with the given text and applies a simple heading style.
def add_heading(container, text, font_size, red, green, blue):
    heading = container.AddParagraph(text)
    style = heading.GetTextStyledElement()
    style.SetFontSize(font_size)
    style.SetBold(True)
    style.SetTextColor(red, green, blue)
    heading.SetSpaceBefore(12)
    heading.SetSpaceAfter(6)
    return heading


# Adds a single table row filled with the given texts.
def add_table_row_with_text(table, texts, bold, back_red, back_green, back_blue):
    row = table.AddTableRow()
    for i, text in enumerate(texts):
        cell = row.AddTableCell()
        cell.SetBackgroundColor(back_red, back_green, back_blue)
        cell.SetVerticalAlignment(TableCell.e_alignment_center)

        para = cell.AddParagraph(text)
        para.SetStartIndent(3)
        style = para.GetTextStyledElement()
        style.SetFontSize(10)
        style.SetBold(bold)

        # Right align everything but the first (description) column.
        para.SetJustificationMode(Paragraph.e_text_justify_left if i == 0
                                  else Paragraph.e_text_justify_right)
    return row


# Adds a "Page X of Y" footer to the given section, for all page groups.
def add_page_number_footer(section, title):
    for group in [Section.e_first_page, Section.e_even_pages, Section.e_odd_pages]:
        footer = section.GetOrCreateFooter(group)

        para = footer.AddParagraph()
        para.SetJustificationMode(Paragraph.e_text_justify_center)

        style = para.GetTextStyledElement()
        style.SetFontSize(9)
        style.SetTextColor(120, 120, 120)
        style.SetItalic(True)

        para.AddText(title + "   |   Page ")
        para.AddPageNumber(PageNumber.e_current_page)
        para.AddText(" of ")
        para.AddPageNumber(PageNumber.e_total_pages)


#-----------------------------------------------------------------------------------
# 1. An invoice: a header with a logo float, an addresses table, a line item table
#    with merged cells and a totals block.
#-----------------------------------------------------------------------------------
def create_invoice():
    try:
        doc = FlowDocument()
        doc.SetDefaultPageSize(612, 792)        # US Letter, in points.
        doc.SetDefaultMargins(54, 54, 54, 54)

        section = doc.GetCurrentSection()

        # --- Header ---------------------------------------------------------------
        header = section.GetOrCreateHeader(Section.e_odd_pages)
        header_para = header.AddParagraph("SYH Supply Co.")
        header_para.SetJustificationMode(Paragraph.e_text_justify_right)
        header_para.GetTextStyledElement().SetFontSize(9)
        header_para.GetTextStyledElement().SetTextColor(120, 120, 120)

        add_page_number_footer(section, "Invoice INV-2025-0042")

        # --- Title, with the company logo floated to the right --------------------
        title = doc.AddParagraph()

        # A float takes its content out of the main flow and positions it relative to
        # a reference point, with the document content wrapped around it.
        logo_float = title.AddFloat()
        logo_float.SetHorizontalReferencePoint(Float.e_reference_page)
        logo_float.SetVerticalReferencePoint(Float.e_reference_paragraph)
        logo_float.SetPositionX(400)
        logo_float.SetPositionY(0)
        logo_float.SetObstructionType(Float.e_square)
        logo_float.AddParagraph().AddImage(96, 96, input_path + "logo_red.png")

        title.AddText("INVOICE")
        title_style = title.GetTextStyledElement()
        title_style.SetFontSize(28)
        title_style.SetBold(True)
        title_style.SetTextColor(0, 51, 102)

        subtitle = doc.AddParagraph(
            "Invoice #INV-2025-0042\nIssued: March 14, 2025\nDue: April 13, 2025")
        subtitle.GetTextStyledElement().SetFontSize(10)
        subtitle.SetSpaceAfter(18)

        # --- Bill to / ship to ----------------------------------------------------
        addresses = doc.AddTable()
        addresses.SetDefaultColumnWidth(240)
        addresses.SetDefaultRowHeight(16)

        address_row = addresses.AddTableRow()
        address_titles = ["BILL TO", "SHIP TO"]
        address_bodies = [
            "Contoso Ltd.\n123 Maple Street\nVancouver, BC V6B 1A1\nCanada",
            "Contoso Warehouse #4\n980 Industrial Way\nBurnaby, BC V5J 3J1\nCanada"]

        for i in range(2):
            cell = address_row.AddTableCell()
            cell.SetBackgroundColor(240, 244, 248)
            cell.SetBorder(0.5, 200, 210, 220)

            caption = cell.AddParagraph(address_titles[i])
            caption.SetStartIndent(3)
            caption_style = caption.GetTextStyledElement()
            caption_style.SetFontSize(9)
            caption_style.SetBold(True)
            caption_style.SetTextColor(0, 51, 102)

            body = cell.AddParagraph(address_bodies[i])
            body.SetStartIndent(3)
            body.GetTextStyledElement().SetFontSize(10)

        doc.AddParagraph(" ")

        # --- Line items -----------------------------------------------------------
        items = doc.AddTable()
        items.SetDefaultColumnWidth(120)
        items.SetDefaultRowHeight(18)
        items.SetBorder(0.75, 0, 51, 102)

        headers = ["Description", "Qty", "Unit price", "Amount"]
        header_row = add_table_row_with_text(items, headers, True, 0, 51, 102)

        # Make the header row text white by walking the row we have just created.
        cell_itr = header_row.GetContentNodeIterator()
        while cell_itr.HasNext():
            cell = cell_itr.Current().AsTableCell()
            if cell is not None:
                para_itr = cell.GetContentNodeIterator()
                while para_itr.HasNext():
                    para = para_itr.Current().AsParagraph()
                    if para is not None:
                        para.GetTextStyledElement().SetTextColor(255, 255, 255)
                    para_itr.Next()
            cell_itr.Next()

        line_descriptions = [
            "Height adjustable desk, oak finish",
            "Ergonomic office chair",
            "Meeting room whiteboard, 180 cm",
            "On-site assembly and delivery"]
        line_quantities = [2, 5, 1, 1]
        line_prices = [4800.00, 950.00, 1200.00, 2500.00]
        num_line_items = len(line_descriptions)

        subtotal = 0
        for i in range(num_line_items):
            amount = line_quantities[i] * line_prices[i]
            subtotal += amount

            cells = [
                line_descriptions[i],
                str(line_quantities[i]),
                money_to_string(line_prices[i]),
                money_to_string(amount)]

            # Alternating row background for readability.
            even = (i % 2) == 0
            add_table_row_with_text(items, cells, False,
                                    255 if even else 240,
                                    255 if even else 244,
                                    255 if even else 248)

        tax = subtotal * 0.12

        total_labels = ["Subtotal", "GST/PST (12%)", "Total due (CAD)"]
        total_values = [subtotal, tax, subtotal + tax]
        total_bold = [False, False, True]

        for i in range(len(total_labels)):
            cells = ["", "", total_labels[i], money_to_string(total_values[i])]
            add_table_row_with_text(items, cells, total_bold[i], 255, 255, 255)

            # Merge the two empty leading cells of the totals row.
            items.GetTableCell(0, num_line_items + 1 + i).MergeCellsRight(1)

        notes = doc.AddParagraph(
            "Payment is due within 30 days. Late payments are subject to a 1.5% monthly "
            "interest charge. Please reference the invoice number with your payment.")
        notes.SetSpaceBefore(24)
        notes.GetTextStyledElement().SetFontSize(9)
        notes.GetTextStyledElement().SetItalic(True)
        notes.GetTextStyledElement().SetTextColor(90, 90, 90)

        signature = doc.AddParagraph()
        signature.SetSpaceBefore(18)
        signature.AddImage(140, 50, input_path + "signature.jpg")
        signature.AddText("\nAuthorized signature")

        pdf = doc.PaginateToPDF()
        pdf.Save(output_path + "created_invoice.pdf", SDFDoc.e_linearized)
        pdf.Close()
        print("Saved created_invoice.pdf")
        return True
    except Exception as e:
        print(str(e))
        return False


#-----------------------------------------------------------------------------------
# 2. A two page report. The first page (portrait) holds a data table, the second one
#    is a separate landscape section holding a chart.
#-----------------------------------------------------------------------------------
def create_report_with_chart():
    try:
        doc = FlowDocument()
        doc.SetDefaultPageSize(612, 792)
        doc.SetDefaultMargins(72, 72, 72, 72)

        #--- Page 1: portrait section with the data table --------------------------
        data_section = doc.GetCurrentSection()
        add_page_number_footer(data_section, "Quarterly Revenue Report")

        add_heading(doc, "Quarterly Revenue Report 2025", 22, 0, 51, 102)

        intro = doc.AddParagraph(
            "The table below summarizes the revenue by region for the first three quarters "
            "of the fiscal year. All figures are given in thousands of Canadian dollars "
            "and exclude intercompany transactions.")
        intro.GetTextStyledElement().SetFontSize(11)
        intro.SetSpaceAfter(12)

        table = doc.AddTable()
        table.SetDefaultColumnWidth(90)
        table.SetDefaultRowHeight(18)
        table.SetBorder(0.75, 120, 120, 120)

        header_cells = ["Region", "Q1", "Q2", "Q3", "Total"]
        add_table_row_with_text(table, header_cells, True, 220, 230, 240)

        region_names = ["North America", "Europe", "Asia Pacific", "Latin America"]
        region_values = [
            [1250, 1410, 1580],
            [910, 980, 1120],
            [640, 720, 905],
            [310, 355, 390]]

        totals = [0, 0, 0]
        for i in range(len(region_names)):
            totals[0] += region_values[i][0]
            totals[1] += region_values[i][1]
            totals[2] += region_values[i][2]

            row_total = sum(region_values[i])
            cells = [region_names[i]] + [str(v) for v in region_values[i]] + [str(row_total)]
            add_table_row_with_text(table, cells, False, 255, 255, 255)

        total_cells = ["All regions"] + [str(t) for t in totals] + [str(sum(totals))]
        add_table_row_with_text(table, total_cells, True, 240, 240, 240)

        add_heading(doc, "Key observations", 14, 0, 51, 102)

        observations = doc.AddList()
        observations.SetNumberFormat(List.e_decimal, ".", True)
        observations.GetLabelStyle().SetBold(True)
        observations.AddItem().AddParagraph(
            "Revenue grew in every region, with Asia Pacific showing the strongest "
            "quarter over quarter growth.")
        observations.AddItem().AddParagraph(
            "North America remains the largest market, contributing roughly 40% of "
            "the total revenue.")

        risks = observations.AddItem()
        risks.AddParagraph("Risks that may affect the Q4 forecast:")
        risk_list = risks.AddList()
        risk_list.SetNumberFormat(List.e_lower_letter, ")", True)
        risk_list.AddItem().AddParagraph("Currency fluctuations in Latin America.")
        risk_list.AddItem().AddParagraph("Longer sales cycles in the enterprise segment.")

        #--- Page 2: landscape section with the chart ------------------------------
        chart_section = doc.AddSection()
        chart_section.SetPageSize(792, 612)        # landscape
        chart_section.SetMargins(54, 54, 54, 54)
        add_page_number_footer(chart_section, "Quarterly Revenue Report")

        add_heading(doc, "Revenue by region and quarter", 18, 0, 51, 102)

        # A chart is described by a JSON definition string.
        chart_definition = """{
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
        }"""

        chart_para = doc.AddParagraph()
        chart_para.SetJustificationMode(Paragraph.e_text_justify_center)
        chart = chart_para.AddChart(560, 340, chart_definition)
        chart.SetWidth(600)
        chart.SetHeight(360)

        caption = doc.AddParagraph(
            "Figure 1: revenue distribution across the four sales regions.")
        caption.SetJustificationMode(Paragraph.e_text_justify_center)
        caption.GetTextStyledElement().SetItalic(True)
        caption.GetTextStyledElement().SetFontSize(10)

        print("Report sections: " + str(doc.GetNumSections())
              + ", second section page width: " + str(doc.GetSection(1).GetPageWidth()))

        pdf = doc.PaginateToPDF()
        pdf.Save(output_path + "created_report.pdf", SDFDoc.e_linearized)
        pdf.Close()
        print("Saved created_report.pdf")
        return True
    except Exception as e:
        print(str(e))
        return False


#-----------------------------------------------------------------------------------
# 3. A newsletter demonstrating shapes, shape text boxes, floats, hyperlinks and
#    paragraph styling such as indents, tab stops and justification.
#-----------------------------------------------------------------------------------
def create_newsletter():
    try:
        body_text = (
            "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod "
            "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, "
            "quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo "
            "consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse "
            "cillum dolore eu fugiat nulla pariatur.")

        doc = FlowDocument()
        doc.SetDefaultPageSize(612, 792)
        doc.SetDefaultMargins(60, 60, 60, 60)

        section = doc.GetCurrentSection()
        add_page_number_footer(section, "The Monthly Dispatch")

        # Masthead built from a rounded rectangle shape with a text box inside.
        masthead_para = doc.AddParagraph()
        masthead = masthead_para.AddShape(Shape.e_rectangle_rounded_corners, 492, 70)
        masthead.SetCornerRadius(10)
        masthead.SetBackgroundColor(0, 51, 102)
        masthead.SetOutlineColor(0, 31, 62)
        masthead.SetOutlineThickness(1.5)

        masthead_text = masthead.GetTextBox()
        masthead_title = masthead_text.AddParagraph("The Monthly Dispatch")
        masthead_title.SetJustificationMode(Paragraph.e_text_justify_center)
        masthead_style = masthead_title.GetTextStyledElement()
        masthead_style.SetFontSize(24)
        masthead_style.SetBold(True)
        masthead_style.SetTextColor(255, 255, 255)

        masthead_sub = masthead_text.AddParagraph("Issue 42 - March 2025")
        masthead_sub.SetJustificationMode(Paragraph.e_text_justify_center)
        masthead_sub.GetTextStyledElement().SetFontSize(10)
        masthead_sub.GetTextStyledElement().SetTextColor(200, 215, 230)

        # Lead story with a pull quote floated next to it.
        add_heading(doc, "Documents, assembled", 16, 0, 51, 102)

        lead = doc.AddParagraph()
        lead.SetJustificationMode(Paragraph.e_text_justify_left)
        lead.SetTextIndent(18)
        lead.SetSpaceAfter(10)

        pull_quote = lead.AddFloat()
        pull_quote.SetHorizontalReferencePoint(Float.e_reference_page)
        pull_quote.SetVerticalReferencePoint(Float.e_reference_paragraph)
        pull_quote.SetPositionX(380)
        pull_quote.SetPositionY(10)
        pull_quote.SetObstructionType(Float.e_square)

        quote_holder = pull_quote.AddParagraph()
        quote_box = quote_holder.AddShape(Shape.e_rectangle_rounded_corners, 190, 70)
        quote_box.SetCornerRadius(6)
        quote_box.SetBackgroundColor(240, 246, 255)
        quote_box.SetOutlineColor(0, 51, 102)
        quote_box.SetOutlineThickness(1.0)

        quote_text = quote_box.GetTextBox()
        quote = quote_text.AddParagraph(
            "\"The content tree lets you describe a document, not a page.\"")
        quote.SetStartIndent(6)
        quote.SetEndIndent(6)
        quote_style = quote.GetTextStyledElement()
        quote_style.SetFontSize(12)
        quote_style.SetItalic(True)
        quote_style.SetTextColor(0, 51, 102)

        lead.AddText(body_text)
        lead.AddText(" Read more about the API at ")
        link = lead.AddHyperlink("apryse.com", "https://www.apryse.com")
        link.GetTextStyledElement().SetTextColor(0, 102, 204)
        lead.AddText(".")

        # Two "columns" of text, created with complementary indents.
        column_left = doc.AddParagraph(body_text)
        column_left.SetStartIndent(0)
        column_left.SetEndIndent(260)
        column_left.GetTextStyledElement().SetFontSize(10)

        column_right = doc.AddParagraph(body_text)
        column_right.SetStartIndent(260)
        column_right.SetEndIndent(0)
        column_right.GetTextStyledElement().SetFontSize(10)

        # A schedule built with tab stops instead of a table.
        add_heading(doc, "Upcoming webinars", 14, 0, 51, 102)

        schedule = [
            ["Apr 02", "Building documents from scratch", "R. Fischer"],
            ["Apr 16", "Charts and data visualization", "M. Okafor"],
            ["Apr 30", "Accessible PDF output", "L. Tanaka"]]

        for webinar in schedule:
            row = doc.AddParagraph()
            row.AddTabStop(80)
            row.AddTabStop(360)
            row.GetTextStyledElement().SetFontSize(10)
            row.AddText(webinar[0] + "\t" + webinar[1] + "\t" + webinar[2])

        # A decorative arrow and a photo, both anchored in a single paragraph.
        gallery = doc.AddParagraph()
        gallery.SetSpaceBefore(16)
        gallery.SetJustificationMode(Paragraph.e_text_justify_center)

        arrow = gallery.AddShape(Shape.e_arrow, 90, 40)
        arrow.SetBackgroundColor(0, 153, 102)
        arrow.SetOutlineColor(0, 102, 68)
        arrow.SetOutlineThickness(1)
        arrow.SetArrowHeadSize(18)

        gallery.AddText("   ")
        gallery.AddImage(160, 120, input_path + "butterfly.png")

        pdf = doc.PaginateToPDF()
        pdf.Save(output_path + "created_newsletter.pdf", SDFDoc.e_linearized)
        pdf.Close()
        print("Saved created_newsletter.pdf")
        return True
    except Exception as e:
        print(str(e))
        return False


#-----------------------------------------------------------------------------------
# 4. Post-processing: build a simple document and then walk its content tree,
#    restyling the elements that are found along the way.
#-----------------------------------------------------------------------------------

# Recursively walks the content tree, highlighting every second text run and
# outlining the cells of any table that is encountered.
def restyle_content_tree(node, highlight):
    itr = node.GetContentNodeIterator()
    while itr.HasNext():
        el = itr.Current()
        itr.Next()

        text_run = el.AsTextRun()
        if text_run is not None:
            if highlight:
                style = text_run.GetTextStyledElement()
                style.SetBold(True)
                style.SetBackgroundColor(255, 245, 180)
            highlight = not highlight
            continue

        cell = el.AsTableCell()
        if cell is not None:
            cell.SetBorder(0.5, 150, 150, 150)

        child = el.AsContentNode()
        if child is not None:
            highlight = restyle_content_tree(child, highlight)
    return highlight


def restyle_existing_content():
    try:
        doc = FlowDocument()
        doc.SetDefaultPageSize(612, 792)
        doc.SetDefaultMargins(72, 72, 72, 72)

        add_heading(doc, "Content tree post-processing", 18, 0, 51, 102)

        for i in range(4):
            para = doc.AddParagraph()
            para.SetSpaceAfter(8)
            para.AddText("Sentence " + str(i * 2) + ". ")
            para.AddText("Sentence " + str(i * 2 + 1) + ". ")
            para.AddText("The style of these runs is decided after the fact.")

        table = doc.AddTable()
        table.SetDefaultColumnWidth(150)
        table.SetDefaultRowHeight(16)

        for row_index in range(3):
            row = table.AddTableRow()
            for col_index in range(3):
                cell = row.AddTableCell()
                cell.AddParagraph("R" + str(row_index) + " / C" + str(col_index))

        restyle_content_tree(doc, False)

        print("Table has " + str(table.GetNumRows()) + " rows and "
              + str(table.GetNumColumns()) + " columns.")

        pdf = doc.PaginateToPDF()
        pdf.Save(output_path + "created_restyled.pdf", SDFDoc.e_linearized)
        pdf.Close()
        print("Saved created_restyled.pdf")
        return True
    except Exception as e:
        print(str(e))
        return False


def main():
    # The first step in every application using PDFNet is to initialize the
    # library. The library is usually initialized only once, but calling
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    result = True
    result &= create_invoice()
    result &= create_report_with_chart()
    result &= create_newsletter()
    result &= restyle_existing_content()

    PDFNet.Terminate()

    if not result:
        print("Tests FAILED!!!\n==========")
        return
    print("Tests successful.\n==========")


if __name__ == '__main__':
    main()
