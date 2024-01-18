#!/bin/bash
# Script to prepare a working feature branch
set -e

usage(){
  echo 'prepare_branch.sh [OPTIONS]'
  echo 'Prepare feature branch for working with.'
  echo ''
  echo 'Available options:'
  echo '--name: Name of the feature branch to create or refresh'
  echo '--default: Name of the default branch, 1.x, 2.x, apply, etc.'
  echo '--remote: Defaults to origin, allows you to set an alternative remote name'
}

# Set defaults
REMOTE="origin"
DEFAULT="1.x"

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--name")
          shift
	  NAME="$1"
        ;;
      "--default")
          shift
          DEFAULT="$1"
        ;;
      "--remote")
          shift
          REMOTE="$1"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Parse options.
echo "Parsing provided options."
parse_options "$@"

# Check we received a feature branch name
if [ -z "$NAME" ]; then
  echo "You must provide a branch name. Exiting."
  exit 1
fi

# Fetch branches
git_branches=`git branch`

# Determine naming convention applied
if [[ $git_branches == *"$DEFAULT"* ]]; then
  echo "Using devel/$DEFAULT naming convention."
elif [[ $git_branches == *"apply"* ]]; then
  echo "Using apply/test naming convention."
  DEFAULT="apply"
else
  echo "Unable to determine the default branch name. Exiting."
  exit 1
fi

echo "NOW EXECUTING GIT COMMANDS!"
echo "---------------------------"

echo "Making sure main branch is up to date."
# Checkout and pull main branch
git checkout $DEFAULT
git pull $REMOTE $DEFAULT
echo "---------------------------"

echo "Preparing feature branch."
# Determine if feature branch exists
if [[ `git branch --list $NAME` ]]; then
   echo "Branch name with $NAME already exists."
   git checkout $NAME
   git merge $DEFAULT
else
   echo "No branch with name $NAME, creating."
   git checkout -b $NAME
fi
echo "---------------------------"
echo "ALL DONE!"
