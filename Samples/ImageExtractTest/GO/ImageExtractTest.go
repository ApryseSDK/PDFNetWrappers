//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "strconv"
    . "pdftron"
)

import  "pdftron/Samples/LicenseKey/GO"

//-----------------------------------------------------------------------------------
// This sample illustrates one approach to PDF image extraction 
// using PDFNet.
// 
// Note: Besides direct image export, you can also convert PDF images 
// to GDI+ Bitmap, or extract uncompressed/compressed image data directly 
// using element.GetImageData() (e.g. as illustrated in ElementReaderAdv 
// sample project).
//-----------------------------------------------------------------------------------

var imageCounter = 0

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

//---------------------------------------------------------------------------------------

func catch(err *error) {
    if r := recover(); r != nil {
        *err = fmt.Errorf("%v", r)
    }
}

//---------------------------------------------------------------------------------------


func ImageExtract(reader ElementReader) (err error){

	defer catch(&err)
	
    element := reader.Next()

    for element.GetMp_elem().Swigcptr() != 0{
        if (element.GetType() == ElementE_image ||
            element.GetType() == ElementE_inline_image){
            imageCounter += 1
            fmt.Println("--> Image: " + strconv.Itoa(imageCounter))
            fmt.Println("    Width: " + strconv.Itoa(element.GetImageWidth()))
            fmt.Println("    Height: " + strconv.Itoa(element.GetImageHeight()))
            fmt.Println("    BPC: " + strconv.Itoa(element.GetBitsPerComponent()))
            
            ctm := element.GetCTM()
            x2 := 1
            y2 := 1
            pt := NewPoint(float64(x2), float64(y2))
            point := ctm.Mult(pt)
            fmt.Println("    Coords: x1=%.2f, y1=%.2f, x2=%.2f, y2=%.2f", ctm.GetM_h(), ctm.GetM_v(), point.GetX(), point.GetY())
            
            if element.GetType() == ElementE_image{
                image := NewImage(element.GetXObject())
                
                fname := "image_extract1_" + strconv.Itoa(imageCounter)
                
                path := outputPath + fname
                image.Export(path)
                
                //path = outputPath + fname + ".tif"
                //image.ExportAsTiff(path)
                
                //path = outputPath + fname + ".png"
                //image.ExportAsPng(path)
            }
        }else if element.GetType() == ElementE_form{
            reader.FormBegin()
            ImageExtract(reader)
            reader.End() 
        }
        element = reader.Next()
    }
	
	return nil
}

func main(){
    // Initialize PDFNet
    PDFNetInitialize(PDFTronLicense.Key)    
    
    // Example 1: 
    // Extract images by traversing the display list for 
    // every page. With this approach it is possible to obtain 
    // image positioning information and DPI.
    
    doc := NewPDFDoc(inputPath + "newsletter.pdf")
    doc.InitSecurityHandler()
    
    reader := NewElementReader()
    
    // Read every page
    itr := doc.GetPageIterator()
    for itr.HasNext(){
        reader.Begin(itr.Current())
        err := ImageExtract(reader)
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to extract image, error: %s", err))
		}
        reader.End()
        itr.Next()
    }

    doc.Close()
    fmt.Println("Done.")
    
    fmt.Println("----------------------------------------------------------------")
    
    // Example 2: 
    // Extract images by scanning the low-level document.
    
    doc = NewPDFDoc(inputPath + "newsletter.pdf")
    doc.InitSecurityHandler()
    imageCounter= 0
    
    cosDoc := doc.GetSDFDoc()
    numObjs := cosDoc.XRefSize()
    i := uint(1)
    for i < numObjs{
        obj := cosDoc.GetObj(i)
        if(obj != nil && !obj.IsFree() && obj.IsStream()){
            
            // Process only images
            itr := obj.Find("Type")
            
            if (!itr.HasNext()) || (itr.Value().GetName() != "XObject"){
                i = i + 1
                continue
            }
            itr = obj.Find("Subtype")
            if (!itr.HasNext()) || (itr.Value().GetName() != "Image"){
                i = i + 1
                continue
            }
            image := NewImage(obj)
            
            imageCounter = imageCounter + 1
            fmt.Println("--> Image: " + strconv.Itoa(imageCounter))
            fmt.Println("    Width: " + strconv.Itoa(image.GetImageWidth()))
            fmt.Println("    Height: " + strconv.Itoa(image.GetImageHeight()))
            fmt.Println("    BPC: " + strconv.Itoa(image.GetBitsPerComponent()))
            
            fname := "image_extract2_" + strconv.Itoa(imageCounter)
                
            path := outputPath + fname
            image.Export(path)
            
            //path = outputPath + fname + ".tif"
            //image.ExportAsTiff(path)
            
            //path = outputPath + fname + ".png"
            //image.ExportAsPng(path)
        }
        i = i + 1
    }
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
