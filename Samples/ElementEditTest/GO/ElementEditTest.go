//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
	. "pdftron"
)

import  "pdftron/Samples/LicenseKey/GO"

//---------------------------------------------------------------------------------------
// The sample code shows how to edit the page display list and how to modify graphics state 
// attributes on existing Elements. In particular the sample program strips all images from 
// the page, changes path fill color to red, and changes text color to blue. 
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

func catch(err *error) {
    if r := recover(); r != nil {
        *err = fmt.Errorf("%v", r)
    }
}

//---------------------------------------------------------------------------------------


func ProcessElements(reader ElementReader, writer ElementWriter, omap map[uint]Obj) (err error) {

	defer catch(&err)
	
    element := reader.Next()     // Read page contents
    for element.GetMp_elem().Swigcptr() != 0{
        etype := element.GetType()
        if etype == ElementE_image{
            // remove all images by skipping them
        }else if etype == ElementE_inline_image{            
            // remove all images by skipping them
        }else if etype == ElementE_path{
            // Set all paths to red color.
            gs := element.GetGState()
            gs.SetFillColorSpace(ColorSpaceCreateDeviceRGB())
            gs.SetFillColor(NewColorPt(1.0, 0.0, 0.0))
            writer.WriteElement(element)
        }else if etype == ElementE_text{    // Process text strings...
            // Set all text to blue color.
            gs := element.GetGState()
            gs.SetFillColorSpace(ColorSpaceCreateDeviceRGB())
            cp := NewColorPt(0.0, 0.0, 1.0)
            gs.SetFillColor(cp)
            writer.WriteElement(element)
        }else if etype == ElementE_form{    // Recursively process form XObjects
            o := element.GetXObject()
            omap[o.GetObjNum()] = o
            writer.WriteElement(element)
        }else{
            writer.WriteElement(element)
		}
        element = reader.Next()
	}
	
	return nil
}

func main(){
    PDFNetInitialize(PDFTronLicense.Key)
    
    // Relative path to the folder containing the test files.
    inputPath := "../../TestFiles/"
    outputPath := "../../TestFiles/Output/"
    inputFilename := "newsletter.pdf"
    outputFilename := "newsletter_edited.pdf"
    
    
    // Open the test file
    fmt.Println("Opening the input file...")
    doc := NewPDFDoc(inputPath + inputFilename)
    doc.InitSecurityHandler()
    
    writer := NewElementWriter()
    reader := NewElementReader()
    
    itr := doc.GetPageIterator()
    
    for itr.HasNext(){
        page := itr.Current()
        reader.Begin(page)
        writer.Begin(page, ElementWriterE_replacement, false)
        var map1 = make(map[uint]Obj)
        err := ProcessElements(reader, writer, map1)
		if err != nil {
			fmt.Println(fmt.Errorf("Unable to process elements, error: %s", err))
		}
		
        writer.End()
        reader.End()
		
        var map2 = make(map[uint]Obj)
        for !(len(map1) == 0 && len(map2) == 0){
            for k, v := range map1{
                obj := v
                writer.Begin(obj)
                reader.Begin(obj, page.GetResourceDict())
                err = ProcessElements(reader, writer, map2)
				if err != nil {
					fmt.Println(fmt.Errorf("Unable to process elements, error: %s", err))
				}
                reader.End()
                writer.End()
                delete(map1, k)
			}
            if (len(map1) == 0 && len(map2) != 0){
                //map1.update(map2)
				for key, value := range map2{         
					map1[key] = value 
				}
				//map2.clear()
				for k := range map2 {
					delete(map2, k)
				}
			}
		}
        itr.Next()
    }
	
    doc.Save(outputPath + outputFilename, uint(SDFDocE_remove_unused))
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done. Result saved in " + outputFilename +"...")
}
