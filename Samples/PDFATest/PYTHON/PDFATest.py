#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

#---------------------------------------------------------------------------------------
# The following sample illustrates how to parse and check if a PDF document meets the
#    PDFA standard, using the PDFACompliance class object. 
#---------------------------------------------------------------------------------------

def PrintResults(pdf_a, filename):
    err_cnt = pdf_a.GetErrorCount()
    if err_cnt == 0:
        print(filename + ": OK.")
    else:
        print(filename + " is NOT a valid PDFA.")
        i = 0
        while i < err_cnt:
            c = pdf_a.GetError(i)
            str1 = " - e_PDFA " + str(c) + ": " + PDFACompliance.GetPDFAErrorMessage(c) + "."
            if True:
                num_refs = pdf_a.GetRefObjCount(c)
                if num_refs > 0:
                    str1 = str1 + "\n   Objects: "
                    j = 0
                    while j < num_refs:
                        str1 = str1 + str(pdf_a.GetRefObj(c, j))
                        if j < num_refs-1:
                            str1 = str1 + ", "
                        j = j + 1
            print(str1)
            i = i + 1
        print('')	

def main():
    # Relative path to the folder containing the test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"
    
    PDFNet.Initialize()
    PDFNet.SetColorManagement()     # Enable color management (required for PDFA validation).
    
    #-----------------------------------------------------------
    # Example 1: PDF/A Validation
    #-----------------------------------------------------------
    filename = "newsletter.pdf"
    # The max_ref_objs parameter to the PDFACompliance constructor controls the maximum number 
    # of object numbers that are collected for particular error codes. The default value is 10 
    # in order to prevent spam. If you need all the object numbers, pass 0 for max_ref_objs.
    pdf_a = PDFACompliance(False, input_path+filename, None, PDFACompliance.e_Level2B, 0, 0, 10)
    PrintResults(pdf_a, filename)
    pdf_a.Destroy()
    
    #-----------------------------------------------------------
    # Example 2: PDF/A Conversion
    #-----------------------------------------------------------
    filename = "fish.pdf"
    pdf_a = PDFACompliance(True, input_path + filename, None, PDFACompliance.e_Level2B, 0, 0, 10)
    filename = "pdfa.pdf"
    pdf_a.SaveAs(output_path + filename, False)
    pdf_a.Destroy()
    
    # Re-validate the document after the conversion...
    pdf_a = PDFACompliance(False, output_path + filename, None, PDFACompliance.e_Level2B, 0, 0, 10)
    PrintResults(pdf_a, filename)
    pdf_a.Destroy()
	
    print("PDFACompliance test completed.")

if __name__ == '__main__':
    main()