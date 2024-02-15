#!/bin/bash

WORKING_DIRECTORY='/tmp/task'
REPO_NAME='InformatykaOlimpijska'
TEST_REPO_NAME='ConsoleCheckerTests'
TIMEOUT=1

while getopts 'n:t:' FLAG; do
	case "${FLAG}" in
		n) FILE_NAME=$OPTARG ;;
		t) TIMEOUT=$OPTARG ;;
	esac
done

if [[ -z $FILE_NAME ]]; then
	echo "Task name not given!"
	exit 1
fi

rm -rf $WORKING_DIRECTORY
mkdir $WORKING_DIRECTORY
cd $WORKING_DIRECTORY
mkdir programs 
mkdir tests

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$REPO_NAME.git
cd $REPO_NAME
echo $(git branch --list -a | grep '^\s*remotes/origin/' | grep -v main | grep -v HEAD)
BRANCHES=$(git branch --list -a | grep '^\s*remotes/origin/' | grep -v main | grep -v HEAD)

for BRANCH in ${BRANCHES[@]}; do
	git checkout $BRANCH
	CPP=$(ls | grep $FILE_NAME.cpp | head -1)
	BRANCH_OWNER=${BRANCH##*/}
	g++ $CPP -o $WORKING_DIRECTORY/programs/$BRANCH_OWNER
done

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$TEST_REPO_NAME.git
cd $TEST_REPO_NAME/$FILE_NAME
cp -r * $WORKING_DIRECTORY/tests

echo "Testing (${FILE_NAME}):"
cd $WORKING_DIRECTORY
mkdir out
CONTESTANTS=$(ls $WORKING_DIRECTORY/programs/)
TESTS=$(ls $WORKING_DIRECTORY/tests/)

for CONTESTANT in ${CONTESTANTS[@]}; do 
	echo "    $CONTESTANT:"
	mkdir out/$CONTESTANT
	for TEST in ${TESTS[@]}; do
		mkdir out/$CONTESTANT/$TEST
		TEST_CASES=$(ls tests/${TEST}/in/)
		for TEST_CASE in ${TEST_CASES[@]}; do
			TEST_CASE=${TEST_CASE%%.*}
			WRONG_CASE=""
			TLE_CASE=""
			timeout $TIMEOUT ./programs/$CONTESTANT < tests/${TEST}/in/$TEST_CASE.in > out/$CONTESTANT/$TEST/$TEST_CASE.out
			STATUS=$?
			if [[ $STATUS -eq 124 ]]; then
				TLE_CASE=$TEST_CASE
				break
			fi
			DIFF=$(diff -wB tests/${TEST}/out/$TEST_CASE.out out/$CONTESTANT/$TEST/$TEST_CASE.out)
			if [[ -n $DIFF ]]; then
				WRONG_CASE=$TEST_CASE
				break
			fi
		done
		if [[ -n $WRONG_CASE ]]; then
			echo "        Test $TEST: WRONG! (test case $TEST_CASE)"
		elif [[ -n $TLE_CASE ]]; then
			echo "        Test $TEST: TLE! (test case $TEST_CASE)"
		else
			echo "        Test $TEST: OK!"
		fi
	done
done

