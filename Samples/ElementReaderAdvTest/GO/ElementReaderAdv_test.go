//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2024 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
	"fmt"
    "testing"
    "os"
    "strconv"
    "flag"
    . "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func ProcessPath(reader ElementReader, path Element){
    if path.IsClippingPath(){
        fmt.Println("This is a clipping path")
    }

    pathData := path.GetPathData()
    data := pathData.GetPoints()
    opr := pathData.GetOperators()

    oprIndex := 0
    oprEnd := int(opr.Size())
    dataIndex := 0
    //dataEnd := data.Size()
    
    // Use path.GetCTM() if you are interested in CTM (current transformation matrix).
    
    os.Stdout.Write([]byte("Path Data Points := \""))
    x1, x2, x3, x4 := 0.0, 0.0, 0.0, 0.0
    y1, y2, y3, y4 := 0.0, 0.0, 0.0, 0.0
    for oprIndex < oprEnd{
        if int(opr.Get(oprIndex)) == int(PathDataE_moveto){
            x1 = data.Get(dataIndex) 
            dataIndex = dataIndex + 1
            y1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            os.Stdout.Write([]byte("M" + fmt.Sprintf("%f", x1) + " " + fmt.Sprintf("%f", y1)))
        }else if int(opr.Get(oprIndex)) == int(PathDataE_lineto){
            x1 = data.Get(dataIndex) 
            dataIndex = dataIndex + 1
            y1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            os.Stdout.Write([]byte(" L" + fmt.Sprintf("%f", x1) + " " + fmt.Sprintf("%f", y1)))
        }else if int(opr.Get(oprIndex)) == int(PathDataE_cubicto){
            x1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            y1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            x2 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            y2 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            x3 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            y3 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            os.Stdout.Write([]byte(" C" + fmt.Sprintf("%f", x1) + " " + fmt.Sprintf("%f", y1) + " " + fmt.Sprintf("%f", x2) + " " + fmt.Sprintf("%f", y2) + " " + fmt.Sprintf("%f", x3) + " " + fmt.Sprintf("%f", y3)))
        }else if int(opr.Get(oprIndex)) == int(PathDataE_rect){
            x1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            y1 = data.Get(dataIndex)
            dataIndex = dataIndex + 1
            w := data.Get(dataIndex)
            dataIndex = dataIndex + 1
            h := data.Get(dataIndex)
            dataIndex = dataIndex + 1
            x2 = x1 + w
            y2 = y1
            x3 = x2
            y3 = y1 + h
            x4 = x1
            y4 = y3
            os.Stdout.Write([]byte("M" + fmt.Sprintf("%.2f", x1) + " " + fmt.Sprintf("%.2f", y1) + " L" + fmt.Sprintf("%.2f", x2) + " " + fmt.Sprintf("%.2f", y2) + " L" + fmt.Sprintf("%.2f", x3) + " " + fmt.Sprintf("%.2f", y3) + " L" + fmt.Sprintf("%.2f", x4) + " " + fmt.Sprintf("%.2f", y4) + " Z"))
        }else if int(opr.Get(oprIndex)) == int(PathDataE_closepath){
            fmt.Println(" Close Path")
        }else{
            //
        }
        oprIndex = oprIndex + 1
    }

    os.Stdout.Write([]byte("\" "))
    gs := path.GetGState()
    
    // Set Path State 0 (stroke, fill, fill-rule) -----------------------------------
    if path.IsStroked(){
        fmt.Println("Stroke path")
        
        if (gs.GetStrokeColorSpace().GetType() == ColorSpaceE_pattern){
            fmt.Println("Path has associated pattern")
        }else{
            // Get stroke color (you can use PDFNet color conversion facilities)
            // rgb = gs.GetStrokeColorSpace().Convert2RGB(gs.GetStrokeColor())
        }
    }else{
        // Do not stroke path
    }

    if path.IsFilled(){
        fmt.Println("Fill path")
        
        if (gs.GetFillColorSpace().GetType() == ColorSpaceE_pattern){
            fmt.Println("Path has associated pattern")
        }else{
            // rgb = gs.GetFillColorSpace().Convert2RGB(gs.GetFillColor())
        }
    }else{
        // Do not fill path
    }

    // Process any changes in graphics state  ---------------------------------
    gsItr := reader.GetChangesIterator()
    for gsItr.HasNext(){
        if int(gsItr.Current()) == int(GStateE_transform){
            // Get transform matrix for this element. Unlike path.GetCTM() 
            // that return full transformation matrix gs.GetTransform() return 
            // only the transformation matrix that was installed for this element.
            //
            // gs.GetTransform()
            
        }else if int(gsItr.Current()) == int(GStateE_line_width){
            // gs.GetLineWidth()
            
        }else if int(gsItr.Current()) == int(GStateE_line_cap){
            // gs.GetLineCap()
            
        }else if int(gsItr.Current()) == int(GStateE_line_join){
            // gs.GetLineJoin()
            
        }else if int(gsItr.Current()) == int(GStateE_flatness){
            
        }else if int(gsItr.Current()) == int(GStateE_miter_limit){
            // gs.GetMiterLimit()
            
        }else if int(gsItr.Current()) == int(GStateE_dash_pattern){
            // dashes = gs.GetDashes()
            // gs.GetPhase()
            
        }else if int(gsItr.Current()) == int(GStateE_fill_color){
            if (int(gs.GetFillColorSpace().GetType()) == int(ColorSpaceE_pattern) && int(gs.GetFillPattern().GetType()) != int(PatternColorE_shading) ){
                // process the pattern data
                reader.PatternBegin(true)
                ProcessElements(reader)
                reader.End()
            }
        }
        gsItr.Next()
    }
    reader.ClearChangeList()
}

func ProcessText (pageReader ElementReader){
    // Begin text element
    fmt.Println("Begin Text Block:")
    
    element := pageReader.Next()
    
    for element.GetMp_elem().Swigcptr() != 0{
        etype := element.GetType()
        if etype == ElementE_text_end{
            // Finish the text block
            fmt.Println("End Text Block.")
            return
        }else if etype == ElementE_text{
            gs := element.GetGState()
            
            //csFill := gs.GetFillColorSpace()
            //fill := gs.GetFillColor()
            
            //out := csFill.Convert2RGB(fill)
            
            //csStroke := gs.GetStrokeColorSpace()
            //stroke := gs.GetStrokeColor()
            
            font := gs.GetFont()
            fmt.Println("Font Name: " + font.GetName())
            // font.IsFixedWidth()
            // font.IsSerif()
            // font.IsSymbolic()
            // font.IsItalic()
            // ... 

            // fontSize = gs.GetFontSize()
            // wordSpacing = gs.GetWordSpacing()
            // charSpacing = gs.GetCharSpacing()
            // txt := element.GetTextString()
            if font.GetType() == FontE_Type3{
                // type 3 font, process its data
                itr := element.GetCharIterator()
                for itr.HasNext(){
                    pageReader.Type3FontBegin(itr.Current())
                    ProcessElements(pageReader)
                    pageReader.End()
                }
            }else{
                text_mtx := element.GetTextMatrix()
                
                itr := element.GetCharIterator()
                for itr.HasNext(){
                    charCode := itr.Current().GetChar_data()
                    if *charCode >= 32 && *charCode <= 255 {     // Print if in ASCII range...
                        a := font.MapToUnicode(uint(*charCode))
                        os.Stdout.Write([]byte( a )) // Revisit: if sys.version_info.major < 3 else ascii(a[0]) ))
                    }    
                    pt := NewPoint()   
                    pt.SetX(itr.Current().GetX())     // character positioning information
                    pt.SetY(itr.Current().GetY())
                    
                    // Use element.GetCTM() if you are interested in the CTM 
                    // (current transformation matrix).
                    ctm := element.GetCTM()
                    
                    // To get the exact character positioning information you need to 
                    // concatenate current text matrix with CTM and then multiply 
                    // relative positioning coordinates with the resulting matrix.
                    mtx := ctm.Multiply(text_mtx)
                    mtx.Mult(pt)
                    itr.Next()
                }
            }
            fmt.Println("")
        }
        element = pageReader.Next()
    }
}

func ProcessImage (image Element){
    //imageMask := image.IsImageMask()
    //interpolate := image.IsImageInterpolate()
    width := image.GetImageWidth()
    height := image.GetImageHeight()
    outDataSz := width * height * 3
    
    fmt.Println("Image: width=\"" + fmt.Sprintf("%d", width) + "\"" + " height=\"" + fmt.Sprintf("%d", height)+ "\"" )
    
    // Matrix2D& mtx = image->GetCTM() // image matrix (page positioning info)

    // You can use GetImageData to read the raw (decoded) image data
    //image->GetBitsPerComponent()    
    //image->GetImageData()    // get raw image data
    // .... or use Image2RGB filter that converts every image to RGB format,
    // This should save you time since you don't need to deal with color conversions, 
    // image up-sampling, decoding etc.
    
    imgConv := NewImage2RGB(image)     // Extract and convert image to RGB 8-bps format
    reader := NewFilterReader(imgConv)

    //imageDataOut := reader.Read(int64(outDataSz))
    reader.Read(int64(outDataSz))
    
    // Note that you don't need to read a whole image at a time. Alternatively
    // you can read a chuck at a time by repeatedly calling reader.Read(buf, buf_sz) 
    // until the function returns 0. 
}

func ProcessElements(reader ElementReader){
    element := reader.Next()     // Read page contents
    for element.GetMp_elem().Swigcptr() != 0{
        etype := element.GetType()
        if etype == ElementE_path{      // Process path data...
            ProcessPath(reader, element)
        }else if etype == ElementE_text_begin{      // Process text block...
            ProcessText(reader)
        }else if etype == ElementE_form{    // Process form XObjects
            reader.FormBegin()
            ProcessElements(reader)
            reader.End()
        }else if etype == ElementE_image{    // Process Images
            ProcessImage(element)
        }
        element = reader.Next()
    }
}

func TestElementReaderAdv(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    //outputPath := "../TestFiles/Output/"
    
    // Extract text data from all pages in the document
    
    fmt.Println("__________________________________________________")
    fmt.Println("Extract page element information from all ")
    fmt.Println("pages in the document.")
    
    doc := NewPDFDoc(inputPath + "newsletter.pdf")
    doc.InitSecurityHandler()
    //pgnum := doc.GetPageCount()
    pageBegin := doc.GetPageIterator()
    pageReader := NewElementReader()
    
    itr := pageBegin
    for itr.HasNext(){    // Read every page
        fmt.Println("Page " + strconv.Itoa(itr.Current().GetIndex()) + "----------------------------------------")
        pageReader.Begin(itr.Current())
        ProcessElements(pageReader)
        pageReader.End()
        itr.Next()
    }
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
