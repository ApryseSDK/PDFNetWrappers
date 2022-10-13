#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2022 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------



import sys
from PDFNetPython3 import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

#------------------------------------------------------------------------------
# The following sample illustrates how to use the PDF.Convert utility class
# to convert MS Office files to PDF and replace templated tags present in the document
# with content supplied via json
#
# For a detailed specification of the template format and supported features,
# see: https://www.pdftron.com/documentation/core/guides/generate-via-template/data-model/
#
# This conversion is performed entirely within the PDFNet and has *no*
# external or system dependencies -- Conversion results will be
# the same whether on Windows, Linux or Android.
#
# Please contact us if you have any questions.
#------------------------------------------------------------------------------

def main():
    # The first step in every application using PDFNet is to initialize the
    # library. The library is usually initialized only once, but calling
    # Initialize() multiple times is also fine.
    PDFNet.Initialize(LicenseKey)
    PDFNet.SetResourcesPath("../../../Resources")

    input_filename = "SYH_Letter.docx"
    output_filename = "SYH_Letter.pdf"

    json = """
    {{
        "dest_given_name": "Janice N.",
        "dest_street_address": "187 Duizelstraat",
        "dest_surname": "Symonds",
        "dest_title": "Ms.",
        "land_location": "225 Parc St., Rochelle, QC ",
        "lease_problem": "According to the city records, the lease was initiated in September 2010 and never terminated",
        "logo": {{ "image_url": "{0}logo_red.png", "width" : 64, "height":  64 }},
        "sender_name": "Arnold Smith"
    }}
    """.format(input_path)

    # Create a TemplateDocument object from an input office file.
    template_doc = Convert.CreateOfficeTemplate(input_path + input_filename, None)

    # Fill the template with data from a JSON string, producing a PDF document.
    pdfdoc = template_doc.FillTemplateJson(json);

    # Save the PDF to a file.
    pdfdoc.Save(output_path + output_filename, SDFDoc.e_linearized)

    # And we're done!
    print("Saved " + output_filename )

if __name__ == '__main__':
    main()
