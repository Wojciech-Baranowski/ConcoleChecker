#!/bin/bash

WORKING_DIRECTORY='/tmp/task'
REPO_NAME='testTaskRepo'
TEST_REPO_NAME='ConsoleCheckerTests'

while getopts 'n:' FLAG; do
	case "${FLAG}" in
		n) FILE_NAME=$OPTARG ;;
	esac
done

rm -rf $WORKING_DIRECTORY
mkdir $WORKING_DIRECTORY
cd $WORKING_DIRECTORY
mkdir programs 
mkdir tests

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$REPO_NAME.git
cd $REPO_NAME
BRANCHES=$(git branch --list -a | grep '^\s*remotes/origin/.*[^HEAD|main]$')

for BRANCH in ${BRANCHES[@]}; do 
	git checkout $BRANCH
	CPP=$(ls | grep $FILE_NAME.cpp | head -1)
	BRANCH_OWNER=${BRANCH##*/}
	gcc $CPP -o $WORKING_DIRECTORY/programs/$BRANCH_OWNER
done

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$TEST_REPO_NAME.git
cd $TEST_REPO_NAME/$FILE_NAME
cp -r * $WORKING_DIRECTORY/tests

echo "Testing!"
cd $WORKING_DIRECTORY
rm -rf out
mkdir out
CONTESTANTS=$(ls $WORKING_DIRECTORY/programs/)
TESTS=$(ls $WORKING_DIRECTORY/tests/)

for CONTESTANT in ${CONTESTANTS[@]}; do 
	echo "    $CONTESTANT:"
	mkdir out/$CONTESTANT
	for TEST in ${TESTS[@]}; do
		TEST_CASES=$(ls tests/${TEST}/in/)
		for TEST_CASE in ${TEST_CASES[@]}; do
			TEST_CASE=${TEST_CASE%%.*}
			./programs/$CONTESTANT < tests/${TEST}/in/$TEST_CASE.in > out/$CONTESTANT/$TEST_CASE.out
			DIFF=$(diff -wB tests/${TEST}/in/$TEST_CASE.in out/$CONTESTANT/$TEST_CASE.out)
			if [[ -n $DIFF ]]; then
				WRONG_CASE=$TEST_CASE
				break
			fi
		done
		if [[ -z $WRONG_CASE ]]; then
			echo "        Test $TEST: OK!"
		else
			echo "        Test $TEST: WRONG! (test case $TEST_CASE)"
		fi
	done
done


