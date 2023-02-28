import os
import argparse
import re
import shutil
import platform
import tarfile
import subprocess
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

def fixSamples():
    samples_path = os.path.join(rootDir, "build/PDFTronGo/pdftron/Samples")

    if not os.path.isdir(samples_path):
        raise Exception("Samples dir not found.")

    for dirName, subdirList, fileList in os.walk(samples_path):
        if "GO" not in dirName:
            shutil.rmtree(dirName)

def extractArchive(fileName, dest):
    ext = path(fileName)
    ext = ''.join(ext.suffixes)
    if ext == ".tar.gz":
        tarfile.open(fileName).extractall(dest)
    else:
        with zipfile(fileName, 'r') as archive:
            archive.extractall(dest)

def buildWindows(cmakeCommand):
    if not os.path.exists("PDFNetC64.zip"):
        raise ValueError("Cannot find PDFNetC64.zip")

    extractArchive("PDFNetC64.zip")
    gccCommand = "g++ -shared -I%s/Headers -L . -lPDFNetC pdftron_wrap.cxx -o pdftron.dll"

    os.chdir("%s/build" % rootDir)
    runCommand(cmakeCommand)

    root_path = os.path.join(rootDir, "PDFTronGo", "CI", "Windows")
    dest_path = os.path.join(rootDir, "PDFTronGo", "pdftron")
    shutil.copy(os.path.join(root_path, "pdftron.go.replace"), dest_path)
    shutil.copy(os.path.join(root_path, "pdftron_wrap.cxx.replace"), dest_path)
    shutil.copy(os.path.join(root_path, "pdftron_wrap.h.replace"), dest_path)
    replacego(dest_path)
    shutil.move(os.path.join(dest_path, "pdftron_wrap.cxx"), os.path.join("PDFNetC", "Lib"))
    shutil.move(os.path.join(dest_path, "pdftron_wrap.h"), os.path.join("PDFNetC", "Lib"))
    os.remove(os.path.join(dest_path, "pdfnetc.lib"))

    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)
    runCommand(gccCommand)
    os.chdir(rootDir)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/win/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/win/Lib" -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/win/Lib"'
    insertCGODirectives("%s/build/PDFTronGo/pdftron/pdftron.go" % rootDir, cxxflags, ldflags)
    setBuildDirectives("%s/build/PDFTronGo/pdftron" % rootDir, "pdftron.go")

def buildLinux(cmakeCommand):
    print("Running Linux build...")
    if not os.path.exists("PDFNetC64.tar.gz"):
        raise ValueError("Cannot find PDFNetC64.tar.gz")

    extractArchive("PDFNetC64.tar.gz", "%s/PDFNetC" % rootDir)

    gccCommand = "g++ -fuse-ld=gold -fpic -I../Headers -L . -lPDFNetC -Wl,-rpath,. -shared -static-libstdc++ pdftron_wrap.cxx -o libpdftron.so"

    os.chdir("%s/build" % rootDir)
    runCommand(cmakeCommand)
    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)
    runCommand(gccCommand)
    os.chdir(rootDir)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/unix/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/unix/Lib" -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/unix/Lib"'
    insertCGODirectives("%s/build/PDFTronGo/pdftron/pdftron.go" % rootDir, cxxflags, ldflags)
    setBuildDirectives("%s/build/PDFTronGo/pdftron" % rootDir, "pdftron.go")

def buildDarwin(cmakeCommand):
    if not os.path.exists("PDFNetCMac.zip"):
        raise ValueError("Cannot find PDFNetCMac.zip")

    extractArchive("PDFNetCMac.zip")
    os.remove("PDFNetCMac.zip")
    gccCommand = "gcc -fPIC -lstdc++ -I../Headers -L. -lPDFNetC -dynamiclib -undefined suppress -flat_namespace pdftron_wrap.cxx -o libpdftron.dylib"

    os.chdir("%s/build" % rootDir)
    runCommand(cmakeCommand)
    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)
    runCommand(gccCommand)
    os.chdir(rootDir)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/mac/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/mac/Lib" -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/mac/Lib"'
    insertCGODirectives("%s/build/PDFTronGo/pdftron/pdftron.go" % rootDir, cxxflags, ldflags)
    setBuildDirectives("%s/build/PDFTronGo/pdftron" % rootDir, "pdftron.go")

def runCommand(cmd):
    try:
        for data in execute(cmd):
            print(data, end="")
    except subprocess.CalledProcessError as e:
        print(e.stdout.decode())

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

    cmakeCommand = 'cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON ..'
    if custom_swig:
        cmakeCommand += " -D CUSTOM_SWIG=%s" % custom_swig

    if platform.system().startswith('Windows'):
        buildWindows(cmakeCommand)
    elif platform.system().startswith('Linux'):
        buildLinux(cmakeCommand)
    else:
        buildDarwin(cmakeCommand)

    os.chdir("../build")

    print("Fixing samples...")
    fixSamples(rootDir)

    print("Build completed.")
    return 0

# inserts CGO LDFLAGS/CXFLAGS for usage during go build
# Should be inserted into any generated swig files at the start of the /* swig */ comment
# https://pkg.go.dev/cmd/cgo
def insertCGODirectives(cxxflags, ldflags, filename):
    inserted = False
    data = ''
    with open(filename, "r") as original:
        for line in original.read():
            if "#define intgo swig_intgo" in line and not inserted:
                inserted = True
                data += "%s\n%s\n" % (cxxflags, ldflags)
                data += line


# Sets where the source file should build. For single OS files we just
# change the name to the build machine type. For Linux we support multiple unix like architectures
# https://pkg.go.dev/go/build
# Should use +build instead of new //go:build to support 1.15
def setBuildDirectives(src_dir, filename):
    if platform.system().startswith('Linux'):
        text = "// +build freebsd linux netbsd openbsd"
        print("Writing %s to %s" % (text, filename))
        actual_path = os.path.join(src_dir, filename)
        with open(actual_path, "r") as original:
            data = original.read()
        with open(actual_path, "w") as modified:
            modified.write("%s\n%s" % (text, data))
    elif platform.system().startswith('Windows'):
        os.rename(os.path.join(src_dir, filename), os.path.join(src_dir, 'pdftron_windows.go'))
    else:
        os.rename(os.path.join(src_dir, filename), os.path.join(src_dir, 'pdftron_darwin.go'))

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
