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
# documents and files to Word, Excel and PowerPoint.
#
# The Structured Output module is an optional PDFNet Add-on that can be used to convert PDF
# and other documents into Word, Excel, PowerPoint and HTML format.
#
# The PDFTron SDK Structured Output module can be downloaded from
# https://www.pdftron.com/documentation/core/info/modules/
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
    
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    if not StructuredOutputModule.IsModuleAvailable():
        print("")
        print("Unable to run the sample: PDFTron SDK Structured Output module not available.")
        print("-----------------------------------------------------------------------------")
        print("The Structured Output module is an optional add-on, available for download")
        print("at https://www.pdftron.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
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

    try:
        # Convert PDF document to Excel
        print("Converting PDF to Excel")

        outputFile = outputPath + "paragraphs_and_tables.xlsx"

        Convert.ToExcel(inputPath + "paragraphs_and_tables.pdf", outputFile)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to Excel, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to Excel with options
        print("Converting PDF to Excel with options")

        outputFile = outputPath + "paragraphs_and_tables_second_page.xlsx"

        excelOutputOptions = ExcelOutputOptions()

        # Convert only the second page
        excelOutputOptions.SetPages(2, 2)

        Convert.ToExcel(inputPath + "paragraphs_and_tables.pdf", outputFile, excelOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to Excel, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to PowerPoint
        print("Converting PDF to PowerPoint")

        outputFile = outputPath + "paragraphs_and_tables.pptx"

        Convert.ToPowerPoint(inputPath + "paragraphs_and_tables.pdf", outputFile)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to PowerPoint, error: " + str(e))

    #-----------------------------------------------------------------------------------

    try:
        # Convert PDF document to PowerPoint with options
        print("Converting PDF to PowerPoint with options")

        outputFile = outputPath + "paragraphs_and_tables_first_page.pptx"

        powerPointOutputOptions = PowerPointOutputOptions()

        # Convert only the first page
        powerPointOutputOptions.SetPages(1, 1)

        Convert.ToPowerPoint(inputPath + "paragraphs_and_tables.pdf", outputFile, powerPointOutputOptions)

        print("Result saved in " + outputFile)
    except Exception as e:
        print("Unable to convert PDF document to PowerPoint, error: " + str(e))

    #-----------------------------------------------------------------------------------

    PDFNet.Terminate()
    print("Done.")
    
if __name__ == '__main__':
    main()
