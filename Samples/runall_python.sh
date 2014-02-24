#!/bin/sh

for SAMPLE in *
do
	if [ -d $SAMPLE ]
	then
		if [ -e $SAMPLE/PYTHON/RunTest.sh ]
		then
			cd $SAMPLE/PYTHON
			echo "$SAMPLE running"
			sh RunTest.sh
			cd ../..
			echo "$SAMPLE finished. Press enter to continue..."
			read -p "$*" a
		fi
	fi
done
