#!/bin/bash

WORKING_DIRECTORY='/tmp/task'
REPO_NAME='testTaskRepo'

while getopts 'n:' FLAG; do
	case "${FLAG}" in
		n) FILE_NAME=$OPTARG ;;
	esac
done

rm -rf $WORKING_DIRECTORY
mkdir $WORKING_DIRECTORY
cd $WORKING_DIRECTORY

mkdir tasks
git clone git@github.com:Wojciech-Baranowski/$REPO_NAME.git
cd testTaskRepo
BRANCHES=$(git branch --list -a | grep '^\s*remotes/origin/.*[^HEAD|main]$')

for BRANCH in ${BRANCHES[@]}; do 
	git checkout $BRANCH
	CPP=$(ls | grep $FILE_NAME.cpp | head -1)
	BRANCH_OWNER=${BRANCH##*/}
	gcc $CPP -o $WORKING_DIRECTORY/tasks/$BRANCH_OWNER
done

