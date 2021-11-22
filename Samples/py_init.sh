#!/bin/sh
# Find PDFNetPyLibInfo
path_to_PDFNetPyLibInfo=../../../PDFNetC/Lib
file=$(find $path_to_PDFNetPyLibInfo -name "PDFNetPyLibInfo")

if [ -z "$file" ] ; then 
	echo Error: No PDFNetPyLibInfo is found! 1>&2
	exit 1
fi

# Get Python version's info from PDFNetPyLibInfo
count=$(grep -c "^Python 2" $file)
count3=$(grep -c "^Python 3" $file)

if [ $(($count+$count3)) -ne 1 ] ; then 
	echo Error: No Python2 or Python3 was found from PDFNetPyLibInfo! 1>&2
fi

if [ $count -eq 1 ] ; then
	pylib=2
elif [ $count3 -eq 1 ] ; then 
	pylib=3
fi

# Select the compatible python from the user's machine if applicable 
py=$(which python)
py3=$(which python3)
if [ ! -z "$py" ] && [ $pylib -eq 2 ] ; then
	python_exe="python"
elif [ ! -z "$py3" ] && [ $pylib -eq 3 ] ; then
	python_exe="python3"
	export PYTHONIOENCODING=UTF-8
else
	echo Error: Python library and installed Python are not compatible! 1>&2
	exit 1
fi

