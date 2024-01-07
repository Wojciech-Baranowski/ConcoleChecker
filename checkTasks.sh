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
mkdir tasks
mkdir tests

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$REPO_NAME.git
cd $REPO_NAME
BRANCHES=$(git branch --list -a | grep '^\s*remotes/origin/.*[^HEAD|main]$')

for BRANCH in ${BRANCHES[@]}; do 
	git checkout $BRANCH
	CPP=$(ls | grep $FILE_NAME.cpp | head -1)
	BRANCH_OWNER=${BRANCH##*/}
	gcc $CPP -o $WORKING_DIRECTORY/tasks/$BRANCH_OWNER
done

cd $WORKING_DIRECTORY
git clone git@github.com:Wojciech-Baranowski/$TEST_REPO_NAME.git
cd $TEST_REPO_NAME/$FILE_NAME
cp -r in $WORKING_DIRECTORY/tests
cp -r out $WORKING_DIRECTORY/tests


