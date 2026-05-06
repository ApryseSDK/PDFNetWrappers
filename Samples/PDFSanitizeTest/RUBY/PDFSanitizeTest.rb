#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult legal.txt regarding legal and license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

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

	# Relative paths to folders containing test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"

	PDFNet.Initialize(PDFTronLicense.Key)

	# The following example illustrates how to retrieve the existing
	# sanitizable content categories within a document.
	begin
		doc = PDFDoc.new(input_path + "numbered.pdf")
		doc.InitSecurityHandler

		opts = Sanitizer.GetSanitizableContent(doc)
		if opts.GetMetadata
			puts "Document has metadata."
		end
		if opts.GetMarkups
			puts "Document has markups."
		end
		if opts.GetHiddenLayers
			puts "Document has hidden layers."
		end
		puts "Done..."
	rescue Exception => e
		puts e
	end

	# The following example illustrates how to sanitize a document with default options,
	# which will remove all sanitizable content present within a document.
	begin
		doc = PDFDoc.new(input_path + "financial.pdf")
		doc.InitSecurityHandler

		Sanitizer.SanitizeDocument(doc, nil)
		doc.Save(output_path + "financial_sanitized.pdf", SDFDoc::E_linearized)
		puts "Done..."
	rescue Exception => e
		puts e
	end

	# The following example illustrates how to sanitize a document with custom set options,
	# which will only remove the content categories specified by the options object.
	begin
		options = SanitizeOptions.new
		options.SetMetadata(true)
		options.SetFormData(true)
		options.SetBookmarks(true)

		doc = PDFDoc.new(input_path + "form1.pdf")
		doc.InitSecurityHandler

		Sanitizer.SanitizeDocument(doc, options)
		doc.Save(output_path + "form1_sanitized.pdf", SDFDoc::E_linearized)
		puts "Done..."
	rescue Exception => e
		puts e
	end

	PDFNet.Terminate
	puts "Done..."

