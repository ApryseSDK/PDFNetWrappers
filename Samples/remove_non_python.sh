#!/bin/sh
cd Samples
for SAMPLE in *
    do
        if [ -d "$SAMPLE" ]  &&  [ "$SAMPLE" != "TestFiles" ]
        then    
                echo "removing anything other than python"
                cd "$SAMPLE"
                rm -rf PHP RUBY GO
                cd ..
        fi
    done
cd ..
