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
# documents and files to Word.
#
# The Word module is an optional PDFNet Add-on that can be used to convert PDF
# documents into Word documents.
#
# The PDFTron SDK Word module can be downloaded from http://www.pdftron.com/
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
    
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    if not PDF2WordModule.IsModuleAvailable():
        print("")
        print("Unable to run the sample: PDFTron SDK Word module not available.")
        print("---------------------------------------------------------------")
        print("The Word module is an optional add-on, available for download")
        print("at http://www.pdftron.com/. If you have already downloaded this")
        print("module, ensure that the SDK is able to find the required files")
        print("using the PDFNet::AddResourceSearchPath() function.")
        print("")
        return

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to Word
        print("Converting PDF to Word")

        outputFile = outputPath + "paragraphs_and_tables.docx"

        Convert.ToWord(inputPath + "paragraphs_and_tables.pdf", outputFile)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to Word, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to Word with options
        print("Converting PDF to Word with options")

        outputFile = outputPath + "paragraphs_and_tables_first_page.docx"

        wordOutputOptions = WordOutputOptions()

        # Convert only the first page
        wordOutputOptions.SetPages(1, 1)

        Convert.ToWord(inputPath + "paragraphs_and_tables.pdf", outputFile, wordOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to Word, error: " + str(e))

    #-----------------------------------------------------------------------------------

    print("Done.")
    
if __name__ == '__main__':
    main()
