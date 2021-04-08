#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2021 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------
import sys
import platform
try:
    from PDFNetPython3 import *
except ImportError as e:
    py3 = "python"if platform.system().lower() == "windows" else "python3"
    print('')
    print(e)
    print("--------------------------------------------------------------------------------------------------------------------")
    print("  You need to install PDFNetPython3 via pip before you could run the samples [$%s -m pip install PDFNetPython3]." % py3)
    print("  Please refer to  'https://www.pdftron.com/documentation/python/get-started/python3' for more information!")
    print("--------------------------------------------------------------------------------------------------------------------")
    exit(1)
except Exception as e:
    print(e)
    exit(1)
exit(0)
