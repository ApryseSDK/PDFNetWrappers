#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

#---------------------------------------------------------------------------------------
# The following sample illustrates how to make sure a file meets the PDF/UA standard, using the PDFUAConformance class object.
# Note: this feature is currently experimental and subject to change
#
# DataExtractionModule is required (Mac users can use StructuredOutputModule instead)
# https://docs.apryse.com/documentation/core/info/modules/#data-extraction-module
# https://docs.apryse.com/documentation/core/info/modules/#structured-output-module (Mac)
#---------------------------------------------------------------------------------------

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

# DataExtraction library location, replace if desired, should point to a folder that includes the contents of <DataExtractionModuleRoot>/Lib.
# If using default, unzip the DataExtraction zip to the parent folder of Samples, and merge with existing "Lib" folder.
extraction_module_path = "../../../PDFNetC/Lib/"

def main():
    input_file1 = input_path + "autotag_input.pdf"
    input_file2 = input_path + "table.pdf"
    output_file1 = output_path + "autotag_pdfua.pdf"
    output_file2 = output_path + "table_pdfua_linearized.pdf"

    PDFNet.Initialize(LicenseKey)

    print("AutoConverting...")

    PDFNet.AddResourceSearchPath(extraction_module_path)

    if not DataExtractionModule.IsModuleAvailable(DataExtractionModule.e_DocStructure):
        print("")
        print("Unable to run Data Extraction: PDFTron SDK Structured Output module not available.")
        print("-----------------------------------------------------------------------------")
        print("The Data Extraction suite is an optional add-on, available for download")
        print("at https://docs.apryse.com/documentation/core/info/modules/. If you have already")
        print("downloaded this module, ensure that the SDK is able to find the required files")
        print("using the PDFNet.AddResourceSearchPath() function.")
        print("")
        PDFNet.Terminate()
        return

    try:
        pdf_ua = PDFUAConformance()

        print("Simple Conversion...")

        # Perform conversion using default options
        pdf_ua.AutoConvert(input_file1, output_file1)

        print("Converting With Options...")

        pdf_ua_opts = PDFUAOptions()
        pdf_ua_opts.SetSaveLinearized(True)  # Linearize when saving output
        # Note: if file is password protected, you can use pdf_ua_opts.SetPassword()

        # Perform conversion using the options we specify
        pdf_ua.AutoConvert(input_file2, output_file2, pdf_ua_opts)

    except Exception as e:
        print(str(e))

    PDFNet.Terminate()
    print("PDFUAConformance test completed.")

if __name__ == '__main__':
    main()