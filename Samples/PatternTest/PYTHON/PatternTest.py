#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

import site
site.addsitedir("../../../PDFNetC/Lib")
import sys
from PDFNetPython import *

# Relative path to the folder containing the test files.
input_path = "../../TestFiles/"
output_path = "../../TestFiles/Output/"

def CreateTilingPattern(doc):
    writer = ElementWriter()
    eb = ElementBuilder()
    
    # Create a new pattern content stream - a heart. ------------
    writer.Begin(doc.GetSDFDoc())
    eb.PathBegin()
    eb.MoveTo(0, 0)
    eb.CurveTo(500, 500, 125, 625, 0, 500)
    eb.CurveTo(-125, 625, -500, 500, 0, 0)
    heart = eb.PathEnd()
    heart.SetPathFill(True)
    
    # Set heart color to red.
    heart.GetGState().SetFillColorSpace(ColorSpace.CreateDeviceRGB()) 
    heart.GetGState().SetFillColor(ColorPt(1, 0, 0)) 
    writer.WriteElement(heart)
    
    pattern_dict = writer.End()
    
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
    pattern_mtx = Matrix2D(0.04,0,0,0.04,0,0)
    pattern_dict.PutMatrix("Matrix", pattern_mtx)
    
    # Set the desired horizontal and vertical spacing between pattern cells, 
    # measured in the pattern coordinate system.
    pattern_dict.PutNumber("XStep", 1000)
    pattern_dict.PutNumber("YStep", 1000)
    
    return pattern_dict # finished creating the Pattern resource

    
    
    
def CreateImageTilingPattern(doc):
    writer = ElementWriter()
    eb = ElementBuilder()
    
    # Create a new pattern content stream - a single bitmap object ----------
    writer.Begin(doc.GetSDFDoc())
    image = Image.Create(doc.GetSDFDoc(), input_path + "dice.jpg")
    img_element = eb.CreateImage(image, 0, 0, image.GetImageWidth(), image.GetImageHeight())
    writer.WritePlacedElement(img_element)
    pattern_dict = writer.End()
    
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
    pattern_mtx = Matrix2D(0.3,0,0,0.3,0,0)
    pattern_dict.PutMatrix("Matrix", pattern_mtx)
    
    # Set the desired horizontal and vertical spacing between pattern cells, 
    # measured in the pattern coordinate system.
    pattern_dict.PutNumber("XStep", 300)
    pattern_dict.PutNumber("YStep", 300)
    
    return pattern_dict     # finished creating the Pattern resource
    
    
def CreateAxialShading(doc):
    # Create a new Shading object ------------
    pattern_dict = doc.CreateIndirectDict()
    
    # Initialize pattern dictionary. For details on what each parameter represents 
    # please refer to Tables 4.30 and 4.26 in PDF Reference Manual
    pattern_dict.PutName("Type", "Pattern")
    pattern_dict.PutNumber("PatternType", 2)    # 2 stands for shading
    
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
    C0 = function.PutArray("C0")
    C0.PushBackNumber(1)
    C0.PushBackNumber(0)
    C0.PushBackNumber(0)
    C0.PushBackNumber(0)
    
    C1 = function.PutArray("C1")
    C1.PushBackNumber(0)
    C1.PushBackNumber(1)
    C1.PushBackNumber(0)
    C1.PushBackNumber(0)
    
    domain = function.PutArray("Domain")
    domain.PushBackNumber(0)
    domain.PushBackNumber(1)
    
    function.PutNumber("FunctionType", 2)
    function.PutNumber("N", 1)
    
    return pattern_dict
    

def main():
    PDFNet.Initialize()
      
    doc = PDFDoc()
    writer = ElementWriter()
    eb = ElementBuilder()
    
    # The following sample illustrates how to create and use tiling patterns
    page = doc.PageCreate()
    writer.Begin(page)
    
    element = eb.CreateTextBegin(Font.Create(doc.GetSDFDoc(), Font.e_times_bold), 1)
    writer.WriteElement(element) # Begin the text block
    
    data = "G"
    element = eb.CreateTextRun(data)
    element.SetTextMatrix(720, 0, 0, 720, 20, 240)
    gs = element.GetGState()
    gs.SetTextRenderMode(GState.e_fill_stroke_text)
    gs.SetLineWidth(4)
    
    # Set the fill color space to the Pattern color space. 
    gs.SetFillColorSpace(ColorSpace.CreatePattern())
    gs.SetFillColor(PatternColor(CreateTilingPattern(doc)))
    
    element.SetPathFill(True)
   
    writer.WriteElement(element)
    writer.WriteElement(eb.CreateTextEnd()) # Finish the text block
    
    writer.End() # Save the page
    doc.PagePushBack(page)
    
    #-----------------------------------------------
    # The following sample illustrates how to create and use image tiling pattern
    
    page = doc.PageCreate()
    writer.Begin(page)
    
    eb.Reset()
    element = eb.CreateRect(0, 0, 612, 794)
    
    # Set the fill color space to the Pattern color space. 
    gs = element.GetGState()
    gs.SetFillColorSpace(ColorSpace.CreatePattern())
    gs.SetFillColor(PatternColor(CreateImageTilingPattern(doc)))
    element.SetPathFill(True)
    
    writer.WriteElement(element)
    
    writer.End()    # Save the page
    doc.PagePushBack(page)
    
    #-----------------------------------------------
    
    # The following sample illustrates how to create and use PDF shadings
    page = doc.PageCreate()
    writer.Begin(page)
    
    eb.Reset()
    element = eb.CreateRect(0, 0, 612, 794)
    
    # Set the fill color space to the Pattern color space. 
    gs = element.GetGState()
    gs.SetFillColorSpace(ColorSpace.CreatePattern())
    gs.SetFillColor(PatternColor(CreateAxialShading(doc)))
    element.SetPathFill(True)
    
    writer.WriteElement(element)
    writer.End()    # save the page
    doc.PagePushBack(page)
    #-----------------------------------------------
    
    doc.Save(output_path + "patterns.pdf", SDFDoc.e_remove_unused)
    print("Done. Result saved in patterns.pdf...")
    
    doc.Close()

if __name__ == '__main__':
    main()
    