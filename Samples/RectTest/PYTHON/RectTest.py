#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

def main():
    PDFNet.Initialize()
    
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    # Test  - Adjust the position of content within the page.
    print("_______________________________________________")
    print("Opening the input pdf...")
    
    input_doc = PDFDoc(input_path + "tiger.pdf")
    input_doc.InitSecurityHandler()
    pg_itr1 = input_doc.GetPageIterator()
    
    media_box = Rect(pg_itr1.Current().GetMediaBox())
    
    media_box.x1 -= 200     # translate the page 200 units (1 uint = 1/72 inch)
    media_box.x2 -= 200
    
    media_box.Update()
    
    input_doc.Save(output_path + "tiger_shift.pdf", 0)
    input_doc.Close()
    
    print("Done. Result saved in tiger_shift...")    

if __name__ == '__main__':
    main()