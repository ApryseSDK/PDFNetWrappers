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
            para.SetFontSize(point_size)

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
