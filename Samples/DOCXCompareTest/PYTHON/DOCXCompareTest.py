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

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

# Provide your own original and revised versions of a DOCX document here.
original_filename = "SYH_Letter.docx"
revised_filename = "SYH_Letter_revision2.docx"
output_filename = "SYH_Letter_changes.docx"

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the Office.DOCXCompare utility class to
# compare two MS Word (DOCX) documents and produce a new DOCX document containing the
# differences between them as tracked changes.
#
# This comparison is performed entirely within the PDFNet and has *no* external or
# system dependencies -- Comparison results will be the same whether on Windows,
# Linux or Android.
#
# Please contact us if you have any questions.
#---------------------------------------------------------------------------------------

def main():
    # The first step in every application using PDFNet is to initialize the
    # library. The library is usually initialized only once, but calling
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)
    PDFNet.SetResourcesPath("../../../Resources")

    try:
        options = DOCXCompareOptions()

        # Compare the two DOCX documents, writing the differences as tracked
        # changes into the output DOCX document.
        result = DOCXCompare.Compare(input_path + original_filename, input_path + revised_filename, output_path + output_filename, options)

        # And we're done!
        if result.DifferencesDetected():
            print("Differences detected, saved to " + output_filename)
        else:
            print("No difference detected")
    except Exception as e:
        print("Unable to compare DOCX documents, error: " + str(e))

    PDFNet.Terminate()
    print("Done.")

if __name__ == '__main__':
    main()

