#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

import platform

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to HTML.
#
# There are two HTML modules and one of them is an optional PDFNet Add-on.
# 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
#    documents.
# 2. The optional add-on module is used to convert PDF documents to HTML documents with
#    text flowing across the browser window.
#
# The PDFTron SDK HTML add-on module can be downloaded from http://www.pdftron.com/
#
# Please contact us if you have any questions.
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
inputPath = "../../TestFiles/"
outputPath = "../../TestFiles/Output/"

def main():
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)
    
    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to HTML with fixed positioning option turned on (default)
        print("Converting PDF to HTML with fixed positioning option turned on (default)")

        outputFile = outputPath + "paragraphs_and_tables_fixed_positioning"

        Convert.ToHtml(inputPath + "paragraphs_and_tables.pdf", outputFile)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to HTML, error: " + str(e))

    #-----------------------------------------------------------------------------------

    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    if not StructuredOutputModule.IsModuleAvailable():
        print("")
        print("Unable to run part of the sample: PDFTron SDK Structured Output module not available.")
        print("-------------------------------------------------------------------------------------")
        print("The Structured Output module is an optional add-on, available for download")
        print("at https://www.pdftron.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
        print("using the PDFNet::AddResourceSearchPath() function.")
        print("")
        return

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to HTML with reflow full option turned on (1)
        print("Converting PDF to HTML with reflow full option turned on (1)")

        outputFile = outputPath + "paragraphs_and_tables_reflow_full.html"

        htmlOutputOptions = HTMLOutputOptions()

        # Set e_reflow_full content reflow setting
        htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptions.e_reflow_full)

        Convert.ToHtml(inputPath + "paragraphs_and_tables.pdf", outputFile, htmlOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to HTML, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to HTML with reflow full option turned on (only converting the first page) (2)
        print("Converting PDF to HTML with reflow full option turned on (only converting the first page) (2)")

        outputFile = outputPath + "paragraphs_and_tables_reflow_full_first_page.html"

        htmlOutputOptions = HTMLOutputOptions()

        # Set e_reflow_full content reflow setting
        htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptions.e_reflow_full)

        # Convert only the first page
        htmlOutputOptions.SetPages(1, 1)

        Convert.ToHtml(inputPath + "paragraphs_and_tables.pdf", outputFile, htmlOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to HTML, error: " + str(e))

    #-----------------------------------------------------------------------------------

    PDFNet.Terminate()
    print("Done.")
    
if __name__ == '__main__':
    main()
