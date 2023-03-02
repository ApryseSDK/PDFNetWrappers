//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "fmt"
    "testing"
    "strconv"
    "flag"
    "os"
    "math"
    . "github.com/pdftron/pdftron-go"
)

var licenseKey string
var modulePath string

func init() {
    flag.StringVar(&licenseKey, "license", "", "License key for Apryse SDK")
    flag.StringVar(&modulePath, "modulePath", "", "Module path for Apryse SDK")
}

// Relative path to the folder containing the test files.
var inputPath = "../TestFiles/"
var outputPath = "../TestFiles/Output/"

//---------------------------------------------------------------------------------------
// This sample illustrates basic PDFNet capabilities related to interactive 
// forms (also known as AcroForms). 
//---------------------------------------------------------------------------------------

// fieldNums has to be greater than 0.
func RenameAllFields(doc PDFDoc, name string, fieldNums int){
    itr := doc.GetFieldIterator(name)
    counter := 1
    for itr.HasNext(){
        f := itr.Current()
        radioCounter := (int)(math.Ceil(float64(counter/fieldNums)))
        f.Rename(name + "-" + strconv.Itoa(radioCounter))
        itr = doc.GetFieldIterator(name)
        counter = counter + 1
	}
}
func CreateCustomButtonAppearance(doc PDFDoc, buttonDown bool) Obj {
    // Create a button appearance stream ------------------------------------
    build := NewElementBuilder()
    writer := NewElementWriter()
    writer.Begin(doc.GetSDFDoc())
    
    // Draw background
    element := build.CreateRect(0.0, 0.0, 101.0, 37.0)
    element.SetPathFill(true)
    element.SetPathStroke(false)
    element.GetGState().SetFillColorSpace(ColorSpaceCreateDeviceGray())
    element.GetGState().SetFillColor(NewColorPt(0.75, 0.0, 0.0))
    writer.WriteElement(element)
    
    // Draw 'Submit' text
    writer.WriteElement(build.CreateTextBegin())
    text := "Submit"
    element = build.CreateTextRun(text, FontCreate(doc.GetSDFDoc(), FontE_helvetica_bold), 12.0)
    element.GetGState().SetFillColor(NewColorPt(0.0, 0.0, 0.0))
    
    if buttonDown{
        element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 33.0, 10.0)
	}else{
        element.SetTextMatrix(1.0, 0.0, 0.0, 1.0, 30.0, 13.0)
	}
    writer.WriteElement(element)
    
    writer.WritePlacedElement(build.CreateTextEnd())
    
    stm := writer.End()
    
    // Set the bounding box
    stm.PutRect("BBox", 0.0, 0.0, 101.0, 37.0)
    stm.PutName("Subtype","Form")
    return stm
}    
func TestInteractiveForms(t *testing.T){
    PDFNetInitialize(licenseKey)
    
    // The map (vector) used to store the name and count of all fields.
    // This is used later on to clone the fields
	fieldNames:= make(map[string]int)
    //----------------------------------------------------------------------------------
    // Example 1: Programatically create new Form Fields and Widget Annotations.
    //----------------------------------------------------------------------------------
    
    doc := NewPDFDoc()

    // Create a blank new page and Add some form fields.
    blankPage := doc.PageCreate()

    // Text Widget Creation 
    // Create an empty text widget with black text.
    text1 := TextWidgetCreate(doc, NewRect(110.0, 700.0, 380.0, 730.0))
    text1.SetText("Basic Text Field")
    text1.RefreshAppearance()
    blankPage.AnnotPushBack(text1)
    // Create a vertical text widget with blue text and a yellow background.
    text2 := TextWidgetCreate(doc, NewRect(50.0, 400.0, 90.0, 730.0))
    text2.SetRotation(90)
    // Set the text content.
    text2.SetText("    ****Lucky Stars!****");
    // Set the font type, text color, font size, border color and background color.
    text2.SetFont(FontCreate(doc.GetSDFDoc(), FontE_helvetica_oblique))
    text2.SetFontSize(28)
    text2.SetTextColor(NewColorPt(0.0, 0.0, 1.0), 3)
    text2.SetBorderColor(NewColorPt(0.0, 0.0, 0.0), 3)
    text2.SetBackgroundColor(NewColorPt(1.0, 1.0, 0.0), 3)
    text2.RefreshAppearance()
    // Add the annotation to the page.
    blankPage.AnnotPushBack(text2)
    // Create two new text widget with Field names employee.name.first and employee.name.last
    // This logic shows how these widgets can be created using either a field name string or
    // a Field object
    text3 := TextWidgetCreate(doc, NewRect(110.0, 660.0, 380.0, 690.0), "employee.name.first")
    text3.SetText("Levi")
    text3.SetFont(FontCreate(doc.GetSDFDoc(), FontE_times_bold))
    text3.RefreshAppearance()
    blankPage.AnnotPushBack(text3)
    empLastName := doc.FieldCreate("employee.name.last", FieldE_text, "Ackerman")
    text4 := TextWidgetCreate(doc, NewRect(110.0, 620.0, 380.0, 650.0), empLastName)
    text4.SetFont(FontCreate(doc.GetSDFDoc(), FontE_times_bold))
    text4.RefreshAppearance()
    blankPage.AnnotPushBack(text4)

    // Signature Widget Creation (unsigned)
    signature1 := SignatureWidgetCreate(doc, NewRect(110.0, 560.0, 260.0, 610.0))
    signature1.RefreshAppearance()
    blankPage.AnnotPushBack(signature1)

    // CheckBox Widget Creation
    // Create a check box widget that is not checked.
    check1 := CheckBoxWidgetCreate(doc, NewRect(140.0, 490.0, 170.0, 520.0))
    check1.RefreshAppearance()
    blankPage.AnnotPushBack(check1)
    // Create a check box widget that is checked.
    check2 := CheckBoxWidgetCreate(doc, NewRect(190.0, 490.0, 250.0, 540.0), "employee.name.check1")
    check2.SetBackgroundColor(NewColorPt(1.0, 1.0, 1.0), 3)
    check2.SetBorderColor(NewColorPt(0.0, 0.0, 0.0), 3)
    // Check the widget (by default it is unchecked).
    check2.SetChecked(true)
    check2.RefreshAppearance()
    blankPage.AnnotPushBack(check2)

    // PushButton Widget Creation
    pushbutton1 := PushButtonWidgetCreate(doc, NewRect(380.0, 490.0, 520.0, 540.0))
    pushbutton1.SetTextColor(NewColorPt(1.0, 1.0, 1.0), 3)
    pushbutton1.SetFontSize(36)
    pushbutton1.SetBackgroundColor(NewColorPt(0.0, 0.0, 0.0), 3)
    // Add a caption for the pushbutton.
    pushbutton1.SetStaticCaptionText("PushButton")
    pushbutton1.RefreshAppearance()
    blankPage.AnnotPushBack(pushbutton1)

    // ComboBox Widget Creation
    combo1 := ComboBoxWidgetCreate(doc, NewRect(280.0, 560.0, 580.0, 610.0));
    // Add options to the combobox widget.
    combo1.AddOption("Combo Box No.1")
    combo1.AddOption("Combo Box No.2")
    combo1.AddOption("Combo Box No.3")
    // Make one of the options in the combo box selected by default.
    combo1.SetSelectedOption("Combo Box No.2")
    combo1.SetTextColor(NewColorPt(1.0, 0.0, 0.0), 3)
    combo1.SetFontSize(28)
    combo1.RefreshAppearance()
    blankPage.AnnotPushBack(combo1)

    // ListBox Widget Creation
    list1 := ListBoxWidgetCreate(doc, NewRect(400.0, 620.0, 580.0, 730.0))
    // Add one option to the listbox widget.
    list1.AddOption("List Box No.1")
    // Add multiple options to the listbox widget in a batch.
    listOptions := NewVectorString()
	listOptions.Add("List Box No.2")
	listOptions.Add("List Box No.3")
    list1.AddOptions(listOptions)
    // Select some of the options in list box as default options
    list1.SetSelectedOptions(listOptions)
    // Enable list box to have multi-select when editing. 
    list1.GetField().SetFlag(FieldE_multiselect, true)
    list1.SetFont(FontCreate(doc.GetSDFDoc(),FontE_times_italic))
    list1.SetTextColor(NewColorPt(1.0, 0.0, 0.0), 3)
    list1.SetFontSize(28)
    list1.SetBackgroundColor(NewColorPt(1.0, 1.0, 1.0), 3)
    list1.RefreshAppearance()
    blankPage.AnnotPushBack(list1)

    // RadioButton Widget Creation
    // Create a radio button group and Add three radio buttons in it. 
    radioGroup := RadioButtonGroupCreate(doc, "RadioGroup")
    radiobutton1 := radioGroup.Add(NewRect(140.0, 410.0, 190.0, 460.0))
    radiobutton1.SetBackgroundColor(NewColorPt(1.0, 1.0, 0.0), 3)
    radiobutton1.RefreshAppearance()
    radiobutton2 := radioGroup.Add(NewRect(310.0, 410.0, 360.0, 460.0))
    radiobutton2.SetBackgroundColor(NewColorPt(0.0, 1.0, 0.0), 3)
    radiobutton2.RefreshAppearance()
    radiobutton3 := radioGroup.Add(NewRect(480.0, 410.0, 530.0, 460.0))
    // Enable the third radio button. By default the first one is selected
    radiobutton3.EnableButton()
    radiobutton3.SetBackgroundColor(NewColorPt(0.0, 1.0, 1.0), 3)
    radiobutton3.RefreshAppearance()
    radioGroup.AddGroupButtonsToPage(blankPage)

    // Custom push button annotation creation
    customPushbutton1 := PushButtonWidgetCreate(doc, NewRect(260.0, 320.0, 360.0, 360.0))
    // Set the annotation appearance.
    customPushbutton1.SetAppearance(CreateCustomButtonAppearance(doc, false), AnnotE_normal)
    // Create 'SubmitForm' action. The action will be linked to the button.
    url := FileSpecCreateURL(doc.GetSDFDoc(), "http://www.pdftron.com")
    buttonAction := ActionCreateSubmitForm(url)
    // Associate the above action with 'Down' event in annotations action dictionary.
    annotAction := customPushbutton1.GetSDFObj().PutDict("AA")
    annotAction.Put("D", buttonAction.GetSDFObj())
    blankPage.AnnotPushBack(customPushbutton1)

	// Add the page as the last page in the document.
    doc.PagePushBack(blankPage)                     
                                     
    // If you are not satisfied with the look of default auto-generated appearance 
    // streams you can delete "AP" entry from the Widget annotation and set 
    // "NeedAppearances" flag in AcroForm dictionary:
    //    doc.GetAcroForm().PutBool("NeedAppearances", true);
    // This will force the viewer application to auto-generate new appearance streams 
    // every time the document is opened.
    //
    // Alternatively you can generate custom annotation appearance using ElementWriter 
    // and then set the "AP" entry in the widget dictionary to the new appearance
    // stream.
    //
    // Yet another option is to pre-populate field entries with dummy text. When 
    // you edit the field values using PDFNet the new field appearances will match 
    // the old ones.

    //doc.GetAcroForm().PutBool("NeedAppearances", true)
    doc.RefreshFieldAppearances()
    
    doc.Save(outputPath + "forms_test1.pdf", uint(0))
    doc.Close()
    fmt.Println("Done.")
    
    //----------------------------------------------------------------------------------
    // Example 2: 
    // Fill-in forms / Modify values of existing fields.
    // Traverse all form fields in the document (and sys.stdout.write(out their names). 
    // Search for specific fields in the document.
    //----------------------------------------------------------------------------------
    
    doc = NewPDFDoc(outputPath + "forms_test1.pdf")
    doc.InitSecurityHandler()
    
    itr := doc.GetFieldIterator()
    for itr.HasNext(){
        curFieldName := itr.Current().GetName()
        // Add one to the count for this field name for later processing
		if val, found := fieldNames[curFieldName]; found{
			fieldNames[curFieldName] = val + 1
		}else{
			fieldNames[curFieldName] = 1
		}

        fmt.Println("Field name: " + itr.Current().GetName())
        fmt.Println("Field partial name: " + itr.Current().GetPartialName())
        os.Stdout.Write([]byte("Field type: "))
        fieldType := itr.Current().GetType()
        strVal := itr.Current().GetValueAsString()
        if (fieldType == FieldE_button){
            os.Stdout.Write([]byte("Button\n"))
		}else if (fieldType == FieldE_radio){
            os.Stdout.Write([]byte("Radio button: Value = " + strVal + "\n"))
		}else if (fieldType == FieldE_check){
            itr.Current().SetValue(true)
            os.Stdout.Write([]byte("Check box: Value = " + strVal + "\n"))
		}else if (fieldType == FieldE_text){
            os.Stdout.Write([]byte("Text" + "\n"))
            // Edit all variable text in the document
            if itr.Current().GetValue().GetMp_obj().Swigcptr() != 0 {
                old_value := itr.Current().GetValueAsString();
                itr.Current().SetValue("This is a new value. The old one was: " + old_value)
			}
		}else if (fieldType == FieldE_choice){
            os.Stdout.Write([]byte("Choice" + "\n"))
		}else if (fieldType == FieldE_signature){
            os.Stdout.Write([]byte("Signature" + "\n"))
		}
        fmt.Println("------------------------------")
        itr.Next()
	}
    // Search for a specific field
    f := doc.GetField("employee.name.first")
    if f.GetMp_field().Swigcptr() != 0{
        fmt.Println("Field search for " + f.GetName() + " was successful")
	}else{
        fmt.Println("Field search failed")
    }
	
    // Regenerate field appearances.
    doc.RefreshFieldAppearances()
    doc.Save(outputPath + "forms_test_edit.pdf", uint(0))
    doc.Close()
    fmt.Println("Done.")
    
    //----------------------------------------------------------------------------------
    // Sample: Form templating
    // Replicate pages and form data within a document. Then rename field names to make 
    // them unique.
    //----------------------------------------------------------------------------------
    
    // Sample: Copying the page with forms within the same document
    doc = NewPDFDoc(outputPath + "forms_test1.pdf")
    doc.InitSecurityHandler()
    
    srcPage := doc.GetPage(1)
    doc.PagePushBack(srcPage) // Append several copies of the first page
    doc.PagePushBack(srcPage) // Note that forms are successfully copied
    doc.PagePushBack(srcPage)
    doc.PagePushBack(srcPage)
    
    // Now we rename fields in order to make every field unique.
    // You can use this technique for dynamic template filling where you have a 'master'
    // form page that should be replicated, but with unique field names on every page.
    for key, curField := range fieldNames{
        RenameAllFields(doc, key, curField)
    }

    doc.Save(outputPath + "forms_test1_cloned.pdf", uint(0))
    doc.Close()
    fmt.Println("Done.")
    
    //----------------------------------------------------------------------------------
    // Sample: 
    // Flatten all form fields in a document.
    // Note that this sample is intended to show that it is possible to flatten
    // individual fields. PDFNet provides a utility function PDFDoc.FlattenAnnotations()
    // that will automatically flatten all fields.
    //----------------------------------------------------------------------------------
    doc = NewPDFDoc(outputPath + "forms_test1.pdf")
    doc.InitSecurityHandler()
     
    // Traverse all pages
    if false{
        doc.FlattenAnnotations()
	}else{ // Manual flattening
		for pitr := doc.GetPageIterator(); pitr.HasNext(); pitr.Next(){
			page := pitr.Current()
			for i := int(page.GetNumAnnots()) - 1; i >= 0; i-- {
				annot := page.GetAnnot(uint(i))
				if (annot.GetType() == AnnotE_Widget){
                    annot.Flatten(page)
				}
 			}
		}
	}
    doc.Save(outputPath + "forms_test1_flattened.pdf", uint(0))
    doc.Close()
    PDFNetTerminate()
    fmt.Println("Done.")
}
