//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2026 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main

import (
	"flag"
	"fmt"
	"math"
	"strings"
	"testing"

	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
	flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
	flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// ---------------------------------------------------------------------------------------
// This sample illustrates the basic text highlight capabilities of PDFNet.
// It simulates a full-text search engine that finds all occurrences of the word 'Federal'.
// It then highlights those words on the page.
//
// Note: The TextSearch class is the preferred solution for searching text within a single
// PDF file. TextExtractor provides search highlighting capabilities where a large number
// of documents are indexed using a 3rd party search engine.
// --------------------------------------------------------------------------------------

func TestHighlights(t *testing.T) {
	// The first step in every application using PDFNet is to initialize the
	// library and set the path to common PDF resources. The library is usually
	// initialized only once, but calling Initialize() multiple times is also fine.
	PDFNetInitialize(licenseKey)

	// Relative path to the folder containing the test files.
	inputPath := "../TestFiles/paragraphs_and_tables.pdf"
	outputPath := "../TestFiles/Output/"

	// Sample code showing how to use high-level text highlight APIs.
	doc := NewPDFDoc(inputPath)
	doc.InitSecurityHandler()

	page := doc.GetPage(1)
	if !page.IsValid() {
		PDFNetTerminate()
		t.Fatal("Page not found.")
	}

	txt := NewTextExtractor()
	txt.Begin(page) // read the page

	// Do not dehyphenate; that would interfere with character offsets
	dehyphen := false

	// Retrieve the page text
	pageText := txt.GetAsText(dehyphen)

	// Simulating a full-text search engine that finds all occurrences of the word 'Federal'.
	// In a real application, plug in your own search engine here.
	searchText := "Federal"

	charRanges := NewVectorCharRange()
	ofs := strings.Index(pageText, searchText)
	for ofs != -1 {
		cr := NewCharRange()
		cr.SetIndex(ofs)
		cr.SetLength(len(searchText))
		charRanges.Add(cr)
		next := strings.Index(pageText[ofs+1:], searchText)
		if next == -1 {
			break
		}
		ofs = ofs + 1 + next
	}

	// Retrieve Highlights object and apply annotations to the page
	hlts := txt.GetHighlights(charRanges)
	hlts.Begin(doc)

	for hlts.HasNext() {
		quads := hlts.GetCurrentQuads()
		count := int(quads.Size())
		for i := 0; i < count; i++ {
			q := quads.Get(i)

			// Each quad has 4 points: q.P1, q.P2, q.P3, q.P4
			x1 := math.Min(math.Min(q.GetP1().GetX(), q.GetP2().GetX()), math.Min(q.GetP3().GetX(), q.GetP4().GetX()))
			x2 := math.Max(math.Max(q.GetP1().GetX(), q.GetP2().GetX()), math.Max(q.GetP3().GetX(), q.GetP4().GetX()))
			y1 := math.Min(math.Min(q.GetP1().GetY(), q.GetP2().GetY()), math.Min(q.GetP3().GetY(), q.GetP4().GetY()))
			y2 := math.Max(math.Max(q.GetP1().GetY(), q.GetP2().GetY()), math.Max(q.GetP3().GetY(), q.GetP4().GetY()))

			highlight := HighlightAnnotCreate(
				doc.GetSDFDoc(),
				NewRect(x1, y1, x2, y2),
			)
			highlight.RefreshAppearance()
			page.AnnotPushBack(highlight)

			fmt.Printf("[%.2f, %.2f, %.2f, %.2f]\n", x1, y1, x2, y2)
		}

		hlts.Next()
	}
	doc.Save(outputPath+"search_highlights.pdf", uint(SDFDocE_linearized))

	doc.Close()

	PDFNetTerminate()
	fmt.Println("Done.")
}
