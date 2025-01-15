#!/bin/bash
# Script to prepare feature branches for pull requests
set -e

usage(){
  echo 'commit.sh [OPTIONS]'
  echo 'Prepare feature branches for pull requests.'
  echo ''
  echo 'Available options:'
  echo '--apply: Creates a feature branch for committing to the live branch, false by default'
  echo '--default: The target default live branch, defaults to 2.x'
  echo '--remote: Defaults to origin, allows you to set an alternative remote name'
  echo '--skip-checks: Skip over any Git verification steps'
}

# Set defaults
APPLY=false
DEFAULT="2.x"
DEVEL_BRANCH="devel-2.x"
REMOTE="origin"

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--apply")
          APPLY=true
        ;;
      "--default")
	  shift
          DEFAULT="$1"
	  DEVEL_BRANCH="devel-$1"
        ;;
      "--skip-checks")
          SKIP_CHECKS=true
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

# Determine the current branch
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"     # detached HEAD
branch_name=${branch_name##refs/heads/}
echo "Working on branch $branch_name."

# Get remote info
remote_check=`git remote -v show`

# Determine if this is GitHub or GitLab
if [[ $remote_check == *"github"* ]]; then
  echo "GitHub repo, will name branches with PR."
  merge_indicator="PR"
else
  echo "Not a GitHub repo, assuming GitLab, will name branches with MR."
  merge_indicator="MR"
fi

# Determine if we're on a feature branch
if [[ $branch_name == *"$merge_indicator"* ]]; then
  echo "Looks like you're trying to run this script from your merge branch!"
  echo "You need to run it from your feature branch. Exiting."
  exit 1
fi

# Fetch branches
git fetch --all --prune
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

echo "NOW EXECUTING GIT COMMANDS!"
echo "---------------------------"

echo "Making sure main and test branches are up to date."
# Checkout and pull main and test branches
git checkout $test_branch
git pull $REMOTE $test_branch
git checkout $main_branch
git pull $REMOTE $main_branch
echo "---------------------------"

echo "Preparing test branch for merge request."
git checkout $test_branch
# Determine if merge branch exists for test
if [[ `git branch --list $branch_name-$merge_indicator-$test_branch` ]]; then
   echo "Branch name with $branch_name-$merge_indicator-$test_branch already exists."
   git_checkout_flag_test=""
else
   echo "No branch with name $branch_name-$merge_indicator-$test_branch, creating."
   git_checkout_flag_test=" -b"
   set_upstream_test="--set-upstream"
fi
# Checkout test merge branch
git checkout$git_checkout_flag_test $branch_name-$merge_indicator-$test_branch
git pull $REMOTE $test_branch
git merge $branch_name
if [ $SKIP_CHECKS = true ]; then
  git push --no-verify $set_upstream_test $REMOTE $branch_name-$merge_indicator-$test_branch
else
  git push $set_upstream_test $REMOTE $branch_name-$merge_indicator-$test_branch
fi
echo "---------------------------"

if [ $APPLY = true ]; then
  echo "Also merging main branch."
  echo "Returning to our feature branch."
  git checkout $branch_name
  # Determine if merge branch exists for main
  if [[ `git branch --list $branch_name-$merge_indicator-$main_branch` ]]; then
    echo "Branch name with $branch_name-$merge_indicator-$main_branch already exists."
    git_checkout_flag_main=""
  else
    echo "No branch with name $branch_name-$merge_indicator-$main_branch, creating."
    git_checkout_flag_main=" -b"
    set_upstream_test="--set-upstream"
  fi
  # Checkout main merge branch
  git checkout$git_checkout_flag_main $branch_name-$merge_indicator-$main_branch
  git pull $REMOTE $main_branch
  git merge $branch_name
  if [ $SKIP_CHECKS = true ]; then
    git push --no-verify $set_upstream_test $REMOTE $branch_name-$merge_indicator-$main_branch
  else
    git push $set_upstream_test $REMOTE $branch_name-$merge_indicator-$main_branch
  fi
  echo "---------------------------"
fi

echo "Returning to our feature branch."
git checkout $branch_name
git merge $main_branch
echo "---------------------------"
echo "ALL DONE!"

