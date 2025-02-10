//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
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

//-----------------------------------------------------------------------------------------
// The sample code illustrates how to read and edit existing outline items and create 
// new bookmarks using the high-level API.
//-----------------------------------------------------------------------------------------

// Relattive path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

func PrintIndent(item Bookmark){
    indent := item.GetIndent() - 1
    i := 0
    for i < indent{
        os.Stdout.Write([]byte("  "))
        i = i + 1
    }
}

// Prints out the outline tree to the standard output
func PrintOutlineTree (item Bookmark){
    for item.IsValid(){
        PrintIndent(item)

        if item.IsOpen(){
            os.Stdout.Write([]byte("- " + item.GetTitle() + " ACTION -> "))
        }else{
            os.Stdout.Write([]byte("+ " + item.GetTitle() + " ACTION -> "))
        }

        // Print Action
        action := item.GetAction()
        if action.IsValid(){
            if action.GetType() == ActionE_GoTo{
                dest := action.GetDest()
                if dest.IsValid(){
                    page := dest.GetPage()
                    fmt.Println("GoTo Page //" + strconv.Itoa(page.GetIndex()))
                }
            }else{
                fmt.Println("Not a 'GoTo' action")
            }
        }else{
            fmt.Println("NULL")
        }
        // Recursively print children sub-trees   
        if item.HasChildren(){        
            PrintOutlineTree(item.GetFirstChild())
        }
        item = item.GetNext()
    }
}            

func TestBookmark(t *testing.T){
    PDFNetInitialize(licenseKey)

    // The following example illustrates how to create and edit the outline tree
    // using high-level Bookmark methods.
    
    doc := NewPDFDoc(inputPath + "numbered.pdf")
    doc.InitSecurityHandler()
    
    // Lets first create the root bookmark items. 
    red := BookmarkCreate(doc, "Red")
    green := BookmarkCreate(doc, "Green")
    blue := BookmarkCreate(doc, "Blue")
    
    doc.AddRootBookmark(red)
    doc.AddRootBookmark(green)
    doc.AddRootBookmark(blue)
    
    // You can also add new root bookmarks using Bookmark.AddNext("...")
    blue.AddNext("foo")
    blue.AddNext("bar")

    // We can now associate new bookmarks with page destinations:
    
    // The following example creates an 'explicit' destination (see 
    // section '8.2.1 Destinations' in PDF Reference for more details)
    itr := doc.GetPageIterator()
    redDest := DestinationCreateFit(itr.Current())
    red.SetAction(ActionCreateGoto(redDest))

    // Create an explicit destination to the first green page in the document
    green.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(10))))

    // The following example creates a 'named' destination (see 
    // section '8.2.1 Destinations' in PDF Reference for more details)
    // Named destinations have certain advantages over explicit destinations.
    key := []byte("blue1")
    blueAction := ActionCreateGoto(&key[0], 2, DestinationCreateFit(doc.GetPage(19)))
    
    blue.SetAction(blueAction)
    
    // We can now add children Bookmarks
    subRed1 := red.AddChild("Red - Page 1")
    subRed1.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(1))))
    subRed2 := red.AddChild("Red - Page 2")
    subRed2.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(2))))
    subRed3 := red.AddChild("Red - Page 3")
    subRed3.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(3))))
    subRed4 := subRed3.AddChild("Red - Page 4")
    subRed4.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(4))))
    subRed5 := subRed3.AddChild("Red - Page 5")
    subRed5.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(5))))
    subRed6 := subRed3.AddChild("Red - Page 6")
    subRed6.SetAction(ActionCreateGoto(DestinationCreateFit(doc.GetPage(6))))
    
    // Example of how to find and delete a bookmark by title text.
    foo := doc.GetFirstBookmark().Find("foo")
    if foo.IsValid(){
        foo.Delete()
    }else{
        panic("Foo is not Valid")
    }
    bar := doc.GetFirstBookmark().Find("bar")
    if bar.IsValid(){
        bar.Delete()
    }else{
        panic("Bar is not Valid")
    }
    // Adding color to Bookmarks. Color and other formatting can help readers 
    // get around more easily in large PDF documents.
    red.SetColor(1.0, 0.0, 0.0);
    green.SetColor(0.0, 1.0, 0.0);
    green.SetFlags(2);            // set bold font
    blue.SetColor(0.0, 0.0, 1.0);
    blue.SetFlags(3);             // set bold and itallic
    
    doc.Save(outputPath + "bookmark.pdf", uint(0))
    doc.Close()
    fmt.Println("Done. Result saved in bookmark.pdf")

    // The following example illustrates how to traverse the outline tree using 
    // Bookmark navigation methods: Bookmark.GetNext(), Bookmark.GetPrev(), 
    // Bookmark.GetFirstChild () and Bookmark.GetLastChild ().
    
    // Open the document that was saved in the previous code sample
    doc = NewPDFDoc(outputPath + "bookmark.pdf")
    doc.InitSecurityHandler()
    
    root := doc.GetFirstBookmark()
    PrintOutlineTree(root)
    
    doc.Close()
    fmt.Println("Done.")
    
    // The following example illustrates how to create a Bookmark to a page 
    // in a remote document. A remote go-to action is similar to an ordinary 
    // go-to action, but jumps to a destination in another PDF file instead 
    // of the current file. See Section 8.5.3 'Remote Go-To Actions' in PDF 
    // Reference Manual for details.
    
    doc = NewPDFDoc(outputPath + "bookmark.pdf")
    doc.InitSecurityHandler()
    
    // Create file specification (the file reffered to by the remote bookmark)
    fileSpec := doc.CreateIndirectDict()
    fileSpec.PutName("Type", "Filespec")
    fileSpec.PutString("F", "bookmark.pdf")
    spec := NewFileSpec(fileSpec)
    gotoRemote := ActionCreateGotoRemote(spec, 5, true)
    
    remoteBookmark1 := BookmarkCreate(doc, "REMOTE BOOKMARK 1")
    remoteBookmark1.SetAction(gotoRemote)
    doc.AddRootBookmark(remoteBookmark1)
    
    // Create another remote bookmark, but this time using the low-level SDF/Cos API.
    // Create a remote action
    remoteBookmark2 := BookmarkCreate(doc, "REMOTE BOOKMARK 2")
    doc.AddRootBookmark(remoteBookmark2)
    
    gotoR := remoteBookmark2.GetSDFObj().PutDict("A")
    gotoR.PutName("S","GoToR")  // Set action type
    gotoR.PutBool("NewWindow", true)
    
    // Set the file specification
    gotoR.Put("F", fileSpec)
    
    // jump to the first page. Note that pages are indexed from 0.
    dest := gotoR.PutArray("D")  // Set the destination
    dest.PushBackNumber(9); 
    dest.PushBackName("Fit");
    
    doc.Save(outputPath + "bookmark_remote.pdf", uint(SDFDocE_linearized))
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done. Result saved in bookmark_remote.pdf")
}
