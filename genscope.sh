#!/bin/bash

# Remove any existing cscope file lists
if [ -e ./cscope.files ]; then
	rm cscope.files
fi

#extensions=(c h cpp hpp xml java cc json txt idl sh)
extensions=(c h cpp hpp)
if [ "$1" == "-server" ]; then
	echo "server flag detected!"
	extensions=(c h cpp hpp java idl txt)
	shift 1
elif [ "$1" == "-rctt" ]; then
	echo "rctt flag detected!"
	extensions=(ets eth txt)
	shift 1
fi
args=( "$@" )
argslength=${#args[@]}
for (( i=1; i<${argslength}+1; i++ ));
do
#   echo arg[$i] = "${args[$i-1]}"
   path="$(realpath ${args[$i-1]})"
#   echo path[$i] = "$path"
   echo Searching $path for files...

   for ext in "${extensions[@]}"
   do
      find $path -name "*.$ext" -type f -exec echo \"{}\" \; >> cscope.files
   done
done

echo Finished finding files, rebuilding cscope database...

cscope -b
CSCOPE_DB=$(pwd)/cscope.out; export CSCOPE_DB

echo Cscope database rebuild complete! Playing DING.
paplay /home/bfreeland/SFX/ding.wav&
