#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

#---------------------------------------------------------------------------------------
# This sample explores the structure and content of a tagged PDF document and dumps 
# the structure information to the console window.
#
# In tagged PDF documents StructTree acts as a central repository for information 
# related to a PDF document's logical structure. The tree consists of StructElement-s
# and ContentItem-s which are leaf nodes of the structure tree.
#
# The sample can be extended to access and extract the marked-content elements such 
# as text and images.
#---------------------------------------------------------------------------------------

def PrintIndent(indent)
	print "\n"
	i = 0
	while i < indent
		print "  "
		i = i + 1
	end
end
		
def ProcessStructElement(element, indent)
	if !element.IsValid
		return
	end
	
	# Print out the type and title info, if any.
	PrintIndent(indent)
	indent = indent + 1
	print "Type: " + element.GetType
	if element.HasTitle
		print ". Title:" + element.GetTitle
	end
	
	num = element.GetNumKids
	i = 0
	while i < num do
		# Check if the kid is a leaf node (i.e. it is a ContentItem)
		if element.IsContentItem(i)
			cont = element.GetAsContentItem(i)
			type = cont.GetType
			
			page = cont.GetPage
			
			PrintIndent(indent)
			print "Content Item. Part of page #" + page.GetIndex.to_s
			PrintIndent(indent)
			case type
			when ContentItem::E_MCID
				print "MCID: " + cont.GetMCID.to_s
			when ContentItem::E_MCR
				print "MCID: " + cont.GetMCID.to_s
			when ContentItem::E_OBJR
				print "OBJR "
				ref_obj = cont.GetRefObj
				if !ref_obj.nil?
					print "- Referenced Object#: " + ref_obj.GetObjNum.to_s
				end
			end
		else
			ProcessStructElement(element.GetAsStructElem(i), indent)
		end
		i = i + 1
	end
end	

# Used in code snippet 3.
def ProcessElements2(reader)
	mcid_page_map = Hash.new
	element = reader.Next
	while !element.nil? do	# Read page contents
		# In this sample we process only text, but the code can be extended
		# to handle paths, images, or other Element type.
		mcid = element.GetStructMCID
		
		if mcid>=0 and element.GetType == Element::E_text
			val = element.GetTextString
			
			if mcid_page_map.has_key?(mcid)
				mcid_page_map[mcid] = mcid_page_map[mcid].to_s + val
			else
				mcid_page_map[mcid] = val
			end
		end
		element = reader.Next
	end
	return mcid_page_map
end

# Used in code snippet 2.
def ProcessElements(reader)
	element = reader.Next
	while !element.nil? do	# Read page contents
		# In this sample we process only paths & text, but the code can be 
		# extended to handle any element type.
		type = element.GetType
		if (type == Element::E_path or
			type == Element::E_text or
			type == Element::E_path)
			case type
			when Element::E_path	# Process path ...
				print "\nPATH: "
			when Element::E_text	# Process text ...
				print "\nTEXT: " + element.GetTextString + "\n"
			when Element::E_path	# Process from XObjects
				print "\nFORM XObject: "
			end
			
			# Check if the element is associated with any structural element.
			# Content items are leaf nodes of the structure tree.
			struct_parent = element.GetParentStructElement
			if struct_parent.IsValid
				# Print out the parent structural element's type, title, and object number.
				print " Type: " + struct_parent.GetType.to_s + ", MCID: " + element.GetStructMCID.to_s
				if struct_parent.HasTitle
					print ". Title: " + struct_parent.GetTitle
				end
				print ", Obj#: " + struct_parent.GetSDFObj.GetObjNum.to_s
			end
		end
		element = reader.Next
	end
end		
		
def ProcessStructElement2(element, mcid_doc_map, indent)
	if !element.IsValid
		return
	end
	
	# Print out the type and title info, if any
	PrintIndent(indent)
	print "<" + element.GetType
	if element.HasTitle
		print " title=\"" + element.GetTitle + "\""
	end
	print ">"
	
	num = element.GetNumKids
	i = 0
	while i < num do
		if element.IsContentItem(i)
			cont = element.GetAsContentItem(i)
			if cont.GetType == ContentItem::E_MCID
				page_num = cont.GetPage.GetIndex
				if mcid_doc_map.has_key?(page_num)
					mcid_page_map = mcid_doc_map[page_num]
					mcid_key = cont.GetMCID
					if mcid_page_map.has_key?(mcid_key)
						print mcid_page_map[mcid_key]
					end
				end
			end
		else	# the kid is another StructElement node.
			ProcessStructElement2(element.GetAsStructElem(i), mcid_doc_map, indent+1)
		end 
		i = i + 1
	end
	PrintIndent(indent)
	print "</" + element.GetType + ">"		
end

	PDFNet.Initialize
	
	# Relative path to the folder containing the test files.
	input_path = "../../TestFiles/"
	output_path = "../../TestFiles/Output/"
	
	# Extract logical structure from a PDF document
	doc = PDFDoc.new(input_path + "tagged.pdf")
	doc.InitSecurityHandler
	
	puts "____________________________________________________________"
	puts "Sample 1 - Traverse logical structure tree..."
	
	tree = doc.GetStructTree
	if tree.IsValid
		puts "Document has a StructTree root."
		
		i = 0
		while i<tree.GetNumKids do
			# Recursively get structure info for all child elements.
			ProcessStructElement(tree.GetKid(i), 0)
			i = i + 1
		end
	else
		puts "This document does not contain any logical structure."
	end
	
	puts "\nDone 1."
	
	puts "____________________________________________________________"
	puts "Sample 2 - Get parent logical structure elements from"
	puts "layout elements."
	
	reader = ElementReader.new
	itr = doc.GetPageIterator
	while itr.HasNext do
		reader.Begin(itr.Current)
		ProcessElements(reader)
		reader.End
		itr.Next
	end
	
	puts "\nDone 2."
	
	puts "____________________________________________________________"
	puts "Sample 3 - 'XML style' extraction of PDF logical structure and page content."

	# A map which maps page numbers(as Integers)
	# to page Maps(which map from struct mcid(as Integers) to
	# text Strings)

	mcid_doc_map = Hash.new
	reader = ElementReader.new
	itr = doc.GetPageIterator
	while itr.HasNext do
		reader.Begin(itr.Current)
		mcid_doc_map[itr.Current.GetIndex] = ProcessElements2(reader)
		reader.End
		itr.Next
	end
	tree = doc.GetStructTree
	if tree.IsValid
		i = 0
		while i < tree.GetNumKids do
			ProcessStructElement2(tree.GetKid(i), mcid_doc_map, 0)
			i = i + 1  
		end
	end
	puts "\nDone 3."
	doc.Save((output_path + "LogicalStructure.pdf"), SDFDoc::E_linearized)
	doc.Close
