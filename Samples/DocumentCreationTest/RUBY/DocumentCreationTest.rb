#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

def ModifyContentTree(node)
	bold = false

	itr = node.GetContentNodeIterator()

	while itr.HasNext() do
		el = itr.Current()
		maybe_content_node = el.AsContentNode()
		if maybe_content_node.IsValid()
			ModifyContentTree(maybe_content_node.GetContentNode())
		else
			maybe_text_run = el.AsTextRun()
			if maybe_text_run.IsValid()
				if bold
					text_run = maybe_text_run.GetTextRun()
					text_run.GetTextStyledElement().SetBold(true)
					text_run.GetTextStyledElement().SetFontSize(text_run.GetTextStyledElement().GetFontSize() * 0.8)
				end
				bold = !bold
			end
		end

		itr.Next()
	end
end

	PDFNet.Initialize(PDFTronLicense.Key)

	para_text = "Lorem ipsum dolor " +
		"sit amet, consectetur adipisicing elit, sed " +
		"do eiusmod tempor incididunt ut labore " +
		"et dolore magna aliqua. Ut enim ad " +
		"minim veniam, quis nostrud exercitation " +
		"ullamco laboris nisi ut aliquip ex ea " +
		"commodo consequat. Duis aute irure " +
		"dolor in reprehenderit in voluptate velit " +
		"esse cillum dolore eu fugiat nulla pariatur. " +
		"Excepteur sint occaecat cupidatat " +	
		"non proident, sunt in culpa qui officia " +
		"deserunt mollit anim id est laborum."

	result = true

	flowdoc = FlowDocument.new()
	para = flowdoc.AddParagraph()
	st_para = para.GetTextStyledElement()

	st_para.SetFontSize(24)
	st_para.SetTextColor(255, 0, 0)
	para.AddText("Start Red Text\n")
	st_para.SetTextColor(0, 0, 255)
	para.AddText("Start Blue Text\n")

	last_run = para.AddText("Start Green Text\n")

	itr = para.GetContentNodeIterator()
	i = 0
	while itr.HasNext() do
		el = itr.Current()

		maybe_text_run = el.AsTextRun()
		if maybe_text_run.IsValid()
			run = maybe_text_run.GetTextRun()
			run.GetTextStyledElement().SetFontSize(12)

			if i == 0
				# restore red color
				run.SetText(run.GetText() + "(restored red color)\n")
				run.GetTextStyledElement().SetTextColor(255, 0, 0)
			end
		end

		itr.Next()
		i += 1
	end

	st_last = last_run.GetTextStyledElement()

	st_last.SetTextColor(0, 255, 0)
	st_last.SetItalic(true)
	st_last.SetFontSize(18)

	para.GetTextStyledElement().SetBold(true)

	st_last.SetBold(false)

	flowdoc.SetDefaultMargins(0, 72.0, 144.0, 228.0)
	flowdoc.SetDefaultPageSize(650, 750)
	flowdoc.AddParagraph(para_text)

	clr1 = [50, 50, 199]
	clr2 = [30, 199, 30]

	(0..49).each do |i|
		para = flowdoc.AddParagraph()
		st = para.GetTextStyledElement()

		point_size = (17*i*i*i)%13+5
		if i % 2 == 0
			st.SetItalic(true)
			st.SetTextColor(clr1[0], clr1[1], clr1[2])
			para.SetSpaceBefore(20)
			para.SetJustificationMode(ParagraphStyle::E_text_justify_left)
		else
			st.SetTextColor(clr2[0], clr2[1], clr2[2])
			para.SetSpaceBefore(50)
			para.SetJustificationMode(ParagraphStyle::E_text_justify_right)
		end

		para.AddText(para_text)
		para.AddText(" " + para_text)
		st.SetFontSize(point_size)
	end

	# Walk the content tree and modify some text runs.
	body = flowdoc.GetBody()
	ModifyContentTree(body)

	my_pdf = flowdoc.PaginateToPDF()
	my_pdf.Save((output_path + "created_doc.pdf"), SDFDoc::E_remove_unused)
	
	PDFNet.Terminate
	puts "Done. Result saved in created_doc.pdf..."

