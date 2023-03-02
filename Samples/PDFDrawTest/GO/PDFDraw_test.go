//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package PDFDrawTest
import (
    "fmt"
    "strconv"
    "testing"
    "os"
    . "github.com/pdftron/pdftron-go"
    "flag"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

func TestPDFDraw(t *testing.T){
    // Relative path to the folder containing test files.
    var inputPath =  "../TestFiles/"
    var outputPath = "../TestFiles/Output/"

    // The first step in every application using PDFNet is to initialize the 
    // library and set the path to common PDF resources. The library is usually 
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    
    // Optional: Set ICC color profiles to fine tune color conversion 
    // for PDF 'device' color spaces...

    // PDFNetSetResourcesPath("../../../resources")
    // PDFNetSetColorManagement()
    // PDFNetSetDefaultDeviceCMYKProfile("D:/Misc/ICC/USWebCoatedSWOP.icc")
    // PDFNetSetDefaultDeviceRGBProfile("AdobeRGB1998.icc") // will search in PDFNet resource folder.

    // ----------------------------------------------------
    // Optional: Set predefined font mappings to override default font 
    // substitution for documents with missing fonts...

    // PDFNetAddFontSubst("StoneSans-Semibold", "C:/WINDOWS/Fonts/comic.ttf")
    // PDFNetAddFontSubst("StoneSans", "comic.ttf")  // search for 'comic.ttf' in PDFNet resource folder.
    // PDFNetAddFontSubst(PDFNetE_Identity, "C:/WINDOWS/Fonts/arialuni.ttf")
    // PDFNetAddFontSubst(PDFNetE_Japan1, "C:/Program Files/Adobe/Acrobat 7.0/Resource/CIDFont/KozMinProVI-Regular.otf")
    // PDFNetAddFontSubst(PDFNetE_Japan2, "c:/myfonts/KozMinProVI-Regular.otf")
    // PDFNetAddFontSubst(PDFNetE_Korea1, "AdobeMyungjoStd-Medium.otf")
    // PDFNetAddFontSubst(PDFNetE_CNS1, "AdobeSongStd-Light.otf")
    // PDFNetAddFontSubst(PDFNetE_GB1, "AdobeMingStd-Light.otf")
    
    //Example 1) Convert the first page to PNG and TIFF at 92 DPI.
    
    // PDFDraw class is used to rasterize PDF pages.
    draw := NewPDFDraw()
    
    //--------------------------------------------------------------------------------
    // Example 1) Convert the first page to PNG and TIFF at 92 DPI. 
    // A three step tutorial to convert PDF page to an image.
    
    // A) Open the PDF document.
    doc := NewPDFDoc(inputPath + "tiger.pdf")
    
    // Initialize the security handler, in case the PDF is encrypted.
    doc.InitSecurityHandler()
    
    // B) The output resolution is set to 92 DPI.
    draw.SetDPI(92)
    
    // C) Rasterize the first page in the document and save the result as PNG.
    itr := doc.GetPageIterator()
    draw.Export(itr.Current(), outputPath + "tiger_92dpi.png")
    
    fmt.Println("Example 1: tiger_92dpi.png")
    
    // Export the same page as TIFF
    itr = doc.GetPageIterator()
    draw.Export(itr.Current(), (outputPath + "tiger_92dpi.tif"), "TIFF")

    //--------------------------------------------------------------------------------
    // Example 2) Convert the all pages in a given document to JPEG at 72 DPI.

    fmt.Println("Example 2:")
    
    hintSet := NewObjSet() // A collection of rendering 'hits'.
    
    doc = NewPDFDoc(inputPath + "newsletter.pdf")
    // Initialize the security handler, in case the PDF is encrypted.
    doc.InitSecurityHandler()
    
    // Set the output resolution is to 72 DPI.
    draw.SetDPI(72)
    
    // Use optional encoder parameter to specify JPEG quality.
    encoderParam := hintSet.CreateDict()
    encoderParam.PutNumber("Quality", 80)
    
    // Traverse all pages in the document.
    itr = doc.GetPageIterator()
    for itr.HasNext(){
        filename := "newsletter" + strconv.Itoa(itr.Current().GetIndex()) + ".jpg"
        fmt.Println(filename)
        draw.Export(itr.Current(), outputPath + filename, "JPEG", encoderParam)
        itr.Next()
	}
    fmt.Println("Done.")

    // Examples 3-5
    // Common code for remaining samples.
    tigerDoc := NewPDFDoc(inputPath + "tiger.pdf")
    // Initialize the security handler, in case the PDF is encrypted.
    tigerDoc.InitSecurityHandler()
    page := tigerDoc.GetPage(1)
    
    //--------------------------------------------------------------------------------
    // Example 3) Convert the first page to raw bitmap. Also, rotate the 
    // page 90 degrees and save the result as RAW.
    draw.SetDPI(100)    // Set the output resolution is to 100 DPI.
    draw.SetRotate(PageE_90)   // Rotate all pages 90 degrees clockwise.
    bmp := draw.GetBitmap(page, PDFDrawE_rgb)
	bmpBytes := make([]byte, int(bmp.GetBuffer().Size()))
	buffVUC := bmp.GetBuffer()
	for i := 0; i < int(buffVUC.Size()); i++{
		bmpBytes[i] = buffVUC.Get(i)
	}
    // Save the raw RGB data to disk.
	f, err := os.Create(outputPath + "tiger_100dpi_rot90.raw")

    if err != nil {
        fmt.Println(err)
    }
    defer f.Close()
    _, err2 := f.Write(bmpBytes)
    if err2 != nil {
        fmt.Println(err2)
    }

    fmt.Println("Example 3: tiger_100dpi_rot90.raw")
    
    draw.SetRotate(PageE_0)    // Disable image rotation for remaining samples.
    
    //--------------------------------------------------------------------------------
    // Example 4) Convert PDF page to a fixed image size. Also illustrates some 
    // other features in PDFDraw class such as rotation, image stretching, exporting 
    // to grayscale, or monochrome.
    
    // Initialize render 'grayHint' parameter, that is used to control the 
    // rendering process. In this case we tell the rasterizer to export the image as 
    // 1 Bit Per Component (BPC) image.
    monoHint := hintSet.CreateDict()
    monoHint.PutNumber("BPC", 1)
    
    // SetImageSize can be used instead of SetDPI() to adjust page scaling
    // dynamically so that given image fits into a buffer of given dimensions.
    draw.SetImageSize(1000, 1000)   // Set the output image to be 1000 wide and 1000 pixels tall
    draw.Export(page, outputPath + "tiger_1000x1000.png", "PNG", monoHint)
    fmt.Println("Example 4: tiger_1000x1000.png")
    
    draw.SetImageSize(200, 400)     // Set the output image to be 200 wide and 400 pixels tall
    draw.SetRotate(PageE_180)      // Rotate all pages 90 degrees clockwise
    
    // 'grayHint' tells the rasterizer to export the image as grayscale.
    grayHint := hintSet.CreateDict()
    grayHint.PutName("ColorSpace", "Gray")
    
    draw.Export(page, (outputPath + "tiger_200x400_rot180.png"), "PNG", grayHint)
    fmt.Println("Example 4: tiger_200x400_rot180.png")
    
    draw.SetImageSize(400, 200, false)  // The third parameter sets 'preserve-aspect-ratio' to false
    draw.SetRotate(PageE_0)     // Disable image rotation
    draw.Export(page, outputPath + "tiger_400x200_stretch.jpg", "JPEG")
    fmt.Println("Example 4: tiger_400x200_stretch.jpg")
    
    //--------------------------------------------------------------------------------
    // Example 5) Zoom into a specific region of the page and rasterize the 
    // area at 200 DPI and as a thumbnail (i.e. a 50x50 pixel image).
    zoomRect := NewRect(216.0, 522.0, 330.0, 600.0)
    page.SetCropBox(zoomRect)    // Set the page crop box.

    // Select the crop region to be used for drawing.
    draw.SetPageBox(PageE_crop)
    draw.SetDPI(900)  // Set the output image resolution to 900 DPI.
    draw.Export(page, outputPath + "tiger_zoom_900dpi.png", "PNG")
    fmt.Println("Example 5: tiger_zoom_900dpi.png")

    // -------------------------------------------------------------------------------
    // Example 6)
    draw.SetImageSize(50, 50)      // Set the thumbnail to be 50x50 pixel image.
    draw.Export(page, outputPath + "tiger_zoom_50x50.png", "PNG")
    fmt.Println("Example 6: tiger_zoom_50x50.png")

    cmykHint := hintSet.CreateDict()
    cmykHint.PutName("ColorSpace", "CMYK")
    
    //--------------------------------------------------------------------------------
    // Example 7) Convert the first PDF page to CMYK TIFF at 92 DPI.
    // A three step tutorial to convert PDF page to an image
    // A) Open the PDF document
    doc = NewPDFDoc(inputPath + "tiger.pdf")
    // Initialize the security handler, in case the PDF is encrypted.
    doc.InitSecurityHandler()
    
    // The output resolution is set to 92 DPI.
    draw.SetDPI(92)
    
    // C) Rasterize the first page in the document and save the result as TIFF.
    pg := doc.GetPage(1)
    draw.Export(pg, outputPath + "out1.tif", "TIFF", cmykHint)
    fmt.Println("Example 7: out1.tif")
        
    doc.Close()

    // A) Open the PDF document.
    doc = NewPDFDoc(inputPath + "tiger.pdf");
    // Initialize the security handler, in case the PDF is encrypted.
    doc.InitSecurityHandler();  

    // B) Get the page matrix 
    pg = doc.GetPage(1);
    box := PageE_crop;
    mtx := pg.GetDefaultMatrix(true, box);
    // We want to render a quadrant, so use half of width and height
    pgW := pg.GetPageWidth(box) / 2;
    pgH := pg.GetPageHeight(box) / 2;

    // C) Scale matrix from PDF space to buffer space
    dpi := 96.0;
    scale := dpi / 72.0; // PDF space is 72 dpi
    bufW := int(scale * pgW);
    bufH := int(scale * pgH);
    bytesPerPixel := 4; // BGRA buffer
    bufSize := bufW * bufH * bytesPerPixel;
    mtx.Translate(0, -pgH); // translate by '-pgH' since we want south-west quadrant
    mtx = NewMatrix2D(scale, 0.0, 00.0, scale, 00.0, 00.0).Multiply(mtx);

    // D) Rasterize page into memory buffer, according to our parameters
    rast := NewPDFRasterizer();
    buf := rast.Rasterize(pg, bufW, bufH, bufW * bytesPerPixel, bytesPerPixel, true, mtx);
	if(bufSize != 0 && buf.Size() != 0){
		// buf now contains raw BGRA bitmap.
		fmt.Println("Example 8: Successfully rasterized into memory buffer.");
	}else{
		fmt.Println("Example 8: Failed to rasterize into memory buffer.");
	}

    //--------------------------------------------------------------------------------
    // Example 9) Export raster content to PNG using different image smoothing settings. 
    textDoc := NewPDFDoc(inputPath + "lorem_ipsum.pdf");
    textDoc.InitSecurityHandler();

    draw.SetImageSmoothing(false, false);
    filename := "raster_text_no_smoothing.png";
    draw.Export(textDoc.GetPageIterator().Current(), outputPath + filename);
    fmt.Println("Example 9 a): " + filename + ". Done.");

    filename = "raster_text_smoothed.png";
    draw.SetImageSmoothing(true, false); // second argument = default quality bilinear resampling
    draw.Export(textDoc.GetPageIterator().Current(), outputPath + filename);
    fmt.Println("Example 9 b): " + filename + ". Done.");

    filename = "raster_text_high_quality.png";
    draw.SetImageSmoothing(true, true); // second argument = default quality bilinear resampling
    draw.Export(textDoc.GetPageIterator().Current(), outputPath + filename);
    fmt.Println("Example 9 c): " + filename + ". Done.");

    //--------------------------------------------------------------------------------
    // Example 10) Export separations directly, without conversion to an output colorspace

    separationDoc := NewPDFDoc(inputPath + "op_blend_test.pdf");
    separationDoc.InitSecurityHandler();
    separationHint := hintSet.CreateDict();
    separationHint.PutName("ColorSpace", "Separation");
    draw.SetDPI(96);
    draw.SetImageSmoothing(true, true);
    draw.SetOverprint(PDFRasterizerE_op_on);

    filename = "merged_separations.png";
    draw.Export(separationDoc.GetPageIterator().Current(), outputPath + filename, "PNG");
    fmt.Println("Example 10 a): " + filename + ". Done.");

    filename = "separation";
    draw.Export(separationDoc.GetPageIterator().Current(), outputPath + filename, "PNG", separationHint);
    fmt.Println("Example 10 b): " + filename + "_[ink].png. Done.");

    filename = "separation_NChannel.tif";
    draw.Export(separationDoc.GetPageIterator().Current(), outputPath + filename, "TIFF", separationHint);
    fmt.Println("Example 10 c): " + filename + ". Done.");
    PDFNetTerminate()
}
