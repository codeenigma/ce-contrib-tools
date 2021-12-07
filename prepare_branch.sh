#!/bin/bash

# Check we received a feature branch name
if [ -z "$1" ]; then
  echo "You must provide a branch name. Exiting."
  exit 1
fi

# Fetch branches
git_branches=`git branch`

# Determine naming convention applied
if [[ $git_branches == *"1.x"* ]]; then
  echo "Using devel/1.x naming convention."
  main_branch="1.x"
else
  echo "Using apply/test naming convention."
  main_branch="apply"
fi

echo "NOW EXECUTING GIT COMMANDS!"
echo "---------------------------"

echo "Making sure main branch is up to date."
# Checkout and pull main branch
git checkout $main_branch
git pull origin $main_branch
echo "---------------------------"

echo "Preparing feature branch."
# Determine if feature branch exists
if [[ `git branch --list $1` ]]; then
   echo "Branch name with $1 already exists."
   git checkout $1
   git merge $main_branch
else
   echo "No branch with name $1, creating."
   git checkout -b $1
fi
echo "---------------------------"
echo "ALL DONE!"
