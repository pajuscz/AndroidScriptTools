#!/bin/bash

# Set icon path
ICO_PATH=$1

#if the path does not have last /, add it

function endPath {
	if [[ $1 != */ ]]; then
		echo "$1/"
	else
		echo $1
	fi 
}
# Is file a PNG?
function isPngFile {
	if [ -f $1 ];then
		if [[ $1 == *.png || $1 == *.PNG ]];then
			# Is an PNG file
			return 0 # 0 = true
		fi
	fi
	# 1 = false 
	return 1
}
#create dir if does not exist
function IFneMkdir {
	if [ ! -d $1 ]; then
		mkdir -p $1 ##@TODO check the parent creation
		return 0
	fi
	return 1
}

#global prefixes
dir_prefix="drawable-"
declare -a DIRS=('ldpi' 'mdpi' 'hdpi' 'xhdpi' 'xxhdpi' 'xxxhdpi')
declare -a SIZES=('36x36' '48x48' '72x72' '96x96' '144x144' '192x192') 

#create directory structure
function cr8DirStructure {
	argv1=""

	if [ $1 ]; then
		argv1=$(endPath $1)	
	fi	

	for d in "${DIRS[@]}"; do
		created=$argv1$dir_prefix$d
		if IFneMkdir $created; then
			echo "creating directory: $created"
		#else
		#	echo "directory already exists!: $created"
		fi
	done;
}
#resize icon and copy into folders
function resAndCopy {
	icon_src=$1
	argv1=""
	icon_name="ic_launcher.png"
	if [ $2 ]; then
		argv1=$(endPath $2)	
	fi

	if [ -d $argv1 ]; then
		for i in "${!DIRS[@]}"; do
			created=$(endPath $argv1$dir_prefix"${DIRS[i]}")
			if [ -f $created$icon_name ]; then
				echo "rewriting ... $created$icon_name"
			else
				echo "creating icon ... $created$icon_name"
			fi
		
			convert $icon_src -resize "${SIZES[i]}" $created$icon_name
		#if IFneMkdir $created; then
		#	echo "creating directory: $created"
		#fi
		done;
	else
		echo "Directory '$argv1' does not exist!"	
	fi
}

#if one command line argument
if [ "$#" -eq 1 ] || [ "$#" -eq 2 ]; then
	if isPngFile $ICO_PATH; then
		
		if [ $2 ]; then
			if [ ! -d $2 ]; then
				echo "Android project "$2" does not exist"
			else
				cr8DirStructure $2
				resAndCopy $ICO_PATH $2
			fi 
			
		else
			cr8DirStructure
			resAndCopy $ICO_PATH
      fi
	else
		echo "$ICO_PATH is not a .png file"
	fi
	
else
	echo "usage: ./icogen icon.png [path to project's res]"
fi
