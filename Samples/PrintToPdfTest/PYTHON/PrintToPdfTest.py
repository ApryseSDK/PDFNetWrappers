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

# Relative path to the folder containing test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#---------------------------------------------------------------------------------------
# The following sample illustrates how to convert documents to PDF format by printing
# them to the Apryse PDF printer via the Windows print verb, using the
# 'PrintToPdfModule' class.
#
# The PrintToPdf module is an optional PDFNet Add-on that can be used to convert any
# printable document into a PDF.
#
# The Apryse SDK PrintToPdf module can be downloaded from http://www.apryse.com/
#
# Note: The PrintToPdf module is only available on Windows.
#---------------------------------------------------------------------------------------

def main():

    # The first step in every application using PDFNet is to initialize the
    # library and set the path to common PDF resources. The library is usually
    # initialized only once, but calling Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)

    # The location of the PrintToPdf Module
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    if not PrintToPdfModule.IsModuleAvailable():

        print("""
        Unable to run PrintToPdfTest: Apryse SDK PrintToPdf module not available.
        ---------------------------------------------------------------
        The PrintToPdf module is an optional add-on, available for download
        at http://www.apryse.com/. If you have already downloaded this
        module, ensure that the SDK is able to find the required files
        using the PDFNet::AddResourceSearchPath() function.""")

    else:

        inputFileName = "simple-word_2007.docx"
        outputFileName = inputFileName + ".pdf"

        try:
            doc = PDFDoc()

            # Convert the document with some user options
            opts = PrintToPdfOptions()
            opts.SetPageOrientation("portrait")
            opts.SetHorizontalPageMargin(18)
            opts.SetVerticalPageMargin(18)
            # Page width and height in points (1/72 of an inch).
            # If both are zero (default), letter paper size is used.
            # opts.SetPageWidth(612)
            # opts.SetPageHeight(792)

            PrintToPdfModule.PrintToPdf(doc, input_path + inputFileName, opts)
            doc.Save(output_path + outputFileName, SDFDoc.e_linearized)
            print("Printed file: " + inputFileName)
            print("to: " + outputFileName)
        except Exception as e:
            print("Unable to convert file " + inputFileName)
            print(e)

    PDFNet.Terminate()
    print("PrintToPdf conversion example")


if __name__ == '__main__':
    main()
