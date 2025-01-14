#!/bin/bash
# Script to update a lot of repositories at once.
set -e

usage(){
  echo 'update_repos.sh [OPTIONS]'
  echo 'If you have a lot of infra or config repos checked out into a single directory, you can'
  echo 'use this script to update them all at once.'
  echo 'IMPORTANT: Script assumes all the repos use the same branch naming convention.'
  echo ''
  echo 'Available options:'
  echo '--default: Name of the default branch, 1.x, 2.x, apply, etc.'
  echo '--remote: Defaults to origin, allows you to set an alternative remote name'
}

# Set defaults
REMOTE="origin"
DEVEL_BRANCH="devel-2.x"
DEFAULT="2.x"

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--default")
          shift
          DEFAULT="$1"
          DEVEL_BRANCH="devel-$1"
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

# Load current directory
dir=$(pwd)

echo "NOW EXECUTING GIT COMMANDS"
echo "--------------------------"
# Assuming each subdirectory is a git repo, loop over them
for repo in $dir/*/
do
  echo "Treating directory $repo"
  echo ""
  # Move to repo directory and grab currently checked out branch name
  cd $repo
  this_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

  # Fetch all branches
  git_branches=`git branch`

  # Determine naming convention applied
  if [[ $git_branches == *"$DEFAULT"* ]]; then
    echo "Using $DEVEL_BRANCH/$DEFAULT naming convention."
    main_branch="$DEFAULT"
    test_branch="$DEVEL_BRANCH"
  else
    echo "Using apply/test naming convention."
    main_branch="apply"
    test_branch="test"
  fi

  # Update main branches
  echo "Updating the $REMOTE/$test_branch branch."
  git checkout $test_branch || true
  git pull $REMOTE $test_branch || true
  echo "Updating the $REMOTE/$main_branch branch."
  git checkout $main_branch || true
  git pull $REMOTE $main_branch || true
  # Put us back in the branch where we started
  git checkout $this_branch
  echo ""
  echo "---------------------------"
  echo "NEXT REPO!"
  echo "---------------------------"
done

echo "ALL DONE!"

