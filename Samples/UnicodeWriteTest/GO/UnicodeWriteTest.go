//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
    "os"
    "bufio"
    "strconv"
    "runtime"
	. "pdftron"
    "golang.org/x/text/encoding/unicode"
    "golang.org/x/text/transform"
)

import  "pdftron/Samples/LicenseKey/GO"

// Relative path to the folder containing the test files.
var inputPath = "../../TestFiles/"
var outputPath = "../../TestFiles/Output/"

// This example illustrates how to create Unicode text and how to embed composite fonts.
// 
// Note: This demo attempts to make use of 'arialuni.ttf' in the '/Samples/TestFiles' 
// directory. Arial Unicode MS is about 24MB in size and used to come together with Windows and 
// MS Office.
// 
// In case you don't have access to Arial Unicode MS you can use another wide coverage
// font, like Google Noto, GNU UniFont, or cyberbit. Many of these are freely available,
// and there is a list maintained at https://en.wikipedia.org/wiki/Unicode_font
// 
// If no specific font file can be loaded, the demo will fall back to system specific font
// substitution routines, and the result will depend on which fonts are available.
//
// Run "go get golang.org/x/text/encoding/unicode" and "go get golang.org/x/text/transform" to install, 
// if these two packages are not presented.
 
func ReadUnicodeTextLinesFromFile(  writer ElementWriter, 
                                    indexedFont Font, 
                                    eb ElementBuilder, 
                                    linePos float64, 
                                    lineSpace float64, 
                                    showNumOfLines bool, 
                                    readLines bool){
    file, err := os.Open(inputPath + "hindi_sample_utf16le.txt")
    if err != nil {
        fmt.Println(err)
    }
    defer file.Close()
    scanner := bufio.NewScanner(transform.NewReader(file, unicode.UTF16(unicode.LittleEndian, unicode.UseBOM).NewDecoder()))
    i := 0
    if(showNumOfLines){
        for scanner.Scan() {
            i++
        }
        fmt.Println("Read in " + strconv.Itoa(i) + " lines of Unicode text from file")
    }else if(readLines){
        for scanner.Scan() {
            shapedText := indexedFont.GetShapedText(scanner.Text())
            element := eb.CreateShapedTextRun(shapedText)
            element.SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, linePos-lineSpace*(float64(i+1)))
            writer.WriteElement(element)
            fmt.Println("Wrote shaped line to page")  
            i++
        }
    }
    if err := scanner.Err(); err != nil {
        fmt.Println(err)
    }
}

func main(){
    PDFNetInitialize(PDFTronLicense.Key)
    
    doc := NewPDFDoc()
    eb := NewElementBuilder()
    writer := NewElementWriter()
    
    // Start a new page ------------------------------------
    page := doc.PageCreate(NewRect(0.0, 0.0, 612.0, 794.0))
    
    writer.Begin(page)    // begin writing to this page
       
    // Embed and subset the font
    fontProgram := inputPath + "ARIALUNI.TTF"
    fnt := FontCreate(doc.GetSDFDoc(), "Helvetica", "")
    if _, err := os.Stat(fontProgram); err == nil{
      // fontProgram exists
      fnt = FontCreateCIDTrueTypeFont(doc.GetSDFDoc(), fontProgram, true, true)
      fmt.Println("Note: using " + fontProgram + " for unshaped unicode text")
    }else if os.IsNotExist(err){
        if runtime.GOOS == "windows"{
            fontProgram = "C:/Windows/Fonts/ARIALUNI.TTF"
            if _, err := os.Stat(fontProgram); err == nil{
              // fontProgram exists
                fnt = FontCreateCIDTrueTypeFont(doc.GetSDFDoc(), fontProgram, true, true)
                fmt.Println("Note: using " + fontProgram + " for unshaped unicode text")
            }else if os.IsNotExist(err){
                fmt.Println("Note: using system font substitution for unshaped unicode text")
            }else{
                fmt.Println(err)
            }
        }
    }else{
        fmt.Println(err)
    }

    element := eb.CreateTextBegin(fnt, 1.0)
    element.SetTextMatrix(10.0, 0.0, 0.0, 10.0, 50.0, 600.0)
    element.GetGState().SetLeading(2)         // Set the spacing between lines
    writer.WriteElement(element)

    // Hello World!
    hello := []uint16{'H','e','l','l','o',' ','W','o','r','l','d','!'}
    fmt.Println(hello)
    writer.WriteElement(eb.CreateUnicodeTextRun(&hello[0], uint(len(hello))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Latin
    latin := []uint16{'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 0x45, 0x0046, 0x00C0, 
            0x00C1, 0x00C2, 0x0143, 0x0144, 0x0145, 0x0152, '1', '2' }// etc.
    writer.WriteElement(eb.CreateUnicodeTextRun(&latin[0], uint(len(latin))))
    writer.WriteElement(eb.CreateTextNewLine())

    // Greek
    greek := []uint16{0x039E, 0x039F, 0x03A0, 0x03A1,0x03A3, 0x03A6, 0x03A8, 0x03A9}
    writer.WriteElement(eb.CreateUnicodeTextRun(&greek[0], uint(len(greek))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Cyrillic
    cyrillic := []uint16{0x0409, 0x040A, 0x040B, 0x040C, 0x040E, 0x040F, 0x0410, 0x0411,
                0x0412, 0x0413, 0x0414, 0x0415, 0x0416, 0x0417, 0x0418, 0x0419}
    writer.WriteElement(eb.CreateUnicodeTextRun(&cyrillic[0], uint(len(cyrillic))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Hebrew
    hebrew := []uint16{0x05D0, 0x05D1, 0x05D3, 0x05D3, 0x05D4, 0x05D5, 0x05D6, 0x05D7, 0x05D8,
              0x05D9, 0x05DA, 0x05DB, 0x05DC, 0x05DD, 0x05DE, 0x05DF, 0x05E0, 0x05E1}
    writer.WriteElement(eb.CreateUnicodeTextRun(&hebrew[0], uint(len(hebrew))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Arabic
    arabic := []uint16{0x0624, 0x0625, 0x0626, 0x0627, 0x0628, 0x0629, 0x062A, 0x062B, 0x062C,
              0x062D, 0x062E, 0x062F, 0x0630, 0x0631, 0x0632, 0x0633, 0x0634, 0x0635}
    writer.WriteElement(eb.CreateUnicodeTextRun(&arabic[0], uint(len(arabic))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Thai
    thai := []uint16{0x0E01, 0x0E02, 0x0E03, 0x0E04, 0x0E05, 0x0E06, 0x0E07, 0x0E08, 0x0E09, 
            0x0E0A, 0x0E0B, 0x0E0C, 0x0E0D, 0x0E0E, 0x0E0F, 0x0E10, 0x0E11, 0x0E12}
    writer.WriteElement(eb.CreateUnicodeTextRun(&thai[0], uint(len(thai))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Hiragana - Japanese 
    hiragana := []uint16{0x3041, 0x3042, 0x3043, 0x3044, 0x3045, 0x3046, 0x3047, 0x3048, 0x3049,
                0x304A, 0x304B, 0x304C, 0x304D, 0x304E, 0x304F, 0x3051, 0x3051, 0x3052}
    writer.WriteElement(eb.CreateUnicodeTextRun(&hiragana[0], uint(len(hiragana))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // CJK Unified Ideographs 
    cjk_uni := []uint16{0x5841, 0x5842, 0x5843, 0x5844, 0x5845, 0x5846, 0x5847, 0x5848, 0x5849, 
               0x584A, 0x584B, 0x584C, 0x584D, 0x584E, 0x584F, 0x5850, 0x5851, 0x5852}
    writer.WriteElement(eb.CreateUnicodeTextRun(&cjk_uni[0], uint(len(cjk_uni))))
    writer.WriteElement(eb.CreateTextNewLine())
    
    // Simplified Chinese
    chineseSimplified := []uint16{0x4e16, 0x754c, 0x60a8, 0x597d}
    writer.WriteElement(eb.CreateUnicodeTextRun(&chineseSimplified[0], uint(len(chineseSimplified))))
    writer.WriteElement(eb.CreateTextNewLine())

    // Finish the block of text
    writer.WriteElement(eb.CreateTextEnd())

    fmt.Println("Now using text shaping logic to place text")

    // Create a font in indexed encoding mode 
    // normally this would mean that we are required to provide glyph indices
    // directly to CreateUnicodeTextRun, but instead, we will use the GetShapedText
    // method to take care of this detail for us.
    indexedFont := FontCreateCIDTrueTypeFont(doc.GetSDFDoc(), inputPath + "NotoSans_with_hindi.ttf", true, true, FontE_Indices)
    element = eb.CreateTextBegin(indexedFont, 10.0)
    writer.WriteElement(element)

    linePos := 350.0
    lineSpace := 20.0

    // Transform unicode text into an abstract collection of glyph indices and positioning info 
    shapedText := indexedFont.GetShapedText("Shaped Hindi Text:")

    // transform the shaped text info into a PDF element and write it to the page
    element = eb.CreateShapedTextRun(shapedText)
    element.SetTextMatrix(1.5, 0.0, 0.0, 1.5, 50.0, linePos)
    writer.WriteElement(element)
    // read in unicode text lines from a file
    ReadUnicodeTextLinesFromFile(writer, indexedFont, eb, linePos, lineSpace, true, false)
    ReadUnicodeTextLinesFromFile(writer, indexedFont, eb, linePos, lineSpace, false, true)
    
    // Finish the block of text
    writer.WriteElement(eb.CreateTextEnd())

    writer.End()    // save changes to the current page
    doc.PagePushBack(page)
    
    doc.Save(outputPath + "unicodewrite.pdf", uint(SDFDocE_remove_unused | SDFDocE_hex_strings))
    fmt.Println("Done. Result saved in unicodewrite.pdf...")
    
    doc.Close()
    PDFNetTerminate()
}
