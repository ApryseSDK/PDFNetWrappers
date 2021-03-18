#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby

$stdout.sync = true

# Relative path to the folder containing the test files.
$input_path = "../../TestFiles/"
$output_path = "../../TestFiles/Output/"

def CreateTilingPattern(doc)
	writer = ElementWriter.new
	eb = ElementBuilder.new
	
	# Create a new pattern content stream - a heart. ------------
	writer.Begin(doc.GetSDFDoc)
	eb.PathBegin
	eb.MoveTo(0, 0)
	eb.CurveTo(500, 500, 125, 625, 0, 500)
	eb.CurveTo(-125, 625, -500, 500, 0, 0)
	heart = eb.PathEnd
	heart.SetPathFill(true)
	
	# Set heart color to red.
	heart.GetGState.SetFillColorSpace(ColorSpace.CreateDeviceRGB) 
	heart.GetGState.SetFillColor(ColorPt.new(1, 0, 0)) 
	writer.WriteElement(heart)
	
	pattern_dict = writer.End
	
	# Initialize pattern dictionary. For details on what each parameter represents please 
	# refer to Table 4.22 (Section '4.6.2 Tiling Patterns') in PDF Reference Manual.
	pattern_dict.PutName("Type", "Pattern")
	pattern_dict.PutNumber("PatternType", 1)
	
	# TilingType - Constant spacing.
	pattern_dict.PutNumber("TilingType",1) 

	# This is a Type1 pattern - A colored tiling pattern.
	pattern_dict.PutNumber("PaintType", 1)

	# Set bounding box
	pattern_dict.PutRect("BBox", -253, 0, 253, 545)

	# Create and set the matrix
	pattern_mtx = Matrix2D.new(0.04,0,0,0.04,0,0)
	pattern_dict.PutMatrix("Matrix", pattern_mtx)
	
	# Set the desired horizontal and vertical spacing between pattern cells, 
	# measured in the pattern coordinate system.
	pattern_dict.PutNumber("XStep", 1000)
	pattern_dict.PutNumber("YStep", 1000)
	
	return pattern_dict # finished creating the Pattern resource
end

def CreateImageTilingPattern(doc)
	writer = ElementWriter.new
	eb = ElementBuilder.new
	
	# Create a new pattern content stream - a single bitmap object ----------
	writer.Begin(doc.GetSDFDoc)
	image = Image.Create(doc.GetSDFDoc, $input_path + "dice.jpg")
	img_element = eb.CreateImage(image, 0, 0, image.GetImageWidth, image.GetImageHeight)
	writer.WritePlacedElement(img_element)
	pattern_dict = writer.End
	
	# Initialize pattern dictionary. For details on what each parameter represents please 
	# refer to Table 4.22 (Section '4.6.2 Tiling Patterns') in PDF Reference Manual.
	pattern_dict.PutName("Type", "Pattern")
	pattern_dict.PutNumber("PatternType",1)
	
	# TilingType - Constant spacing.
	pattern_dict.PutNumber("TilingType", 1)
	
	# This is a Type1 pattern - A colored tiling pattern.
	pattern_dict.PutNumber("PaintType", 1)
	
	# Set bounding box
	pattern_dict.PutRect("BBox", -253, 0, 253, 545)
	
	# Create and set the matrix
	pattern_mtx = Matrix2D.new(0.3,0,0,0.3,0,0)
	pattern_dict.PutMatrix("Matrix", pattern_mtx)
	
	# Set the desired horizontal and vertical spacing between pattern cells, 
	# measured in the pattern coordinate system.
	pattern_dict.PutNumber("XStep", 300)
	pattern_dict.PutNumber("YStep", 300)
	
	return pattern_dict	 # finished creating the Pattern resource
end
	
def CreateAxialShading(doc)
	# Create a new Shading object ------------
	pattern_dict = doc.CreateIndirectDict
	
	# Initialize pattern dictionary. For details on what each parameter represents 
	# please refer to Tables 4.30 and 4.26 in PDF Reference Manual
	pattern_dict.PutName("Type", "Pattern")
	pattern_dict.PutNumber("PatternType", 2)	# 2 stands for shading
	
	shadingDict = pattern_dict.PutDict("Shading")
	shadingDict.PutNumber("ShadingType",2)
	shadingDict.PutName("ColorSpace","DeviceCMYK")
	
	# pass the coordinates of the axial shading to the output
	shadingCoords = shadingDict.PutArray("Coords")
	shadingCoords.PushBackNumber(0)
	shadingCoords.PushBackNumber(0)
	shadingCoords.PushBackNumber(612)
	shadingCoords.PushBackNumber(794)
	
	# pass the function to the axial shading
	function = shadingDict.PutDict("Function")
	c0 = function.PutArray("C0")
	c0.PushBackNumber(1)
	c0.PushBackNumber(0)
	c0.PushBackNumber(0)
	c0.PushBackNumber(0)
	
	c1 = function.PutArray("C1")
	c1.PushBackNumber(0)
	c1.PushBackNumber(1)
	c1.PushBackNumber(0)
	c1.PushBackNumber(0)
	
	domain = function.PutArray("Domain")
	domain.PushBackNumber(0)
	domain.PushBackNumber(1)
	
	function.PutNumber("FunctionType", 2)
	function.PutNumber("N", 1)
	
	return pattern_dict
end

	PDFNet.Initialize
	  
	doc = PDFDoc.new
	writer = ElementWriter.new
	eb = ElementBuilder.new
	
	# The following sample illustrates how to create and use tiling patterns
	page = doc.PageCreate
	writer.Begin(page)
	
	element = eb.CreateTextBegin(Font.Create(doc.GetSDFDoc, Font::E_times_bold), 1)
	writer.WriteElement(element) # Begin the text block
	
	data = "G"
	element = eb.CreateTextRun(data)
	element.SetTextMatrix(720, 0, 0, 720, 20, 240)
	gs = element.GetGState
	gs.SetTextRenderMode(GState::E_fill_stroke_text)
	gs.SetLineWidth(4)
	
	# Set the fill color space to the Pattern color space. 
	gs.SetFillColorSpace(ColorSpace.CreatePattern)
	gs.SetFillColor(PatternColor.new(CreateTilingPattern(doc)))
	
	element.SetPathFill(true)
   
	writer.WriteElement(element)
	writer.WriteElement(eb.CreateTextEnd) # Finish the text block
	
	writer.End # Save the page
	doc.PagePushBack(page)
	
	#-----------------------------------------------
	# The following sample illustrates how to create and use image tiling pattern
	
	page = doc.PageCreate
	writer.Begin(page)
	
	eb.Reset
	element = eb.CreateRect(0, 0, 612, 794)
	
	# Set the fill color space to the Pattern color space. 
	gs = element.GetGState
	gs.SetFillColorSpace(ColorSpace.CreatePattern)
	gs.SetFillColor(PatternColor.new(CreateImageTilingPattern(doc)))
	element.SetPathFill(true)
	
	writer.WriteElement(element)
	
	writer.End	# Save the page
	doc.PagePushBack(page)
	
	#-----------------------------------------------
	
	# The following sample illustrates how to create and use PDF shadings
	page = doc.PageCreate
	writer.Begin(page)
	
	eb.Reset
	element = eb.CreateRect(0, 0, 612, 794)
	
	# Set the fill color space to the Pattern color space. 
	gs = element.GetGState
	gs.SetFillColorSpace(ColorSpace.CreatePattern)
	gs.SetFillColor(PatternColor.new(CreateAxialShading(doc)))
	element.SetPathFill(true)
	
	writer.WriteElement(element)
	writer.End	# save the page
	doc.PagePushBack(page)
	#-----------------------------------------------
	
	doc.Save($output_path + "patterns.pdf", SDFDoc::E_remove_unused)
	puts "Done. Result saved in patterns.pdf..."
	
	doc.Close

