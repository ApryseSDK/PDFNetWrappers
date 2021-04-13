#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true


# PDF Redactor is a separately licensable Add-on that offers options to remove 
# (not just covering or obscuring) content within a region of PDF. 
# With printed pages, redaction involves blacking-out or cutting-out areas of 
# the printed page. With electronic documents that use formats such as PDF, 
# redaction typically involves removing sensitive content within documents for 
# safe distribution to courts, patent and government institutions, the media, 
# customers, vendors or any other audience with restricted access to the content. 
#
# The redaction process in PDFNet consists of two steps:
# 
#  a) Content identification: A user applies redact annotations that specify the 
# pieces or regions of content that should be removed. The content for redaction 
# can be identified either interactively (e.g. using 'pdftron.PDF.PDFViewCtrl' 
# as shown in PDFView sample) or programmatically (e.g. using 'pdftron.PDF.TextSearch'
# or 'pdftron.PDF.TextExtractor'). Up until the next step is performed, the user 
# can see, move and redefine these annotations.
#  b) Content removal: Using 'pdftron.PDF.Redactor.Redact' the user instructs 
# PDFNet to apply the redact regions, after which the content in the area specified 
# by the redact annotations is removed. The redaction function includes number of 
# options to control the style of the redaction overlay (including color, text, 
# font, border, transparency, etc.).
# 
# PDFTron Redactor makes sure that if a portion of an image, text, or vector graphics 
# is contained in a redaction region, that portion of the image or path data is 
# destroyed and is not simply hidden with clipping or image masks. PDFNet API can also 
# be used to review and remove metadata and other content that can exist in a PDF 
# document, including XML Forms Architecture (XFA) content and Extensible Metadata 
# Platform (XMP) content.

def Redact(input, output, vec, app)
	doc = PDFDoc.new(input)
	if doc.InitSecurityHandler
		Redactor.Redact(doc, vec, app, false, true)
		doc.Save(output, SDFDoc::E_linearized)
	end
end

	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	PDFNet.Initialize
	
	vec = [Redaction.new(1, Rect.new(100, 100, 550, 600), false, "Top Secret"),
		Redaction.new(2, Rect.new(30, 30, 450, 450), true, "Negative Redaction"),
		Redaction.new(2, Rect.new(0, 0, 100, 100), false, "Positive"),
		Redaction.new(2, Rect.new(100, 100, 200, 200), false, "Positive"),
		Redaction.new(2, Rect.new(300, 300, 400, 400), false, ""),
		Redaction.new(2, Rect.new(500, 500, 600, 600), false, ""),
        Redaction.new(3, Rect.new(0, 0, 700, 20), false, "")]

    app = Appearance.new
    app.RedactionOverlay = true
    app.Border = false
    app.ShowRedactedContentRegions = true
	
    Redact(input_path + "newsletter.pdf", output_path + "redacted.pdf", vec, app)
	
	puts "Done..."

