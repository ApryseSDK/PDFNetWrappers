#!/bin/sh

for SAMPLE in *
do
	if [ -d $SAMPLE ]
	then
		if [ -e $SAMPLE/GO/RunTest.sh ]
		then
			cd $SAMPLE/GO
			echo "$SAMPLE running"
			sh RunTest.sh
			cd ../..
			echo "$SAMPLE finished. Press enter to continue..."
			read -p "$*" a
		fi
	fi
done
