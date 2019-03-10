#!/bin/bash
folderPath=$1
program=$2
arguments="$3"
value=0
compilation="PASS"
memoryLeak="PASS"
threadRace="PASS"
originalPath=`pwd`
#move dircteory to folder path
cd ~
cd $folderPath
#check if Makefile exist
if [[ ! -e "./Makefile" ]]; then
	echo "Makefile does not exist"
	value=7
	compilation="FAIL"
	memoryLeak="FAIL"
	threadRace="FAIL"
else
	#check compilation
	make > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		#check memory leak
		valgrind --leak-check=full --error-exitcode=1 "./$program" $arguments > /dev/null 2>&1
		if [[ ! $? -eq 0 ]]; then
			#value=$value+2
			(( value+=2 ))
			memoryLeak="FAIL"
		fi
		#check thread race
		valgrind --tool=helgrind --error-exitcode=1 "./$program" $arguments > /dev/null 2>&1
		if [[ ! $? -eq 0 ]]; then
			(( value+=4 ))
			threadRace="FAIL"
		fi
	else
		(( value+=1 ))
		compilation="FAIL"
	fi
fi

#print resualts
echo "Compilation	Memory Leak	Thread Race"
echo "   $compilation	           $memoryLeak		   $threadRace"
#return to the original path
cd $originalPath
exit "$value"
