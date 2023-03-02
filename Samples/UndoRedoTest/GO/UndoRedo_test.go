//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "flag"
	. "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// Relative path to the folder containing test files.
var inputPath =  "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------
// The following sample illustrates how to use the UndoRedo API.
//---------------------------------------------------------------------------------------

func TestUndoRedo(t *testing.T){
    // The first step in every application using PDFNet is to initialize the 
    // library and set the path to common PDF resources. The library is usually 
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    
    // Open the PDF document.
    doc := NewPDFDoc(inputPath + "newsletter.pdf")

    undoManager := doc.GetUndoManager()

    // Take a snapshot to which we can undo after making changes.
    snap0 := undoManager.TakeSnapshot()

    snap0State := snap0.CurrentState()
    
    // Start a new page
    page := doc.PageCreate()

    bld := NewElementBuilder()          // Used to build new Element objects
    writer := NewElementWriter()        // Used to write Elements to the page
    writer.Begin(page)              // Begin writing to this page

    // ----------------------------------------------------------
    // Add JPEG image to the file
    img := ImageCreate(doc.GetSDFDoc(), inputPath + "peppers.jpg")

    element := bld.CreateImage(img, NewMatrix2D(200.0, 0.0, 0.0, 250.0, 50.0, 500.0))
    writer.WritePlacedElement(element)

    // Finish writing to the page
    writer.End()
    doc.PagePushFront(page)

    // Take a snapshot after making changes, so that we can redo later (after undoing first).
    snap1 := undoManager.TakeSnapshot()

    if snap1.PreviousState().Equals(snap0State){
        fmt.Println("snap1 previous state equals snap0State; previous state is correct")
    }    
    snap1State := snap1.CurrentState()

    doc.Save(outputPath + "addimage.pdf", uint(SDFDocE_incremental))

    if undoManager.CanUndo(){
        undoSnap := undoManager.Undo()

        doc.Save(outputPath + "addimage_undone.pdf", uint(SDFDocE_incremental))

        undoSnapState := undoSnap.CurrentState()

        if undoSnapState.Equals(snap0State){
            fmt.Println("undoSnapState equals snap0State; undo was successful")
        }

        if undoManager.CanRedo(){
            redoSnap := undoManager.Redo()

            doc.Save(outputPath + "addimage_redone.pdf", uint(SDFDocE_incremental))

            if redoSnap.PreviousState().Equals(undoSnapState){
                fmt.Println("redoSnap previous state equals undoSnapState; previous state is correct")
            }

            redoSnapState := redoSnap.CurrentState()
            
            if redoSnapState.Equals(snap1State){
                fmt.Println("Snap1 and redoSnap are equal; redo was successful")
            }
        }else{
            fmt.Println("Problem encountered - cannot redo.")
        }
    }else{
        fmt.Println("Problem encountered - cannot undo.")
    }
    PDFNetTerminate()
}
