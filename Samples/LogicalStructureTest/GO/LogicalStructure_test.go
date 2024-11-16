//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "strconv"
    "testing"
    "flag"
    "os"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// This sample explores the structure and content of a tagged PDF document and dumps 
// the structure information to the console window.
//
// In tagged PDF documents StructTree acts as a central repository for information 
// related to a PDF document's logical structure. The tree consists of StructElement-s
// and ContentItem-s which are leaf nodes of the structure tree.
//
// The sample can be extended to access and extract the marked-content elements such 
// as text and images.
//---------------------------------------------------------------------------------------

func PrintIndent(indent int){
   os.Stdout.Write([]byte("\n"))
   i := 0
    for i < indent{
        os.Stdout.Write([]byte("  "))
        i = i + 1
    }
}

func ProcessStructElement(element SElement, indent int){
    if !element.IsValid(){
        return
    }

    // Print out the type and title info, if any.
    PrintIndent(indent)
    indent = indent + 1
    os.Stdout.Write([]byte("Type: " + element.GetType()))
    if element.HasTitle(){
        os.Stdout.Write([]byte(". Title:" + element.GetTitle()))
    }
    num := element.GetNumKids()
    i := 0
    for i < num{
        // Check if the kid is a leaf node (i.e. it is a ContentItem)
        if element.IsContentItem(i){
            cont := element.GetAsContentItem(i)
            etype := cont.GetType()
            
            page := cont.GetPage()
            
            PrintIndent(indent)
            os.Stdout.Write([]byte("Content Item. Part of page //" + strconv.Itoa(page.GetIndex())))
            PrintIndent(indent)
            if etype == ContentItemE_MCID{
                os.Stdout.Write([]byte("MCID: " + strconv.Itoa(cont.GetMCID())))
            }else if etype == ContentItemE_MCR{
                os.Stdout.Write([]byte("MCID: " + strconv.Itoa(cont.GetMCID())))
            }else if etype == ContentItemE_OBJR{
                os.Stdout.Write([]byte("OBJR "))
                refObj := cont.GetRefObj()
                if refObj != nil{
                    os.Stdout.Write([]byte("- Referenced Object//: " + strconv.Itoa(int(refObj.GetObjNum()))))
                }
            }
        }else{
            ProcessStructElement(element.GetAsStructElem(i), indent)
        }
        i = i + 1
    }
}    

// Used in code snippet 3.
func ProcessElements2(reader ElementReader, mcidPageMap map[int]string){
    element := reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{ // Read page contents
        // In this sample we process only text, but the code can be extended
        // to handle paths, images, or other Element type.
        mcid := element.GetStructMCID()
        
        if mcid >= 0 && element.GetType() == ElementE_text{
            val := element.GetTextString()
            if _, ok := mcidPageMap[mcid]; ok {
                mcidPageMap[mcid] = mcidPageMap[mcid] + val
            }else{
                mcidPageMap[mcid] = val
            }
        }
        element = reader.Next()
    }
}

// Used in code snippet 2.
func ProcessElements(reader ElementReader){
    element := reader.Next()
    for element.GetMp_elem().Swigcptr() != 0{  // Read page contents
        // In this sample we process only paths & text, but the code can be 
        // extended to handle any element type.
        etype := element.GetType()
        if (etype == ElementE_path ||
            etype == ElementE_text){
            if etype == ElementE_path{      // Process path ...
                os.Stdout.Write([]byte("\nPATH: "))
            }else if etype == ElementE_text{    // Process text ...
                os.Stdout.Write([]byte("\nTEXT: " + element.GetTextString() + "\n"))
            }else if etype == ElementE_path{    // Process from XObjects
                os.Stdout.Write([]byte("\nFORM XObject: "))
            }

            // Check if the element is associated with any structural element.
            // Content items are leaf nodes of the structure tree.
            structParent := element.GetParentStructElement()
            if structParent.IsValid(){
                // Print out the parent structural element's type, title, and object number.
                os.Stdout.Write([]byte(" Type: " + structParent.GetType() + ", MCID: " + strconv.Itoa(element.GetStructMCID())))
                if structParent.HasTitle(){
                    os.Stdout.Write([]byte(". Title: " + structParent.GetTitle()))
                }
                os.Stdout.Write([]byte(", Obj//: " + strconv.Itoa(int(structParent.GetSDFObj().GetObjNum()))))
            }
        }
        element = reader.Next()
    }
}        
        
func ProcessStructElement2(element SElement, mcidDocMap map[int](map[int]string), indent int){
    if !element.IsValid(){
        return
    }
    // Print out the type and title info, if any
    PrintIndent(indent)
    os.Stdout.Write([]byte("<" + element.GetType()))
    if element.HasTitle(){
        os.Stdout.Write([]byte(" title=\"" + element.GetTitle() + "\""))
    }
    os.Stdout.Write([]byte(">"))
    
    num := element.GetNumKids()
    i := 0
    for i < num{
        if element.IsContentItem(i){
            cont := element.GetAsContentItem(i)
            if cont.GetType() == ContentItemE_MCID{
                pageNum := cont.GetPage().GetIndex()
                if _, ok := mcidDocMap[pageNum]; ok{
                    mcidPageMap := mcidDocMap[pageNum]
                    mcidKey := cont.GetMCID()
                    if _, ok := mcidPageMap[mcidKey]; ok{
                        os.Stdout.Write([]byte(mcidPageMap[mcidKey]))
                    }
                }
            }
        }else{ // the kid is another StructElement node.
            ProcessStructElement2(element.GetAsStructElem(i), mcidDocMap, indent+1)     
        } 
        i = i + 1
    }
    PrintIndent(indent)
    os.Stdout.Write([]byte("</" + element.GetType() + ">"))
}        

func TestLogicalStructure(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    
    // Extract logical structure from a PDF document
    doc := NewPDFDoc(inputPath + "tagged.pdf")
    doc.InitSecurityHandler()
    
    fmt.Println("____________________________________________________________")
    fmt.Println("Sample 1 - Traverse logical structure tree...")
    
    tree := doc.GetStructTree()
    if tree.IsValid(){
        fmt.Println("Document has a StructTree root.")
        
        i := 0
        for i < tree.GetNumKids(){
            // Recursively get structure info for all child elements.
            ProcessStructElement(tree.GetKid(i), 0)
            i = i + 1
        }
    }else{
        fmt.Println("This document does not contain any logical structure.")
    }

    fmt.Println("\nDone 1.")

    fmt.Println("____________________________________________________________")
    fmt.Println("Sample 2 - Get parent logical structure elements from")
    fmt.Println("layout elements.")
    
    reader := NewElementReader()
    itr := doc.GetPageIterator()
    for itr.HasNext(){
        reader.Begin(itr.Current())
        ProcessElements(reader)
        reader.End()
        itr.Next()
    }

    fmt.Println("\nDone 2.")
    
    fmt.Println("____________________________________________________________")
    fmt.Println("Sample 3 - 'XML style' extraction of PDF logical structure and page content.")
    // A map which maps page numbers(as Integers)
    // to page Maps(which map from struct mcid(as Integers) to
    // text Strings)
    var mcidDocMap = make(map[int](map[int]string))
    reader = NewElementReader()
    itr = doc.GetPageIterator()
    for itr.HasNext(){
        reader.Begin(itr.Current())
        var pageMcidMap = make(map[int]string)
        mcidDocMap[itr.Current().GetIndex()] = pageMcidMap
        ProcessElements2(reader, pageMcidMap)
        reader.End()
        itr.Next() 
    } 
    tree = doc.GetStructTree()
    if tree.IsValid(){
        i := 0
        for i < tree.GetNumKids(){
            ProcessStructElement2(tree.GetKid(i), mcidDocMap, 0)
            i = i + 1  
        }
    }
    fmt.Println("\nDone 3.")
    doc.Save(outputPath + "LogicalStructure.pdf", uint(SDFDocE_linearized))
    doc.Close()        
    PDFNetTerminate()
}
