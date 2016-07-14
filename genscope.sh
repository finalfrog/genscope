#!/bin/bash


function printUsage() {
	echo "$0"
	echo "Usage:"
	echo "Generates a cscope database in the current directory using all source files found in all the given directories"
	echo ""
	echo "Syntax: $0 [FLAGS] PATH..."
	echo ""i
	echo "General Flags:"
	echo "  -h, --help           			: Display this message"
	echo
	echo "Mode Flags (Exclusive):"
	echo "  --c                             : Searches for C/C++ associated source files"
	echo "  --cjava                         : Searches for C/C++/Java associated source files"
	echo "  --javascript                    : Searches for Javascript assocated source files"
}

MODE=""

# Main
echo Parsing arguments...
until [ -z "$1" ]; do
	case "$1" in
		-h|--help)
			printUsage
			exit 0
			;;
		--c)
			if [ "$MODE" = "" ]; then
				MODE="c"
			else
				echo "Error: Multiple mode flags detected"
				printUsage
#				paplay ~/SFX/bump.wav
				exit 1
			fi
			shift 1
			;;
		--cjava)
			if [ "$MODE" = "" ]; then
				MODE="cjava"
			else
				echo "Error: Multiple mode flags detected"
				printUsage
#				paplay ~/SFX/bump.wav
				exit 1
			fi
			shift 1
			;;
		--javascript)
			if [ "$MODE" = "" ]; then
				MODE="javascript"
			else
				echo "Error: Multiple mode flags detected"
				printUsage
#				paplay ~/SFX/bump.wav
				exit 1
			fi
			shift 1
			;;
		*)
			break
			;;
	esac
done

# Check for at least one source path arguement
if [ $# = 0 ]; then
	echo "Error: Please supply at least one directory as argument"
	printUsage
#	paplay ~/SFX/bump.wav
	exit 1
fi

# Default to C/C++ mode
if [ "$MODE" = "" ]; then
	MODE="c"
	echo "Using default extensions search mode: $MODE"
else
	echo "Using extensions search mode: $MODE"
fi

# Set source file extension search filter
if [ "$MODE" == "c" ]; then
	extensions=(c h cpp hpp) # C/C++
elif [ "$MODE" == "cjava" ]; then
	extensions=(c h cpp hpp java idl txt) # C/C++/Java
elif [ "$MODE" == "javascript" ]; then
	extensions=(ets eth txt) # Javascript
else
	echo "Error: Invalid mode: $MODE"
#	paplay ~/SFX/bump.wav
	exit 1
fi

# Remove any existing cscope file lists
if [ -e ./cscope.files ]; then
	rm cscope.files
fi

# Search supplied paths for source files
echo Processing path arguemnts...
args=( "$@" )
argslength=${#args[@]}
for (( i=1; i<${argslength}+1; i++ ));
do
	relativePath=${args[$i-1]}
	if [ ! -d $relativePath ]; then
		echo "Error: Relative path $relativePath not found"
		printUsage
#		paplay ~/SFX/bump.wav
		exit 1
	fi

	path="$(realpath $relativePath)"
	echo Searching $path for source files...
	for ext in "${extensions[@]}"
	do
		find $path -name "*.$ext" -type f -exec echo \"{}\" \; >> cscope.files
	done
done

# Generate cscope database
echo Finished source file search, rebuilding cscope database...
cscope -b
CSCOPE_DB=$(pwd)/cscope.out; export CSCOPE_DB

echo Cscope database rebuild complete!
#paplay ~/SFX/ding.wav&
