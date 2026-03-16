#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult legal.txt regarding legal and license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

sys.path.append("../../LicenseKey/PYTHON")
from LicenseKey import *

#------------------------------------------------------------------------------
# PDFNet's Sanitizer is a security-focused feature that permanently removes
# hidden, sensitive, or potentially unsafe content from a PDF document.
# While redaction targets visible page content such as text or graphics,
# sanitization focuses on non-visual elements and embedded structures.
#
# PDFNet Sanitizer ensures hidden or inactive content is destroyed,
# not merely obscured or disabled. This prevents leakage of sensitive
# data such as authoring details, editing history, private identifiers,
# and residual form entries, and neutralizes scripts or attachments.
#
# Sanitization is recommended prior to external sharing with clients,
# partners, or regulatory bodies. It helps align with privacy policies
# and compliance requirements by permanently removing non-visual data.
#------------------------------------------------------------------------------

def main():
    # Relative paths to folders containing test files.
    input_path = "../../TestFiles/"
    output_path = "../../TestFiles/Output/"

    PDFNet.Initialize(LicenseKey)

    # The following example illustrates how to retrieve the existing
    # sanitizable content categories within a document.
    try:
        doc = PDFDoc(input_path + "numbered.pdf")
        doc.InitSecurityHandler()

        opts = Sanitizer.GetSanitizableContent(doc)
        if opts.GetMetadata():
            print("Document has metadata.")
        if opts.GetMarkups():
            print("Document has markups.")
        if opts.GetHiddenLayers():
            print("Document has hidden layers.")
        print("Done...")
    except Exception as e:
        print(e)

    # The following example illustrates how to sanitize a document with default options,
    # which will remove all sanitizable content present within a document.
    try:
        doc = PDFDoc(input_path + "financial.pdf")
        doc.InitSecurityHandler()

        Sanitizer.SanitizeDocument(doc, None)
        doc.Save(output_path + "financial_sanitized.pdf", SDFDoc.e_linearized)
        print("Done...")
    except Exception as e:
        print(e)

    # The following example illustrates how to sanitize a document with custom set options,
    # which will only remove the content categories specified by the options object.
    try:
        options = SanitizeOptions()
        options.SetMetadata(True)
        options.SetFormData(True)
        options.SetBookmarks(True)

        doc = PDFDoc(input_path + "form1.pdf")
        doc.InitSecurityHandler()

        Sanitizer.SanitizeDocument(doc, options)
        doc.Save(output_path + "form1_sanitized.pdf", SDFDoc.e_linearized)
        print("Done...")
    except Exception as e:
        print(e)

    PDFNet.Terminate()

if __name__ == '__main__':
    main()

