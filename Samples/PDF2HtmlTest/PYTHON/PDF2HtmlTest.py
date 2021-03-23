#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

import platform

#---------------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class to convert 
# documents and files to HTML.
#
# There are two HTML modules and one of them is an optional PDFNet Add-on.
# 1. The built-in HTML module is used to convert PDF documents to fixed-position HTML
#    documents.
# 2. The optional add-on module is used to convert PDF documents to HTML documents with
#    text flowing within paragraphs.
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
    PDFNet.Initialize()
    
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

    if not PDF2HtmlReflowParagraphsModule.IsModuleAvailable():
        print("")
        print("Unable to run part of the sample: PDFTron SDK HTML reflow paragraphs module not available.")
        print("---------------------------------------------------------------")
        print("The HTML reflow paragraphs module is an optional add-on, available for download")
        print("at http://www.pdftron.com/. If you have already downloaded this")
        print("module, ensure that the SDK is able to find the required files")
        print("using the PDFNet::AddResourceSearchPath() function.")
        print("")
        return

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to HTML with reflow paragraphs option turned on (1)
        print("Converting PDF to HTML with reflow paragraphs option turned on (1)")

        outputFile = outputPath + "paragraphs_and_tables_reflow_paragraphs.html"

        htmlOutputOptions = HTMLOutputOptions()

        # Set e_reflow_paragraphs content reflow setting
        htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptions.e_reflow_paragraphs)

        Convert.ToHtml(inputPath + "paragraphs_and_tables.pdf", outputFile, htmlOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to HTML, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to HTML with reflow paragraphs option turned on (2)
        print("Converting PDF to HTML with reflow paragraphs option turned on (2)")

        outputFile = outputPath + "paragraphs_and_tables_reflow_paragraphs_no_page_width.html"

        htmlOutputOptions = HTMLOutputOptions()

        # Set e_reflow_paragraphs content reflow setting
        htmlOutputOptions.SetContentReflowSetting(HTMLOutputOptions.e_reflow_paragraphs)

        # Set to flow paragraphs across the entire browser window.
        htmlOutputOptions.SetNoPageWidth(True)

        Convert.ToHtml(inputPath + "paragraphs_and_tables.pdf", outputFile, htmlOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to HTML, error: " + str(e))

    #-----------------------------------------------------------------------------------

    print("Done.")
    
if __name__ == '__main__':
    main()
