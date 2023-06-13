#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

import platform

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

# Relative path to the folder containing the test files.
output_path = "../../TestFiles/Output/"
output_name = "created_doc.pdf"

def modify_content_tree(node):
    bold = False

    itr = node.GetContentNodeIterator()
    while itr.HasNext():
        el = itr.Current()
        itr.Next()

        text_run = el.AsTextRun()
        if text_run is not None:
            if bold:
                text_run.GetTextStyledElement().SetBold(True)
                text_run.GetTextStyledElement().SetFontSize(
                    text_run.GetTextStyledElement().GetFontSize() * 0.8)
            bold = not bold
            continue

        content_node = el.AsContentNode()
        if content_node is not None:
            modify_content_tree(content_node)
            continue

def main():
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    para_text = ("Lorem ipsum dolor "
    "sit amet, consectetur adipisicing elit, sed "
    "do eiusmod tempor incididunt ut labore "
    "et dolore magna aliqua. Ut enim ad "
    "minim veniam, quis nostrud exercitation "
    "ullamco laboris nisi ut aliquip ex ea "
    "commodo consequat. Duis aute irure "
    "dolor in reprehenderit in voluptate velit "
    "esse cillum dolore eu fugiat nulla pariatur. "
    "Excepteur sint occaecat cupidatat "
    "non proident, sunt in culpa qui officia "
    "deserunt mollit anim id est laborum.")

    result = True
    
    try:
        flowdoc = FlowDocument()
        para = flowdoc.AddParagraph()
        st_para = para.GetTextStyledElement()

        st_para.SetFontSize(24)
        st_para.SetTextColor(255, 0, 0)
        para.AddText("Start \tRed \tText\n")

        para.AddTabStop(150)
        para.AddTabStop(250)
        st_para.SetTextColor(0, 0, 255)
        para.AddText("Start \tBlue \tText\n")

        last_run = para.AddText("Start Green Text\n")

        start = True
        itr = para.GetContentNodeIterator()
        while itr.HasNext():
            el = itr.Current()
            run = el.AsTextRun()
            if run is not None:
                run.GetTextStyledElement().SetFontSize(12)
                if start:
                    # Restore red color.
                    start = False
                    run.SetText(run.GetText() + "(restored \tred \tcolor)\n")
                    run.GetTextStyledElement().SetTextColor(255, 0, 0)
            itr.Next()

        st_last = last_run.GetTextStyledElement()
        st_last.SetTextColor(0, 255, 0)
        st_last.SetItalic(True)
        st_last.SetFontSize(18)

        para.GetTextStyledElement().SetBold(True)
        para.SetBorder(0.2, 0, 127, 0)
        st_last.SetBold(False)

        flowdoc.AddParagraph("Simple list creation process. All elements are added in their natural order\n\n")

        list = flowdoc.AddList()
        list.SetNumberFormat(List.e_upper_letter)
        list.SetStartIndex(4)

        item = list.AddItem()  # creates "D."
        item.AddParagraph("item 0[0]")
        px = item.AddParagraph("item 0[1]")
        xx_para = px.GetTextStyledElement()
        xx_para.SetTextColor(255, 99, 71)
        px.AddText(" Some More Text!")

        item2 = list.AddItem()  # creates "E."
        item2List = item2.AddList()
        item2List.SetStartIndex(0)
        item2List.SetNumberFormat(List.e_decimal, "", True)
        item2List.AddItem().AddParagraph("item 1[0].0")
        pp = item2List.AddItem().AddParagraph("item 1[0].1")
        sx_para = pp.GetTextStyledElement()
        sx_para.SetTextColor(0, 0, 255)
        pp.AddText(" Some More Text")
        item2List.AddItem().AddParagraph("item 1[0].2")
        item2List1 = item2List.AddItem().AddList()
        item2List1.SetStartIndex(7)
        item2List1.SetNumberFormat(List.e_upper_roman, ")", True)
        item2List1.AddItem().AddParagraph("item 1[0].3.0")
        item2List1.AddItem().AddParagraph("item 1[0].3.1")

        extraItem = item2List1.AddItem()
        extraItem.AddParagraph("item 1[0].3.2[0]")
        extraItem.AddParagraph("item 1[0].3.2[1]")
        fourth = extraItem.AddList()
        fourth.SetNumberFormat(List.e_decimal, "", True)
        fourth.AddItem().AddParagraph("Fourth Level")

        fourth = item2List1.AddItem().AddList()
        fourth.SetNumberFormat(List.e_lower_letter, "", True)
        fourth.AddItem().AddParagraph("Fourth Level (again)")

        item2.AddParagraph("item 1[1]")
        item2List2 = item2.AddList()
        item2List2.SetStartIndex(10)
        item2List2.SetNumberFormat(List.e_lower_roman)
        item2List2.AddItem().AddParagraph("item 1[2].0")
        item2List2.AddItem().AddParagraph("item 1[2].1")
        item2List2.AddItem().AddParagraph("item 1[2].2")

        item3 = list.AddItem()  # creates "F."
        item3.AddParagraph("item 2")

        item4 = list.AddItem()  # creates "G."
        item4.AddParagraph("item 3")

        item5 = list.AddItem()  # creates "H."
        item5.AddParagraph("item 4")

        itr = flowdoc.GetBody().GetContentNodeIterator()
        while itr.HasNext():
            el = itr.Current()

            list = el.AsList()
            if list is not None:
                if list.IndentationLevel() == 1:
                    p = list.AddItem().AddParagraph("Item added during iteration")
                    ps = p.GetTextStyledElement()
                    ps.SetTextColor(0, 127, 0)

            list_item = el.AsListItem()
            if list_item is not None:
                if list_item.IndentationLevel() == 2:
                    p = list_item.AddParagraph("* Paragraph added during iteration")
                    ps = p.GetTextStyledElement()
                    ps.SetTextColor(0, 0, 255)
            itr.Next()

        flowdoc.AddParagraph("\f")  # page break

        flowdoc.AddParagraph("Nonlinear list creation flow. Items are added randomly."
                            + " List body separated by a paragraph, does not belong to the list\n\n")

        list = flowdoc.AddList()
        list.SetNumberFormat(List.e_upper_letter)
        list.SetStartIndex(4)

        item = list.AddItem()  # creates "D."
        item.AddParagraph("item 0[0]")
        px = item.AddParagraph("item 0[1]")
        xx_para = px.GetTextStyledElement()
        xx_para.SetTextColor(255, 99, 71)
        px.AddText(" Some More Text!")
        item.AddParagraph("item 0[2]")
        px = item.AddParagraph("item 0[3]")
        item.AddParagraph("item 0[4]")
        xx_para = px.GetTextStyledElement()
        xx_para.SetTextColor(255, 99, 71)

        item2 = list.AddItem()  # creates "E."
        item2List = item2.AddList()
        item2List.SetStartIndex(0)
        item2List.SetNumberFormat(List.e_decimal, "", True)
        item2List.AddItem().AddParagraph("item 1[0].0")
        pp = item2List.AddItem().AddParagraph("item 1[0].1")
        sx_para = pp.GetTextStyledElement()
        sx_para.SetTextColor(0, 0, 255)
        pp.AddText(" Some More Text")

        item3 = list.AddItem()  # creates "F."
        item3.AddParagraph("item 2")

        item2List.AddItem().AddParagraph("item 1[0].2")

        item2.AddParagraph("item 1[1]")
        item2List2 = item2.AddList()
        item2List2.SetStartIndex(10)
        item2List2.SetNumberFormat(List.e_lower_roman)
        item2List2.AddItem().AddParagraph("item 1[2].0")
        item2List2.AddItem().AddParagraph("item 1[2].1")
        item2List2.AddItem().AddParagraph("item 1[2].2")

        item4 = list.AddItem()  # creates "G."
        item4.AddParagraph("item 3")

        item2List1 = item2List.AddItem().AddList()
        item2List1.SetStartIndex(7)
        item2List1.SetNumberFormat(List.e_upper_roman, ")", True)
        item2List1.AddItem().AddParagraph("item 1[0].3.0")

        flowdoc.AddParagraph("---------------------------------- splitting paragraph ----------------------------------")

        item2List1.ContinueList()

        item2List1.AddItem().AddParagraph("item 1[0].3.1 (continued)")
        extraItem = item2List1.AddItem()
        extraItem.AddParagraph("item 1[0].3.2[0]")
        extraItem.AddParagraph("item 1[0].3.2[1]")
        fourth = extraItem.AddList()
        fourth.SetNumberFormat(List.e_decimal, "", True)
        fourth.AddItem().AddParagraph("FOURTH LEVEL")

        item5 = list.AddItem()  # creates "H."
        item5.AddParagraph("item 4 (continued)")

        flowdoc.AddParagraph(" ")

        flowdoc.SetDefaultMargins(72.0, 72.0, 144.0, 228.0)
        flowdoc.SetDefaultPageSize(650, 750)
        flowdoc.AddParagraph(para_text)

        clr1 = [50, 50, 199]
        clr2 = [30, 199, 30]

        for i in range(50):
            para = flowdoc.AddParagraph()
            style = para.GetTextStyledElement()
            point_size = (17*i*i*i)%13+5
            if i % 2 == 0:
                style.SetItalic(True)
                style.SetTextColor(clr1[0], clr1[1], clr1[2])
                style.SetBackgroundColor(200, 200, 200);
                para.SetSpaceBefore(20)
                para.SetStartIndent(20)
                para.SetJustificationMode(Paragraph.e_text_justify_left)
            else:
                style.SetTextColor(clr2[0], clr2[1], clr2[2])
                para.SetSpaceBefore(50)
                para.SetEndIndent(20)
                para.SetJustificationMode(Paragraph.e_text_justify_right)

            para.AddText(para_text)
            para.AddText(" " + para_text)
            style.SetFontSize(point_size)

        # Table creation
        new_table = flowdoc.AddTable()
        new_table.SetDefaultColumnWidth(100)
        new_table.SetDefaultRowHeight(15)

        for i in range(4):
            row = new_table.AddTableRow()
            row.SetRowHeight(new_table.GetDefaultRowHeight() + i*5)
            for j in range(5):
                cell = row.AddTableCell()
                cell.SetBorder(0.5, 255, 0, 0)

                if i == 3:
                    if j % 2 != 0:
                        cell.SetVerticalAlignment(TableCell.e_alignment_center)
                    else:
                        cell.SetVerticalAlignment(TableCell.e_alignment_bottom)

                if i == 3 and j == 4:
                    para_title = cell.AddParagraph("Table title")
                    para_title.SetJustificationMode(Paragraph.e_text_justify_center)

                    nested_table = cell.AddTable()
                    nested_table.SetDefaultColumnWidth(33)
                    nested_table.SetDefaultRowHeight(5)
                    nested_table.SetBorder(0.5, 0, 0, 0)

                    for nested_row_index in range(3):
                        nested_row = nested_table.AddTableRow()
                        for nested_column_index in range(3):
                            para_str = str(nested_row_index) + "/" + str(nested_column_index)
                            nested_cell = nested_row.AddTableCell()
                            nested_cell.SetBackgroundColor(200, 200, 255)
                            nested_cell.SetBorder(0.1, 0, 255, 0)

                            new_para = nested_cell.AddParagraph(para_str)
                            new_para.SetJustificationMode(Paragraph.e_text_justify_right)
                elif i == 2 and j == 2:
                    new_para = cell.AddParagraph("Cell " + str(j) + " x " + str(i) + "\n")
                    new_para.AddText("to be bold text 1\n")
                    new_para.AddText("still normal text\n")
                    new_para.AddText("to be bold text 2")
                    cell.AddParagraph("Second Paragraph")
                else:
                    cell.AddParagraph("Cell " + str(j) + " x " + str(i))

        # Walk the content tree and modify some text runs.
        modify_content_tree(flowdoc.GetBody())

        # Merge cells
        merged_cell = new_table.GetTableCell(2, 0).MergeCellsRight(1)
        merged_cell.SetHorizontalAlignment(TableCell.e_alignment_middle)

        new_table.GetTableCell(0, 0).MergeCellsDown(1).SetVerticalAlignment(TableCell.e_alignment_center)

        # Walk over the table and change the first cell in each row.
        row_idx = 0
        clr_row1 = [175, 240, 240]
        clr_row2 = [250, 250, 175]

        table_itr = new_table.GetContentNodeIterator()
        while table_itr.HasNext():
            row = table_itr.Current().AsTableRow()
            if row is not None:
                row_itr = row.GetContentNodeIterator()
                while row_itr.HasNext():
                    cell = row_itr.Current().AsTableCell()
                    if cell is not None:
                        if row_idx % 2 != 0:
                            cell.SetBackgroundColor(clr_row1[0], clr_row1[1], clr_row1[2])
                        else:
                            cell.SetBackgroundColor(clr_row2[0], clr_row2[1], clr_row2[2])

                        cell_itr = cell.GetContentNodeIterator()
                        while cell_itr.HasNext():
                            element = cell_itr.Current();
                            para = element.AsParagraph()
                            if para is not None:
                                st = para.GetTextStyledElement()
                                st.SetTextColor(255, 0, 0)
                                st.SetFontSize(12)
                            else:
                                nested_table = element.AsTable()
                                if nested_table is not None:
                                    nested_cell = nested_table.GetTableCell(1, 1)
                                    nested_cell.SetBackgroundColor(255, 127, 127)
                            cell_itr.Next()
                    row_itr.Next()

            row_idx += 1
            table_itr.Next()

        my_pdf = flowdoc.PaginateToPDF()
        my_pdf.Save(output_path + output_name, SDFDoc.e_linearized)

    except Exception as e:
        print(str(e))
        result = False

    #-----------------------------------------------------------------------------------

    if not result:
        print("Tests FAILED!!!\n==========")
        PDFNet.Terminate()
        return
    PDFNet.Terminate()
    print("Tests successful.\n==========")
    
if __name__ == '__main__':
    main()
