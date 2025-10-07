#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

import platform

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

# ---------------------------------------------------------------------------------------
# The following sample illustrates how to find and replace text in a PDF document.
# --------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

def main():

    # The first step in every application using PDFNet is to initialize the
    # library and set the path to common PDF resources. The library is usually
    # initialized only once, but calling Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    try:
        # Open a PDF document to edit
        doc = PDFDoc(input_path + "find-replace-test.pdf")
        options = FindReplaceOptions()

        # Set some find/replace options
        options.SetWholeWords(True)
        options.SetMatchCase(True)
        options.SetMatchMode(FindReplaceOptions.e_exact)
        options.SetReflowMode(FindReplaceOptions.e_para)
        options.SetAlignment(FindReplaceOptions.e_left)

        # Perform a Find/Replace finding "the" with "THE INCREDIBLE"
        FindReplace.FindReplaceText(doc, "the", "THE INCREDIBLE", options)

        # Save the edited PDF
        doc.Save(output_path + "find-replace-test-replaced.pdf", SDFDoc.e_linearized)

    except Exception as e:
        print("Unable to perform Find and Replace, error: " + str(e))

    PDFNet.Terminate()


if __name__ == '__main__':
    main()

