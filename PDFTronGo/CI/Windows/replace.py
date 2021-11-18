import re
import os

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
