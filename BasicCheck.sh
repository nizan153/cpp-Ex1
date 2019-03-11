#!/bin/bash
folderPath=$1
program=$2
arguments=${@:3}
value=0
compilation="FAIL"
memoryLeak="FAIL"
threadRace="FAIL"
originalPath=`pwd`
#move dircteory to folder path
cd $folderPath
#check if Makefile exist
make > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	compilation="PASS"
	#check memory leak
	valgrind --leak-check=full --error-exitcode=1 "./$program" $arguments > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		memoryLeak="PASS"
	else
		(( value+=2 ))
	fi
	#check thread race
	valgrind --tool=helgrind --error-exitcode=1 "./$program" $arguments > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		threadRace="PASS"
	else
		(( value+=1 ))
	fi
else
	(( value = 7 ))
fi

echo $0 $folderPath $program $arguments
#print resualts
echo "Compilation	Memory Leak	Thread Race"
echo "   $compilation	           $memoryLeak		   $threadRace"
#return to the original path
cd $originalPath
exit "$value"
