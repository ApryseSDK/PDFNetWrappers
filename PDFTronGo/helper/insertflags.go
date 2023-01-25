//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------

package main
import (
    "os"
    "bytes"
    "io/ioutil"
)

func main(){
    if(len(os.Args) < 4){
        panic("The number of args is wrong!")
    }
    replacedString := "#define intgo swig_intgo"
    newString := os.Args[3] + "\n" + os.Args[4] + "\n" + replacedString
    content, err := ioutil.ReadFile(os.Args[2])
    if err != nil {
        panic(err)
    }

    lines := bytes.Replace(content, []byte(replacedString), []byte(newString), 1)
    err = ioutil.WriteFile(os.Args[2], lines, 0644)
    if err != nil {
        panic(err)
    }    
}
