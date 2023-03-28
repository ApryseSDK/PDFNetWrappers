//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2023 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "strconv"
    "os"
    "flag"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func PrintStyle (style Style){
    sansSerifStr := ""
    if style.IsSerif(){
        sansSerifStr = " sans-serif;"
	}
    rgb := style.GetColor()
    rgbHex := fmt.Sprintf("%02X%02X%02X;", rgb.Get(0), rgb.Get(1), rgb.Get(2))
    fontStr := fmt.Sprintf("%g", style.GetFontSize())
    os.Stdout.Write([]byte(" style=\"font-family:" + style.GetFontName() + "; font-size:" + fontStr + ";" + sansSerifStr + " color:#" + rgbHex + "\""))
}

func DumpAllText (reader ElementReader){
    element := reader.Next()

    for element.GetMp_elem().Swigcptr() != 0{
        etype := element.GetType()
        if etype == ElementE_text_begin{
            fmt.Println("Text Block Begin")
        }else if etype == ElementE_text_end{
            fmt.Println("Text Block End")
        }else if etype == ElementE_text{
            bbox := element.GetBBox()
            fmt.Println("BBox: " + fmt.Sprintf("%f", bbox.GetX1()) + ", " + fmt.Sprintf("%f", bbox.GetY1()) + ", " +
						fmt.Sprintf("%f", bbox.GetX2()) + ", " + fmt.Sprintf("%f", bbox.GetY2()))
            textString := element.GetTextString()
            fmt.Println(textString)
        }else if etype == ElementE_text_new_line{
            fmt.Println("New Line")
        }else if etype == ElementE_form{
            reader.FormBegin()
            DumpAllText(reader)
            reader.End()
		}
        element = reader.Next()
	}
}

// A utility method used to extract all text content from
// a given selection rectangle. The recnagle coordinates are
// expressed in PDF user/page coordinate system.
func ReadTextFromRect (page Page, pos Rect, reader ElementReader) string{
    reader.Begin(page)
    srchStr := RectTextSearch(reader, pos)
    reader.End()
    return srchStr
}
//A helper method for ReadTextFromRect
func RectTextSearch (reader ElementReader, pos Rect) string{
    element := reader.Next()
    srchStr2 := ""
    for element.GetMp_elem().Swigcptr() != 0{
        etype := element.GetType()
        if etype == ElementE_text{
            bbox := element.GetBBox()
            if (bbox.IntersectRect(bbox, pos)){
                arr := element.GetTextString()
                srchStr2 += arr
                srchStr2 += "\n"
			}
        }else if etype == ElementE_text_new_line{
            //handle text new line here
        }else if etype == ElementE_form{
            reader.FormBegin()
            srchStr2 += RectTextSearch(reader, pos)
            fmt.Println(srchStr2)
            reader.End()
		}
        element = reader.Next()
	}
    return srchStr2
}

func TestTextExtract(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing test files.
    inputPath :=  "../TestFiles/newsletter.pdf"
    example1Basic := false
    example2Xml := false
    example3Wordlist := false
    example4Advanced := true
    example5LowLevel := false
   
    // Sample code showing how to use high-level text extraction APIs.
    doc := NewPDFDoc(inputPath)
    doc.InitSecurityHandler()
    
    page := doc.GetPage(1)
    if page == nil{
        fmt.Println("page no found")
    }    
    txt := NewTextExtractor()
    txt.Begin(page) // Read the page
    
    // Example 1. Get all text on the page in a single string.
    // Words will be separated witht space or new line characters.
    if example1Basic{
        fmt.Println("Word count: " + strconv.Itoa(txt.GetWordCount()))
        txtAsText := txt.GetAsText()
        fmt.Println("- GetAsText --------------------------" + txtAsText)
        fmt.Println("-----------------------------------------------------------")
	}
    // Example 2. Get XML logical structure for the page.
    if example2Xml{
        text := txt.GetAsXML(TextExtractorE_words_as_elements | 
                            TextExtractorE_output_bbox | 
                            TextExtractorE_output_style_info)       
        fmt.Println("- GetAsXML  --------------------------" + text)
        fmt.Println("-----------------------------------------------------------")
    }
    // Example 3. Extract words one by one.
    if example3Wordlist{
        word := NewWord()
        line := txt.GetFirstLine()
        for line.IsValid(){
            word = line.GetFirstWord()
            for word.IsValid(){
                wordString := word.GetString()
                fmt.Println(wordString)
                word = word.GetNextWord()
			}
            line = line.GetNextLine()
		}
        fmt.Println("-----------------------------------------------------------")
	}
    // Example 4. A more advanced text extraction example. 
    // The output is XML structure containing paragraphs, lines, words, 
    // as well as style and positioning information.
    if example4Advanced{
        bbox := NewRect()
        curFlowId := -1
        curParaId := -1
        
        fmt.Println("<PDFText>")
        // For each line on the page...
        line := txt.GetFirstLine()
        for line.IsValid(){
            if line.GetNumWords() == 0{
                line = line.GetNextLine()			
                continue
			}
            word := line.GetFirstWord()
            if curFlowId != line.GetFlowID(){
                if curFlowId != -1{
                    if curParaId != -1{
                        curParaId = -1
                        fmt.Println("</Para>")
					}
                    fmt.Println("</Flow>")
				}
                curFlowId = line.GetFlowID()
                fmt.Println("<Flow id=\"" + strconv.Itoa(curFlowId) +"\">")
            }        
            if curParaId != line.GetParagraphID(){
                if curParaId != -1{
                    fmt.Println("</Para>")
				}
                curParaId= line.GetParagraphID()
                fmt.Println("<Para id=\"" +strconv.Itoa(curParaId)+ "\">")
            }    
            bbox = line.GetBBox()
            lineStyle := line.GetStyle()
            os.Stdout.Write([]byte(fmt.Sprintf("<Line box=\"%.2f, %.2f, %.2f, %.2f\"", bbox.GetX1(), bbox.GetY1(), bbox.GetX2(), bbox.GetY2())))
            PrintStyle (lineStyle)
            os.Stdout.Write([]byte(" cur_num=\"" + strconv.Itoa(line.GetCurrentNum()) + "\"" + ">\n"))
            
            // For each word in the line...
            word = line.GetFirstWord()
            for word.IsValid(){
                // Output the bounding box for the word
                bbox = word.GetBBox()
				os.Stdout.Write([]byte(fmt.Sprintf("<Word box=\"%.2f, %.2f, %.2f, %.2f\"", bbox.GetX1(), bbox.GetY1(), bbox.GetX2(), bbox.GetY2())))
                os.Stdout.Write([]byte(" cur_num=\"" + strconv.Itoa(word.GetCurrentNum()) + "\""));
                sz := word.GetStringLen()
                if sz == 0{
                    word = word.GetNextWord()				
                    continue
				}
                // If the word style is different from the parent style, output the new style.
                s := word.GetStyle()
                if !s.IsEqual(lineStyle){
                    PrintStyle (s)
				}
                wordString := word.GetString()
                os.Stdout.Write([]byte(">" + wordString + "</Word>\n"))
                word = word.GetNextWord()
			}
            os.Stdout.Write([]byte("</Line>\n"))               
            line = line.GetNextLine()
        }    
        if curFlowId != -1{
            if curParaId != -1{
                curParaId = -1
                os.Stdout.Write([]byte("</Para>\n"))
			}
            os.Stdout.Write([]byte("</Flow>\n"))
        }
        txt.Destroy()
        doc.Close()            
        fmt.Println("</PDFText>")
    }
    // Sample code showing how to use low-level text extraction APIs.
    if example5LowLevel{
        doc = NewPDFDoc(inputPath)
        doc.InitSecurityHandler()

        // Example 1. Extract all text content from the document
        
        reader := NewElementReader()
        itr := doc.GetPageIterator()
        for itr.HasNext(){
            reader.Begin(itr.Current())
            DumpAllText(reader)
            reader.End()
            itr.Next()
        }
		
        // Example 2. Extract text content based on the 
        // selection rectangle.
        
        fmt.Println("----------------------------------------------------")
        fmt.Println("Extract text based on the selection rectangle.")
        fmt.Println("----------------------------------------------------")
        
        itr = doc.GetPageIterator()
        firstPage := itr.Current()
        s1 := ReadTextFromRect(firstPage, NewRect(27.0, 392.0, 563.0, 534.0), reader)
        fmt.Println("Field 1: " + s1)

        s1 = ReadTextFromRect(firstPage, NewRect(28.0, 551.0, 106.0, 623.0), reader);
        fmt.Println("Field 2: " + s1)

        s1 = ReadTextFromRect(firstPage, NewRect(208.0, 550.0, 387.0, 621.0), reader);
        fmt.Println("Field 3: " + s1)
        
        doc.Close()
        PDFNetTerminate()
        fmt.Println("Done.")
	}
}
