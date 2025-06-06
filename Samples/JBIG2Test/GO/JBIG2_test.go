//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "testing"
    "flag"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// This sample project illustrates how to recompress bi-tonal images in an
// existing PDF document using JBIG2 compression. The sample is not intended 
// to be a generic PDF optimization tool.
//
// You can download the entire document using the following link:
//   http://www.pdftron.com/net/samplecode/data/US061222892.pdf
// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func TestJBIG2(t *testing.T){
    PDFNetInitialize(licenseKey)
    
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
            if !itr.HasCurrent() || !(itr.Value().GetName() == "Image"){
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
            if (itr.HasCurrent() && itr.Value().IsName() && itr.Value().GetName() == "JBIG2Decode"){
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
            
            if itr.HasCurrent(){
                newImgObj.Put("Decode", itr.Value())
            }
            itr = obj.Find("ImageMask")
            if itr.HasCurrent(){
                newImgObj.Put("ImageMask", itr.Value())
            }
            itr = obj.Find("Mask")
            if itr.HasCurrent(){
                newImgObj.Put("Mask", itr.Value())
            }

            cosDoc.Swap(i, newImgObj.GetObjNum())
        }
        i = i + 1
    }

    pdfDoc.Save(outputPath + "US061222892_JBIG2.pdf", uint(SDFDocE_remove_unused))
    pdfDoc.Close()                
    PDFNetTerminate()
}
