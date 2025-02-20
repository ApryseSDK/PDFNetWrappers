//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "testing"
    "flag"
	. "github.com/pdftron/pdftron-go/v2"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

//---------------------------------------------------------------------------------------
// The following sample illustrates how to reduce PDF file size using 'pdftron.PDF.Optimizer'.
// The sample also shows how to simplify and optimize PDF documents for viewing on mobile devices 
// and on the Web using 'pdftron.PDF.Flattener'.
//
// @note Both 'Optimizer' and 'Flattener' are separately licensable add-on options to the core PDFNet license.
//
// ----
//
// 'pdftron.PDF.Optimizer' can be used to optimize PDF documents by reducing the file size, removing 
// redundant information, and compressing data streams using the latest in image compression technology. 
//
// PDF Optimizer can compress and shrink PDF file size with the following operations:
// - Remove duplicated fonts, images, ICC profiles, and any other data stream. 
// - Optionally convert high-quality or print-ready PDF files to small, efficient and web-ready PDF. 
// - Optionally down-sample large images to a given resolution. 
// - Optionally compress or recompress PDF images using JBIG2 and JPEG2000 compression formats. 
// - Compress uncompressed streams and remove unused PDF objects.
// ----
//
// 'pdftron.PDF.Flattener' can be used to speed-up PDF rendering on mobile devices and on the Web by 
// simplifying page content (e.g. flattening complex graphics into images) while maintaining vector text 
// whenever possible.
//
// Flattener can also be used to simplify process of writing custom converters from PDF to other formats. 
// In this case, Flattener can be used as first step in the conversion pipeline to reduce any PDF to a 
// very simple representation (e.g. vector text on top of a background image). 
//---------------------------------------------------------------------------------------

func TestOptimizer(t *testing.T){
    // Relative path to the folder containing the test files.
    inputPath := "../TestFiles/"
    outputPath := "../TestFiles/Output/"
    inputFileName := "newsletter"
    
    // The first step in every application using PDFNet is to initialize the 
    // library and set the path to common PDF resources. The library is usually 
    // initialized only once, but calling Initialize() multiple times is also fine.
    PDFNetInitialize(licenseKey)
    
    //--------------------------------------------------------------------------------
    // Example 1) Simple optimization of a pdf with default settings.
    
    doc := NewPDFDoc(inputPath + inputFileName + ".pdf")
    doc.InitSecurityHandler()
    OptimizerOptimize(doc)
    
    doc.Save(outputPath + inputFileName + "_opt1.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 2) Reduce image quality and use jpeg compression for
    // non monochrome images.    
    doc = NewPDFDoc(inputPath + inputFileName + ".pdf")
    doc.InitSecurityHandler()
    imageSettings := NewImageSettings()
    
    // low quality jpeg compression
    imageSettings.SetCompressionMode(ImageSettingsE_jpeg)
    imageSettings.SetQuality(1)
    
    // Set the output dpi to be standard screen resolution
    imageSettings.SetImageDPI(144,96)
    
    // this option will recompress images not compressed with
    // jpeg compression and use the result if the new image
    // is smaller.
    imageSettings.ForceRecompression(true)
    
    // this option is not commonly used since it can 
    // potentially lead to larger files.  It should be enabled
    // only if the output compression specified should be applied
    // to every image of a given type regardless of the output image size
    //imageSettings.ForceChanges(true)

    optSettings := NewOptimizerSettings()
    optSettings.SetColorImageSettings(imageSettings)
    optSettings.SetGrayscaleImageSettings(imageSettings)

    // use the same settings for both color and grayscale images
    OptimizerOptimize(doc, optSettings)
    
    doc.Save(outputPath + inputFileName + "_opt2.pdf", uint(SDFDocE_linearized))
    doc.Close()
    
    //--------------------------------------------------------------------------------
    // Example 3) Use monochrome image settings and default settings
    // for color and grayscale images. 
    
    doc = NewPDFDoc(inputPath + inputFileName + ".pdf")
    doc.InitSecurityHandler()

    monoImageSettings := NewMonoImageSettings()
    
    monoImageSettings.SetCompressionMode(MonoImageSettingsE_jbig2)
    monoImageSettings.ForceRecompression(true)

    optSettings = NewOptimizerSettings()
    optSettings.SetMonoImageSettings(monoImageSettings)
    
    OptimizerOptimize(doc, optSettings)
    doc.Save(outputPath + inputFileName + "_opt3.pdf", uint(SDFDocE_linearized))
    doc.Close()
	
    // ----------------------------------------------------------------------
    // Example 4) Use Flattener to simplify content in this document
    // using default settings
    
    doc = NewPDFDoc(inputPath + "TigerText.pdf")
    doc.InitSecurityHandler()
    
    fl := NewFlattener()
    // The following lines can increase the resolution of background
    // images.
    //fl.SetDPI(300)
    //fl.SetMaximumImagePixels(5000000)

    // This line can be used to output Flate compressed background
    // images rather than DCTDecode compressed images which is the default
    //fl.SetPreferJPG(false)

    // In order to adjust thresholds for when text is Flattened
    // the following function can be used.
    //fl.SetThreshold(FlattenerE_threshold_keep_most)

    // We use e_fast option here since it is usually preferable
    // to avoid Flattening simple pages in terms of size and 
    // rendering speed. If the desire is to simplify the 
    // document for processing such that it contains only text and
    // a background image e_simple should be used instead.
    fl.Process(doc, FlattenerE_fast)
    doc.Save(outputPath + "TigerText_flatten.pdf", uint(SDFDocE_linearized))
    doc.Close()

    // ----------------------------------------------------------------------
    // Example 5) Optimize a PDF for viewing using SaveViewerOptimized.
    
    doc = NewPDFDoc(inputPath + inputFileName + ".pdf")
    doc.InitSecurityHandler()
    
    opts := NewViewerOptimizedOptions()

    // set the maximum dimension (width or height) that thumbnails will have.
    opts.SetThumbnailSize(1500)

    // set thumbnail rendering threshold. A number from 0 (include all thumbnails) to 100 (include only the first thumbnail) 
    // representing the complexity at which SaveViewerOptimized would include the thumbnail. 
    // By default it only produces thumbnails on the first and complex pages. 
    // The following line will produce thumbnails on every page.
    // opts.SetThumbnailRenderingThreshold(0) 

    doc.SaveViewerOptimized(outputPath + inputFileName + "_SaveViewerOptimized.pdf", opts)
    doc.Close()
    PDFNetTerminate()
}
