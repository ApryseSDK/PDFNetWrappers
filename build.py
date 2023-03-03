import os
import argparse
import re
import shutil
import platform
import tarfile
import subprocess
import shlex
from zipfile import ZipFile as zipfile
from pathlib import Path as path

rootDir = os.getcwd()
if not os.path.exists("PDFTronGo"):
    raise ValueError("PDFTronGo cannot be found, run this script from the root of the repo.")

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

def replacego(replace_path, dest_path):
    print("replacing %s with data from %s" % (dest_path, replace_path))
    filepathname = os.path.join(dest_path, "pdftron_wrap.cxx")
    with open(filepathname, "r") as f:
        cxx = f.read()

    filepathname = os.path.join(dest_path, "pdftron_wrap.h")
    with open(filepathname, "r") as f:
        h = f.read()

    filepathname = os.path.join(dest_path, "pdftron.go")
    with open(filepathname, "r") as f:
        go = f.read()

    filepathname = os.path.join(replace_path, "pdftron_wrap.cxx.replace")
    with open(filepathname, "r") as f:
        cxx_replace = f.readlines()

    filepathname = os.path.join(replace_path, "pdftron_wrap.h.replace")
    with open(filepathname, "r") as f:
        h_replace = f.readlines()

    filepathname = os.path.join(replace_path, "pdftron.go.replace")
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

    filepathname = os.path.join(dest_path, "pdftron_wrap.cxx")
    with open(filepathname, "w+") as f:
        f.write(cxx)

    filepathname = os.path.join(dest_path, "pdftron_wrap.h")
    with open(filepathname, "w+") as f:
        f.write(h)

    filepathname = os.path.join(dest_path, "pdftron.go")
    with open(filepathname, "w+") as f:
        f.write(go)

def fixSamples():
    samples_path = os.path.join(rootDir, "Samples")
    dest_path = os.path.join(rootDir, "build/PDFTronGo/pdftron/samples")
    if not os.path.isdir(samples_path):
        raise Exception("Samples dir not found.")

    for subdir, dirs, files in os.walk(samples_path):
        if subdir.endswith("GO"):
            for file_name in os.listdir(subdir):
                if file_name.endswith(".go"):
                    if os.name == "nt": 
                        split_subdir = subdir.split("\\")
                    else:
                        split_subdir = subdir.split("/")

                    test_dest = os.path.join(dest_path, split_subdir[-2])
                    shutil.copytree(os.path.join(subdir), test_dest)

    shutil.copy(os.path.join(samples_path, "runall_go.bat"), dest_path)
    shutil.copy(os.path.join(samples_path, "runall_go.sh"), dest_path)
    shutil.copytree(os.path.join(samples_path, "TestFiles"), os.path.join(dest_path, "TestFiles"))

def extractArchive(fileName, dest):
    ext = path(fileName)
    ext = ''.join(ext.suffixes)
    if ext == ".tar.gz":
        tarfile.open(fileName).extractall(dest)
    else:
        with zipfile(fileName, 'r') as archive:
            archive.extractall(dest)

    dest_headers = os.path.join(dest, "Headers")
    if os.path.exists(dest_headers):
       shutil.rmtree(dest_headers)
    shutil.copytree(os.path.join(dest, "PDFNetC64", "Headers"), dest_headers)

    dest_libs = os.path.join(dest, "Lib")
    if os.path.exists(dest_libs):
      shutil.rmtree(dest_libs)
    shutil.copytree(os.path.join(dest, "PDFNetC64", "Lib"), dest_libs)

    dest_res = os.path.join(dest, "Resources")
    if os.path.exists(dest_res):
      shutil.rmtree(dest_res)
    shutil.copytree(os.path.join(dest, "PDFNetC64", "Resources"), dest_res)

def buildWindows(custom_swig):
    if not os.path.exists("PDFNetC64.zip"):
        raise ValueError("Cannot find PDFNetC64.zip")

    extractArchive("PDFNetC64.zip", "%s/PDFNetC" % rootDir)

    os.chdir("%s/build" % rootDir)
    cmakeCommand = 'cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON ..'
    subprocess.run(shlex.split(cmakeCommand), check=True)

    # Fix issues with generated wrapper
    os.chdir(os.path.join(rootDir, "build", "PDFTronGo", "pdftron"))
    replace_path = os.path.join(rootDir, "PDFTronGo", "ci", "windows")
    replacego(replace_path, ".")
    shutil.move("pdftron_wrap.cxx", "Lib/")
    shutil.move("pdftron_wrap.h", "Lib/")
    # If you don't remove this, g++ will grab it instead of the .dll
    os.remove("Lib/PDFNetC.lib")
    
    gccCommand = "g++ -I./Headers -L./Lib -lPDFNetC -shared Lib/pdftron_wrap.cxx -o Lib/pdftron.dll"
    subprocess.run(shlex.split(gccCommand), check=True)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/win/Headers"'
    ldflags = '#cgo LDFLAGS: -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/win/Lib" -lstdc++'
    insertCGODirectives("pdftron.go", cxxflags, ldflags)
    setBuildDirectives("pdftron.go")

    os.makedirs("shared_libs/win", exist_ok=True)
    shutil.move("Lib", "shared_libs/win/Lib")
    shutil.move("Headers", "shared_libs/win/Headers")
    shutil.move("Resources", "shared_libs/win/Resources")

    os.chdir(rootDir)

def buildLinux(custom_swig):
    print("Running Linux build...")
    if not os.path.exists("PDFNetC64.tar.gz"):
        raise ValueError("Cannot find PDFNetC64.tar.gz")

    extractArchive("PDFNetC64.tar.gz", "%s/PDFNetC" % rootDir)

    os.chdir("%s/build" % rootDir)

    cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON ..'
    subprocess.run(shlex.split(cmakeCommand), check=True)
    
    os.chdir(os.path.join(rootDir, "build", "PDFTronGo", "pdftron"))
    shutil.move("pdftron_wrap.cxx", "Lib/")
    shutil.move("pdftron_wrap.h", "Lib/")

    gccCommand = "clang -fuse-ld=gold -fpic -I./Headers -L./Lib -lPDFNetC -shared Lib/pdftron_wrap.cxx -o Lib/libpdftron.so"
    subprocess.run(shlex.split(gccCommand), check=True)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/unix/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/unix/Lib" -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/unix/Lib" -lstdc++'
    insertCGODirectives("pdftron.go", cxxflags, ldflags)
    setBuildDirectives("pdftron.go")

    os.makedirs("shared_libs/unix", exist_ok=True)
    shutil.move("Lib", "shared_libs/unix/Lib")
    shutil.move("Headers", "shared_libs/unix/Headers")
    shutil.move("Resources", "shared_libs/unix/Resources")
    os.chdir(rootDir)

def buildDarwin(custom_swig):
    if not os.path.exists("PDFNetCMac.zip"):
        raise ValueError("Cannot find PDFNetCMac.zip")

    extractArchive("PDFNetCMac.zip", "%s/PDFNetC" % rootDir)
    os.remove("PDFNetCMac.zip")

    os.chdir("%s/build" % rootDir)
    cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON ..'
    subprocess.run(shlex.split(cmakeCommand), check=True)

    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)
    gccCommand = "gcc -fPIC -lstdc++ -I./Headers -L./Lib -lPDFNetC -dynamiclib -undefined suppress -flat_namespace Lib/pdftron_wrap.cxx -o Lib/libpdftron.dylib"
    subprocess.run(shlex.split(gccCommand), check=True)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/mac/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/mac/Lib" -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/mac/Lib"'
    insertCGODirectives("pdftron.go", cxxflags, ldflags)
    setBuildDirectives("pdftron.go")

    os.makedirs("shared_libs/mac", exist_ok=True)
    shutil.move("Lib", "shared_libs/mac/Lib")
    shutil.move("Headers", "shared_libs/mac/Headers")
    shutil.move("Resources", "shared_libs/mac/Resources")
    os.chdir(rootDir)

# inserts CGO LDFLAGS/CXFLAGS for usage during go build
# Should be inserted into any generated swig files at the start of the /* swig */ comment
# https://pkg.go.dev/cmd/cgo
def insertCGODirectives(filename, cxxflags, ldflags):
    inserted = False
    data = ''
    with open(filename, "r") as original:
        for line in original.readlines():
            if "#define intgo swig_intgo" in line and not inserted:
                inserted = True
                data += "%s\n%s\n" % (cxxflags, ldflags)

            data += line

    with open(filename, "w") as modified:
        modified.write(data)

# Sets where the source file should build. For single OS files we just
# change the name to the build machine type. For Linux we support multiple unix like architectures
# https://pkg.go.dev/go/build
# Should use +build instead of new //go:build to support 1.15
def setBuildDirectives(filename):
    if platform.system().startswith('Linux'):
        data = ''
        text = "// +build freebsd linux netbsd openbsd"
        print("Writing %s to %s" % (text, filename))
        with open(filename, "r") as original:
            data = original.read()
        with open(filename, "w") as modified:
            modified.write("%s\n%s" % (text, data))
    elif platform.system().startswith('Windows'):
        os.rename(filename, 'pdftron_windows.go')
    else:
        os.rename(filename, 'pdftron_darwin.go')

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-cs', '--custom_swig', dest='custom_swig', default='')

    stored_args, ignored_args = parser.parse_known_args()
    custom_swig = stored_args.custom_swig

    try:
        shutil.rmtree("build", ignore_errors=True)
    except FileNotFoundError:
        pass

    os.mkdir("build")

    if platform.system().startswith('Windows'):
        buildWindows(custom_swig)
    elif platform.system().startswith('Linux'):
        buildLinux(custom_swig)
    else:
        buildDarwin(custom_swig)

    os.chdir(os.path.join(rootDir, "build"));
    shutil.copy(
       os.path.join(rootDir, "PDFTronGo", "go.mod"),
       os.path.join(rootDir, "build", "PDFTronGo", "pdftron"))

    print("Fixing samples...")
    fixSamples()

    shutil.make_archive("PDFTronGo", "zip", "PDFTronGo/pdftron")
    print("Build completed.")
    return 0

if __name__ == '__main__':
    main()
