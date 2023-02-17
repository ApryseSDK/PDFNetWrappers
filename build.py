import os
import argparse
import re
import shutil
import urllib.request
import platform
import tarfile
import subprocess
from zipfile import ZipFile as zipfile
from pathlib import Path as path

def execute_replace(input, script):
   i = 0
   script_len = len(script)
   while True:
      while i < script_len:
         if script[i] == '/\n':
            i += 1
            break
         i += 1
      if i >= script_len:
         break
      before = ''
      while i < script_len:
         if script[i] == '/\n':
            i += 1
            break
         before += script[i]
         i += 1
      if i >= script_len:
         break
      after = ''
      while i < script_len:
         if script[i] == '/\n':
            i += 1
            break
         after += script[i]
         i += 1
      input = input.replace(before, after)
      if i >= script_len:
         break
   return input

def replacego(filepath):
    filepathname = os.path.join(filepath, "pdftron_wrap.cxx")
    with open(filepathname, "r") as f:
       cxx = f.read()

    filepathname = os.path.join(filepath, "pdftron_wrap.h")
    with open(filepathname, "r") as f:
       h = f.read()

    filepathname = os.path.join(filepath, "pdftron.go")
    with open(filepathname, "r") as f:
       go = f.read()

    filepathname = os.path.join(filepath, "pdftron_wrap.cxx.replace")
    with open(filepathname, "r") as f:
       cxx_replace = f.readlines()

    filepathname = os.path.join(filepath, "pdftron_wrap.h.replace")
    with open(filepathname, "r") as f:
       h_replace = f.readlines()

    filepathname = os.path.join(filepath, "pdftron.go.replace")
    with open(filepathname, "r") as f:
       go_replace = f.readlines()

    uid = re.search(r'(extern\s+\w+\s+_wrap_\w+_pdftron_)(\w+)(\()', go).group(2)

    go = execute_replace(go, go_replace)
    cxx = execute_replace(cxx, cxx_replace)
    h = execute_replace(h, h_replace)

    old_uid = '02581caacfa652f4'
    go = go.replace(old_uid, uid)
    cxx = cxx.replace(old_uid, uid)
    h = h.replace(old_uid, uid)

    filepathname = os.path.join(filepath, "pdftron_wrap.cxx")
    with open(filepathname, "w+") as f:
       f.write(cxx)

    filepathname = os.path.join(filepath, "pdftron_wrap.h")
    with open(filepathname, "w+") as f:
       f.write(h)

    filepathname = os.path.join(filepath, "pdftron.go")
    with open(filepathname, "w+") as f:
       f.write(go)

def fixSamples(rootDir):
    substr1 = "RUBY"
    substr2 = "PHP"
    substr3 = "PYTHON"
    strbatfile = ""

    rootDir = os.path.join(rootDir, "build/PDFTronGo/pdftron/Samples")
    if not os.path.isdir(rootDir):
        raise Exception("Samples dir not found.");

    for dirName, subdirList, fileList in os.walk(rootDir):
        if substr1 in dirName  or substr2 in dirName or substr3 in dirName :
            shutil.rmtree(dirName)
        else:
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

def copyPaths(prefix, srcPaths, dest):
    for path in srcPaths:
        print("Copying %s/%s to %s..." % (prefix, path, dest))
        shutil.copytree(os.path.join(prefix, path), os.path.join(dest, path), dirs_exist_ok=True)

def extractArchive(fileName):
    ext = path(fileName)
    ext = ''.join(ext.suffixes)
    if ext == ".tar.gz":
        tarfile.open(fileName).extractall();
    else:
        with zipfile(fileName, 'r') as archive:
            archive.extractall()

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-dl', '--download_link', dest='dl', default='')
    parser.add_argument('-cs', '--custom_swig', dest='custom_swig', default='')
    # skips nightly pull
    parser.add_argument('-sdl', '--skip_dl', dest='skip_dl', action='store_true')

    stored_args, ignored_args = parser.parse_known_args()

    core_download_link = stored_args.dl
    custom_swig = stored_args.custom_swig
    skip_dl = stored_args.skip_dl

    rootDir = os.getcwd()
    try:
        shutil.rmtree("build", ignore_errors=True)
    except FileNotFoundError:
        pass
    os.mkdir("build")
    # provided by repo
    os.chdir("PDFNetC")

    gccCommand = ""
    cmakeCommand = "cmake -D BUILD_PDFTronGo=ON"
    if custom_swig:
       cmakeCommand += " -D CUSTOM_SWIG=%s" % custom_swig

    cmakeCommand += ' ..'

    if platform.system().startswith('Windows'):
        print("Running Windows build...")
        if not core_download_link:
           core_download_link = 'http://www.pdftron.com/downloads/PDFNetC64.zip'
        if not skip_dl:
           print("Downloading PDFNetC64...")
           urllib.request.urlretrieve(core_download_link, "PDFNetC64.zip")
        extractArchive("PDFNetC64.zip")
        os.remove("PDFNetC64.zip")
        copyPaths('PDFNetC64', ['Headers', 'Lib'], '.')
        cmakeCommand = 'cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON ..'
        gccCommand = "g++ -shared -I../Headers -L . -lPDFNetC pdftron_wrap.cxx -o pdftron.dll"
    elif platform.system().startswith('Linux'):
        print("Running Linux build...")
        if not core_download_link:
           core_download_link = 'http://www.pdftron.com/downloads/PDFNetC64.tar.gz'
        print(core_download_link)
        if not skip_dl:
           print("Downloading PDFNetC64...")
           urllib.request.urlretrieve(core_download_link, 'PDFNetC64.tar.gz')
        extractArchive("PDFNetC64.tar.gz")
        os.remove("PDFNetC64.tar.gz")
        copyPaths('PDFNetC64', ['Headers', 'Lib'], '.')
        gccCommand = "g++ -fuse-ld=gold -fpic -I ../Headers -L . -lPDFNetC -Wl,-rpath,. -shared -static-libstdc++ pdftron_wrap.cxx -o libpdftron.so"
    else:
        print("Running Mac build...")
        if not core_download_link:
           core_download_link = 'http://www.pdftron.com/downloads/PDFNetCMac.zip'
        if not skip_dl:
           print("Downloading PDFNetC64...")
           urllib.request.urlretrieve(core_download_link, 'PDFNetCMac.zip')

        extractArchive("PDFNetCMac.zip")
        os.remove("PDFNetCMac.zip")
        copyPaths('PDFNetCMac', ['Headers', 'Lib', 'Resources'], '.')
        gccCommand = "gcc -fPIC -lstdc++ -I../Headers -L. -lPDFNetC -dynamiclib -undefined suppress -flat_namespace pdftron_wrap.cxx -o libpdftron.dylib"

    os.chdir("../build")

    print("Starting cmake: " + cmakeCommand)
    try:
        for data in execute(cmakeCommand):
           print(data, end="")
    except subprocess.CalledProcessError as e:
        print(e.stdout.decode())
        raise

    print("Moving pdftron wrap...")
    os.chdir(os.path.join("PDFTronGo", "pdftron"))
    if platform.system().startswith('Windows'):
        shutil.copy(os.path.join(rootDir, "PDFTronGo", "CI", "Windows", "pdftron.go.replace"), '.')
        shutil.copy(os.path.join(rootDir, "PDFTronGo", "CI", "Windows", "pdftron_wrap.cxx.replace"), '.')
        shutil.copy(os.path.join(rootDir, "PDFTronGo", "CI", "Windows", "pdftron_wrap.h.replace"), '.')
        replacego('.')
    shutil.move("pdftron_wrap.cxx", os.path.join("PDFNetC", "Lib"))
    shutil.move("pdftron_wrap.h", os.path.join("PDFNetC", "Lib"))
    os.chdir(os.path.join("PDFNetC", "Lib"))
    if platform.system().startswith('Windows'):
        os.remove("pdfnetc.lib")

    print("Running GCC: " + gccCommand)
    try:
        for data in execute(gccCommand):
           print(data, end="")

    except subprocess.CalledProcessError as e:
        print(e.stdout.decode())
        raise

    print("Fixing samples...")
    fixSamples(rootDir)

    print("Build completed.")
    return 0

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True, shell=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

if __name__ == '__main__':
    main()
