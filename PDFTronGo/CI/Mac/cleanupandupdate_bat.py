import os
import re
import shutil


from pathlib import Path
home = str(Path.home())

substr1 = "RUBY"
substr2 = "PHP"
substr3 = "PYTHON"
strbatfile = ""

rootDir = home + "/wrappers_build/PDFNetWrappers/Build/PDFTronGo/pdftron/Samples"
print (rootDir)

for dirName, subdirList, fileList in os.walk(rootDir):
     if substr1 in dirName  or substr2 in dirName or substr3 in dirName :
        shutil.rmtree(dirName)
     else :       
        for fname in fileList:       
           if re.match(fname, "RunTest.bat") :
               print('Found directory: %s' % dirName)
               print('\t%s' % fname) 
               strbatfile = dirName + "/" + fname
               f = open(strbatfile,"r")
               filedata = f.read()
               f.close()
               newdata = filedata.replace("setlocal", "if not exist ..\..\\bin\pdftron.dll (\n\tcopy ..\..\..\PDFNetC\Lib\pdftron.dll ..\..\\bin\pdftron.dll >nul \n)\n\nsetlocal\n")

               f = open(strbatfile,"w")
               f.write(newdata)
               f.close()
               