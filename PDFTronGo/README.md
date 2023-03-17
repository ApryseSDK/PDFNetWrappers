<div align="center">
  <h1>PDFTron GO</h1>
  <p>
  </p>
  <h3>
    <a href="https://www.pdftron.com/documentation/go/">Website</a>
  </h3>
</div>
<hr/>

# Supported platforms: Linux , Mac, Windows <br/>

<strong>Environments and versions:</strong> <br/>
- <strong>Go 1.15 or greater</strong><br/>
- <strong>Git</strong><br/>

# Run PDFTron Go SDK in production
A commercial license key is required for use in a production environment. Please <a href="https://apryse.com/pricing">contact us to purchase a commercial license</a> if you do not have a valid license key. 

# Running PDFTron Go in your project

1. Import `github.com/pdftron/pdftron-go` into your project
   a. On **Windows**, you will have to locate the DLLs for running the project and append them to your path.
   ```
   set PATH=%GOPATH%/pkg/mod/github.com/pdftron/pdftron-go@your_version/shared_libs/win/Lib
   ```
   You may also copy these directly to your project directory.
   
2. Create a main.go in your project directory

``` go
package main

import (
    . "github.com/pdftron/pdftron-go"
)


func main() {
    PDFNetInitialize("myLicenseKey:");
    // do work
}
```

3. `go build` && run your created executable

# Running PDFTron Go samples

1. Navigate to your go path where you installed the library, and search for our repository. It may be within this path based on your version of Golang.

`$GOPATH/pkg/mod/github.com/pdftron/pdtron-go@version`

2. Navigate to the `./samples` directory and modify the `runall_go.sh` (`runall_go.bat` on Windows) and set your `LICENSE_KEY` and if using modules such as CAD, `MODULE_PATH` to the directory where your modules are stored.

3. Run the `runallgo.sh` (`runall_go.bat` on Windows). All sample tests will be run.
   a. If you wish to run a specific test, this can be done by specifying the test `./runall_go.sh AddImageTest`
   
   Output files will be created in `TestFiles/Output``

# Running a specific version of PDFTron Go

This can be done by modifying your go.mod via this command in your project directory.

```
go mod edit -require github.com/pdftron/pdftron-go@v0.0.2`
go mod tidy (or go get github.com/pdftron/pdftron-go)
```

# Project Structure

The project is structured into the following

```
root - this repository
    source code placed in root - this contains each of the system specific source files
    shared_libs - this contains the Apryse SDK library files to run the go library
        win
            Lib
            Resources
        mac
            Lib
            Resources
        mac_arm
            Lib
            Resources
        linux
            Lib
            Resources
```

