//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	. "pdftron"
)

// This sample project illustrates how to recompress bi-tonal images in an 
// existing PDF document using JBIG2 compression. The sample is not intended 
// to be a generic PDF optimization tool.
//
// You can download the entire document using the following link:
//   http://www.pdftron.com/net/samplecode/data/US061222892.pdf
// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

func main(){
    PDFNetInitialize()
    
    pdfDoc := NewPDFDoc(inputPath + "US061222892-a.pdf")
    pdfDoc.InitSecurityHandler()
    
    cosDoc := pdfDoc.GetSDFDoc()
    numObjs := cosDoc.XRefSize()
    
    i := uint(1)
    for i < numObjs{
        obj := cosDoc.GetObj(i)
        if obj != nil && ! obj.IsFree() && obj.IsStream(){
            // Process only images
            itr := obj.Find("Subtype")
            //if not itr.HasNext() or not itr.Value().GetName() == "Image":
            if !itr.HasNext() || !(itr.Value().GetName() == "Image"){
                i = i + 1
                continue
            }
            inputImage := NewImage(obj)
            // Process only gray-scale images
            if inputImage.GetComponentNum() != 1{
                i = i + 1
                continue
            }
            // Skip images that are already compressed using JBIG2
            itr = obj.Find("Filter")
            if (itr.HasNext() && itr.Value().IsName() && itr.Value().GetName() == "JBIG2Decode"){
                i = i + 1
                continue
            }

            filter := obj.GetDecodedStream()
            reader := NewFilterReader(filter)
            
            hintSet := NewObjSet()     // hint to image encoder to use JBIG2 compression
            hint := hintSet.CreateArray()
            
            hint.PushBackName("JBIG2")
            hint.PushBackName("Lossless")
            
            newImage := (ImageCreate(cosDoc, reader, 
                                     inputImage.GetImageWidth(), 
                                     inputImage.GetImageHeight(), 
                                     1, 
                                     ColorSpaceCreateDeviceGray(), 
                                     hint))
            
            newImgObj := newImage.GetSDFObj()
            itr = obj.Find("Decode")
            
            if itr.HasNext(){
                newImgObj.Put("Decode", itr.Value())
            }
            itr = obj.Find("ImageMask")
            if itr.HasNext(){
                newImgObj.Put("ImageMask", itr.Value())
            }
            itr = obj.Find("Mask")
            if itr.HasNext(){
                newImgObj.Put("Mask", itr.Value())
            }

            cosDoc.Swap(i, newImgObj.GetObjNum())
        }
        i = i + 1
    }

    pdfDoc.Save(outputPath + "US061222892_JBIG2.pdf", uint(SDFDocE_remove_unused))
    pdfDoc.Close()                
}
