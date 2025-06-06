import os
import subprocess
import sys

print("Running Python tests with %s", sys.executable)

for name in os.listdir('./'):
    if os.path.isdir(name):
        items = os.listdir(name)
        if "PYTHON" in items:
            ret = subprocess.run([sys.executable, "%s.py" % name], cwd="%s/PYTHON" % name)
            if ret != 0:
                print("Test %s failed!" % name)

print("Tests completed");
