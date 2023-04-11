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
outputPath = "../../TestFiles/Output/"

def ModifyContentTree(node):
    bold = False

    itr = node.GetContentNodeIterator()

    while itr.HasNext():
        el = itr.Current()
        eltype = el.GetContentElementType()

        if eltype == ContentElement.e_content_node:
            ModifyContentTree(el.GetContentNode())
        elif eltype == ContentElement.e_text_run:
            text_run = el.GetTextRun()
            if bold:
                text_run.SetBold(True)
                text_run.SetFontSize(text_run.GetFontSize() * 0.8)
            bold = not bold
        
        itr.Next()

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
        
        para.SetFontSize(24)
        para.SetTextColor(255, 0, 0)
        para.AddText("Start Red Text\n")
        para.SetTextColor(0, 0, 255)
        para.AddText("Start Blue Text\n")
        last_run = para.AddText("Start Green Text\n")

        itr = para.GetContentNodeIterator()
        i = 0
        while itr.HasNext():
            el = itr.Current()

            if el.GetContentElementType() == ContentElement.e_text_run:
                run = el.GetTextRun()
                run.SetFontSize(12)

                if i == 0:
                    # restore red color
                    run.SetText(run.GetText() + "(restored red color)\n")
                    run.SetTextColor(255, 0, 0)

            itr.Next()
            i += 1

        last_run.SetTextColor(0, 255, 0)
        last_run.SetItalic(True)
        last_run.SetFontSize(18)

        flowdoc.SetDefaultMargins(0, 72.0, 144.0, 228.0)
        flowdoc.SetDefaultPageSize(650, 750)
        flowdoc.AddParagraph(para_text)

        clr1 = [50, 50, 199]
        clr2 = [30, 199, 30]

        for i in range(50):
            para = flowdoc.AddParagraph()
            point_size = (17*i*i*i)%13+5
            if i % 2 == 0:
                para.SetItalic(True)
                para.SetTextColor(clr1[0], clr1[1], clr1[2])
                para.SetSpaceBefore(20)
                para.SetJustificationMode(ParagraphStyle.e_text_justify_left)
            else:
                para.SetTextColor(clr2[0], clr2[1], clr2[2])
                para.SetSpaceBefore(50)
                para.SetJustificationMode(ParagraphStyle.e_text_justify_right)

            para.AddText(para_text)
            para.AddText(" " + para_text)
            para.SetFontSize(point_size)

        # Walk the content tree and modify some text runs.
        body = flowdoc.GetBody()
        ModifyContentTree(body)

        my_pdf = flowdoc.PaginateToPDF()
        my_pdf.Save(outputPath + "created_doc.pdf", SDFDoc.e_linearized)

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
