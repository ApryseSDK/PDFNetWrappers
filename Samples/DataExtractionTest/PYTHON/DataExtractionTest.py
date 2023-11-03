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

#---------------------------------------------------------------------------------------
# The Data Extraction suite is an optional PDFNet add-on collection that can be used to
# extract various types of data from PDF documents.
#
# The PDFTron SDK Data Extraction suite can be downloaded from
# https://docs.apryse.com/documentation/core/info/modules/
#
# Please contact us if you have any questions.
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
inputPath = "../../TestFiles/"
outputPath = "../../TestFiles/Output/"

def WriteTextToFile(outputFile, text):
    # Write the contents of text to the disk
    f = open(outputFile, "w")
    try:
        f.write(text)
    finally:
        f.close()

def main():
    # The first step in every application using PDFNet is to initialize the 
    # library. The library is usually initialized only once, but calling 
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)
    
    PDFNet.AddResourceSearchPath("../../../PDFNetC/Lib/")

    #-----------------------------------------------------------------------------------
    # The following sample illustrates how to extract tables from PDF documents.
    #-----------------------------------------------------------------------------------

    # Test if the add-on is installed
    if not DataExtractionModule.IsModuleAvailable(DataExtractionModule.e_Tabular):
        print("")
        print("Unable to run Data Extraction: PDFTron SDK Tabular Data module not available.")
        print("-----------------------------------------------------------------------------")
        print("The Data Extraction suite is an optional add-on, available for download")
        print("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
        print("using the PDFNet.AddResourceSearchPath() function.")
        print("")
    else:
        try:
            # Extract tabular data as a JSON file
            print("Extract tabular data as a JSON file")

            outputFile = outputPath + "table.json"
            DataExtractionModule.ExtractData(inputPath + "table.pdf", outputFile, DataExtractionModule.e_Tabular)

            print("Result saved in " + outputFile)

            #------------------------------------------------------
            # Extract tabular data as a JSON string
            print("Extract tabular data as a JSON string")

            outputFile = outputPath + "financial.json"
            json = DataExtractionModule.ExtractData(inputPath + "financial.pdf", DataExtractionModule.e_Tabular)
            WriteTextToFile(outputFile, json)

            print("Result saved in " + outputFile)

            #------------------------------------------------------
            # Extract tabular data as an XLSX file
            print("Extract tabular data as an XLSX file")

            outputFile = outputPath + "table.xlsx"
            DataExtractionModule.ExtractToXLSX(inputPath + "table.pdf", outputFile)

            print("Result saved in " + outputFile)

            #------------------------------------------------------
            # Extract tabular data as an XLSX stream (also known as filter)
            print("Extract tabular data as an XLSX stream")

            outputFile = outputPath + "financial.xlsx"
            options = DataExtractionOptions()
            options.SetPages("1") # page 1
            outputXlsxStream = MemoryFilter(0, False)
            DataExtractionModule.ExtractToXLSX(inputPath + "financial.pdf", outputXlsxStream, options)
            outputXlsxStream.SetAsInputFilter()
            outputXlsxStream.WriteToFile(outputFile, False)

            print("Result saved in " + outputFile)
        except Exception as e:
            print("Unable to extract tabular data, error: " + str(e))

    #-----------------------------------------------------------------------------------
    # The following sample illustrates how to extract document structure from PDF documents.
    #-----------------------------------------------------------------------------------

    # Test if the add-on is installed
    if not DataExtractionModule.IsModuleAvailable(DataExtractionModule.e_DocStructure):
        print("")
        print("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
        print("-----------------------------------------------------------------------------")
        print("The Data Extraction suite is an optional add-on, available for download")
        print("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
        print("using the PDFNet.AddResourceSearchPath() function.")
        print("")
    else:
        try:
            # Extract document structure as a JSON file
            print("Extract document structure as a JSON file")

            outputFile = outputPath + "paragraphs_and_tables.json"
            DataExtractionModule.ExtractData(inputPath + "paragraphs_and_tables.pdf", outputFile, DataExtractionModule.e_DocStructure)

            print("Result saved in " + outputFile)

            #------------------------------------------------------
            # Extract document structure as a JSON string
            print("Extract document structure as a JSON string")

            outputFile = outputPath + "tagged.json"
            json = DataExtractionModule.ExtractData(inputPath + "tagged.pdf", DataExtractionModule.e_DocStructure)
            WriteTextToFile(outputFile, json)

            print("Result saved in " + outputFile)
        except Exception as e:
            print("Unable to extract document structure data, error: " + str(e))

    #-----------------------------------------------------------------------------------
    # The following sample illustrates how to extract form fields from PDF documents.
    #-----------------------------------------------------------------------------------

    # Test if the add-on is installed
    if not DataExtractionModule.IsModuleAvailable(DataExtractionModule.e_Form):
        print("")
        print("Unable to run Data Extraction: PDFTron SDK AIFormFieldExtractor module not available.")
        print("-----------------------------------------------------------------------------")
        print("The Data Extraction suite is an optional add-on, available for download")
        print("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
        print("using the PDFNet.AddResourceSearchPath() function.")
        print("")
    else:
        try:
            # Extract form fields as a JSON file
            print("Extract form fields as a JSON file")

            outputFile = outputPath + "formfields-scanned.json"
            DataExtractionModule.ExtractData(inputPath + "formfields-scanned.pdf", outputFile, DataExtractionModule.e_Form)

            print("Result saved in " + outputFile)

            #------------------------------------------------------
            # Extract form fields as a JSON string
            print("Extract form fields as a JSON string")

            outputFile = outputPath + "formfields.json"
            json = DataExtractionModule.ExtractData(inputPath + "formfields.pdf", DataExtractionModule.e_Form)
            WriteTextToFile(outputFile, json)

            print("Result saved in " + outputFile)

            #-----------------------------------------------------------------------------------
            # Detect and add form fields to a PDF document.
            # PDF document already has form fields, and this sample will keep the original fields.
            print("Extract form fields as a pdf file, keep original")

            doc = PDFDoc(inputPath + "formfields-scanned-withfields.pdf")
            
            options = DataExtractionOptions()
            options.SetOverlappingFormFieldBehavior("KeepOld")
            DataExtractionModule.DetectAndAddFormFieldsToPDF(doc, options)
            
            outputFile = outputPath + "formfields-scanned-fields-old.pdf"
            doc.Save(outputFile, SDFDoc.e_linearized)
            doc.Close()
            
            print("Result saved in " + outputFile)

            #-----------------------------------------------------------------------------------
            # Detect and add form fields to a PDF document.
            # PDF document already has form fields, and this sample will update to new found fields.
            print("Extract form fields as a pdf file, update to new")

            doc = PDFDoc(inputPath + "formfields-scanned-withfields.pdf")
            
            options = DataExtractionOptions()
            options.SetOverlappingFormFieldBehavior("KeepNew")
            DataExtractionModule.DetectAndAddFormFieldsToPDF(doc, options)
            
            outputFile = outputPath + "formfields-scanned-fields-new.pdf"
            doc.Save(outputFile, SDFDoc.e_linearized)
            doc.Close()
            
            print("Result saved in " + outputFile)

        except Exception as e:
            print("Unable to extract form fields data, error: " + str(e))

    #-----------------------------------------------------------------------------------

    PDFNet.Terminate()
    print("Done.")
    
if __name__ == '__main__':
    main()
