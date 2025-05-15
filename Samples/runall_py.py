import os
import subprocess
import sys

print("Running Python tests with %s", sys.executable)

for name in os.listdir('./'):
    if os.path.isdir(name):
        ret = subprocess.run([sys.executable, "%s/PYTHON/%s.py" % (name, name)])
        if ret != 0:
            print("Test %s failed!" % name)

print("Tests completed");
