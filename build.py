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

    dir_name = fileName.split(".")[0]
    dest_headers = os.path.join(dest, "Headers")
    if os.path.exists(dest_headers):
       shutil.rmtree(dest_headers)
    shutil.copytree(os.path.join(dest, dir_name, "Headers"), dest_headers)

    dest_libs = os.path.join(dest, "Lib")
    if os.path.exists(dest_libs):
      shutil.rmtree(dest_libs)
    shutil.copytree(os.path.join(dest, dir_name, "Lib"), dest_libs)

    dest_res = os.path.join(dest, "Resources")
    if os.path.exists(dest_res):
      shutil.rmtree(dest_res)
    shutil.copytree(os.path.join(dest, dir_name, "Resources"), dest_res)

    shutil.rmtree(os.path.join(dest, dir_name))

def buildWindows(custom_swig):
    print("Running Windows build...")
    if not os.path.exists("PDFNetC64.zip"):
        raise ValueError("Cannot find PDFNetC64.zip")

    extractArchive("PDFNetC64.zip", "%s/build/PDFNetC" % rootDir)

    os.chdir("%s/build" % rootDir)
    if custom_swig:
        cmakeCommand = 'cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON -D CUSTOM_SWIG=%s ..' % custom_swig
    else:
        cmakeCommand = 'cmake -G "MinGW Makefiles" -D BUILD_PDFTronGo=ON ..'

    subprocess.run(shlex.split(cmakeCommand), check=True)

    # Fix issues with generated wrapper
    os.chdir(os.path.join(rootDir, "build", "PDFTronGo", "pdftron"))
    replace_path = os.path.join(rootDir, "PDFTronGo", "ci", "windows")
    replacego(replace_path, ".")

    # If you don't remove this, g++ will grab it instead of the .dll
    os.remove("Lib/PDFNetC.lib")
    
    gccCommand = "g++ -I./Headers -L./Lib -lPDFNetC -shared pdftron_wrap.cxx -o Lib/pdftron.dll"
    subprocess.run(shlex.split(gccCommand), check=True)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/win/Headers"'
    ldflags = '#cgo LDFLAGS: -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/win/Lib" -lstdc++'
    shutil.copy("pdftron.go", "pdftron_windows.go")
    insertCGODirectives("pdftron_windows.go", cxxflags, ldflags)
    setBuildDirectives("pdftron_windows.go")

    cleanupDirectories("win")

    os.chdir(rootDir)

def buildLinux(custom_swig):
    print("Running Linux build...")
    if not os.path.exists("PDFNetC64.tar.gz"):
        raise ValueError("Cannot find PDFNetC64.tar.gz")

    extractArchive("PDFNetC64.tar.gz", "%s/build/PDFNetC" % rootDir)

    os.chdir("%s/build" % rootDir)
    print(os.getcwd())
    if custom_swig:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON -D CUSTOM_SWIG=%s ..' % custom_swig
    else:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON ..'

    subprocess.run(shlex.split(cmakeCommand), check=True)
    
    os.chdir(os.path.join(rootDir, "build", "PDFTronGo", "pdftron"))

    gccCommand = "clang -fpic -I./Headers -L./Lib\
 -lPDFNetC -shared pdftron_wrap.cxx -o Lib/libpdftron.so"
    subprocess.run(shlex.split(gccCommand), check=True)



    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/unix/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/unix/Lib"\
 -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/unix/Lib" -lstdc++'
    insertCGODirectives("pdftron.go", cxxflags, ldflags)
    setBuildDirectives("pdftron.go")
    shutil.copy("pdftron.go", "pdftron_linux.go")

    cleanupDirectories("unix")
    os.chdir(rootDir)

def buildDarwin(custom_swig):
    print("Running Mac build...")
    if not os.path.exists("PDFNetCMac.zip"):
        raise ValueError("Cannot find PDFNetCMac.zip")

    extractArchive("PDFNetCMac.zip", "%s/build/PDFNetC" % rootDir)

    # splits binary into arm/x64 so the size isnt so large
    splitBinaries(os.path.join(rootDir, "build", "PDFNetC", "Lib"), "libPDFNetC.dylib", "arm64")
    splitBinaries(os.path.join(rootDir, "build", "PDFNetC", "Lib"), "libPDFNetC.dylib", "x86_64")
    os.remove("%s/build/PDFNetC/Lib/libPDFNetC.dylib" % rootDir)

    os.chdir("%s/build" % rootDir)
    if custom_swig:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON -D CUSTOM_SWIG=%s ..' % custom_swig
    else:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON ..'

    subprocess.run(shlex.split(cmakeCommand), check=True)

    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)

    # We have to create slightly different binaries for each arch
    createMacBinaries("x86_64")
    createMacBinaries("arm64")

    cleanupDirectories("mac")

    os.chdir(rootDir)

def buildDarwinArm(custom_swig):
    print("Running Mac build...")
    if not os.path.exists("PDFNetCMac.zip"):
        raise ValueError("Cannot find PDFNetCMac.zip")

    extractArchive("PDFNetCMac.zip", "%s/build/PDFNetC" % rootDir)

    # splits binary into arm/x64 so the size isnt so large
    splitBinaries(os.path.join(rootDir, "build", "PDFNetC", "Lib"), "libPDFNetC.dylib", "arm64")
    os.remove("%s/build/PDFNetC/Lib/libPDFNetC.dylib" % rootDir)

    os.chdir("%s/build" % rootDir)
    if custom_swig:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON -D CUSTOM_SWIG=%s ..' % custom_swig
    else:
        cmakeCommand = 'cmake -D BUILD_PDFTronGo=ON ..'

    subprocess.run(shlex.split(cmakeCommand), check=True)

    os.chdir("%s/build/PDFTronGo/pdftron" % rootDir)

    createMacBinaries("arm64")

    cleanupDirectories("mac")

    os.chdir(rootDir)

def cleanupDirectories(system):
    os.makedirs("shared_libs/%s" % system, exist_ok=True)
    os.remove("pdftron_wrap.cxx")
    os.remove("pdftron.go")
    os.remove("pdftron_wrap.h")
    shutil.rmtree("Headers")
    os.remove("Lib/PDFNet.jar")
    shutil.move("Lib", "shared_libs/%s/Lib" % system)
    shutil.move("Resources", "shared_libs/%s/Resources" % system)

def createMacBinaries(arch):
    # We don't provide an output name and use install_name instead, so that mac does not inject the output name as a shared dependency
    gccCommand = "clang -fPIC -lstdc++ -I./Headers -L./Lib/%s -lPDFNetC\
 -dynamiclib -undefined suppress -flat_namespace pdftron_wrap.cxx\
 -install_name @rpath/libpdftron.dylib" % (arch)
    subprocess.run(shlex.split(gccCommand), check=True)
    shutil.move("a.out", "Lib/%s/libpdftron.dylib" % arch)

    cxxflags = '#cgo CXXFLAGS: -I"${SRCDIR}/shared_libs/mac/Headers"'
    ldflags = '#cgo LDFLAGS: -Wl,-rpath,"${SRCDIR}/shared_libs/mac/Lib/%s/"\
 -lpdftron -lPDFNetC -L"${SRCDIR}/shared_libs/mac/Lib/%s/"' % (arch, arch)
    shutil.copy("pdftron.go", "pdftron_darwin_%s.go" % arch)
    insertCGODirectives("pdftron_darwin_%s.go" % arch, cxxflags, ldflags)
    setBuildDirectives("pdftron_darwin_%s.go" % arch, arch)

def splitBinaries(lib_path, lib_name, arch):
    lastDir = os.getcwd()
    os.chdir(lib_path)
    lib_names = lib_name.split(".")

    name = "%s_%s.%s" % (lib_names[0], arch, lib_names[1])

    split_obj = "lipo %s -thin %s -output %s" % (lib_name, arch, name)
    subprocess.run(shlex.split(split_obj), check=True)

    os.mkdir(arch)
    shutil.move(name, "%s/libPDFNetC.dylib" % arch)

    os.chdir(lastDir)

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
def setBuildDirectives(filename, arch = ""):
    if platform.system().startswith('Linux'):
        data = ''
        text = "// +build freebsd linux netbsd openbsd\n"
        print("Writing %s to %s" % (text, filename))
        with open(filename, "r") as original:
            data = original.read()
        with open(filename, "w") as modified:
            modified.write("%s\n%s" % (text, data))
    elif platform.system().startswith('Windows'):
        text = "// +build windows\n"
        print("Writing %s to %s" % (text, filename))
        with open(filename, "r") as original:
            data = original.read()
        with open(filename, "w") as modified:
            modified.write("%s\n%s" % (text, data))
    else:
        directive_arch = "amd64"
        if (arch == "arm64"):
                directive_arch = "arm64"

        text = "// +build darwin\n// +build %s\n" % directive_arch
        print("Writing %s to %s" % (text, filename))
        with open(filename, "r") as original:
            data = original.read()
        with open(filename, "w") as modified:
            modified.write("%s\n%s" % (text, data))

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
    elif platform.system().startswith('Darwin') and platform.processor().startswith('arm'):
        buildDarwinArm(custom_swig)
    else:
        buildDarwin(custom_swig)

    os.chdir(os.path.join(rootDir, "build"));

    shutil.copy(os.path.join(rootDir, "PDFTronGo", "README.md"),
                os.path.join("PDFTronGo", "pdftron"))

    shutil.copy(os.path.join(rootDir, "PDFTronGo", "go.mod"),
                os.path.join("PDFTronGo", "pdftron"))

    print("Fixing samples...")
    fixSamples()

    shutil.make_archive("PDFTronGo", "zip", "PDFTronGo/pdftron")
    print("Build completed.")
    return 0

if __name__ == '__main__':
    main()
