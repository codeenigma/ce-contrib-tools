#!/bin/bash
# Script to prepare a working feature branch
set -e

usage(){
  echo 'remove_branches.sh [OPTIONS]'
  echo 'Remove feature branches and clean up remotes.'
  echo ''
  echo 'Available options:'
  echo '--name: Name of the feature branch to remove'
  echo '--default: Name of the default branch, 1.x, 2.x, apply, etc.'
  echo '--remote: Defaults to origin, allows you to set an alternative remote name'
}

# Set defaults
REMOTE="origin"
DEFAULT="1.x"
DEVEL_DEFAULT="devel"

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--name")
          shift
          BRANCH="$1"
        ;;
      "--default")
          shift
          DEFAULT="$1"
	  DEVEL_DEFAULT="devel-$1"
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
if [ -z "$BRANCH" ]; then
  echo "You must provide a branch name. Exiting."
  exit 1
fi

echo "NOW EXECUTING GIT COMMANDS!"
echo "---------------------------"

echo "Determining naming convention and checking out default branch."
# Fetch branches
git_branches=`git branch`

# Determine naming convention applied
if [[ $git_branches == *"$DEFAULT"* ]]; then
  echo "Using devel/$DEFAULT naming convention."
elif [[ $git_branches == *"apply"* ]]; then
  echo "Using apply/test naming convention."
  DEFAULT="apply"
  DEVEL_DEFAULT="test"
else
  echo "Unable to determine the default branch name. Exiting."
  exit 1
fi

git checkout $DEFAULT

echo "Deleting unwanted feature branches."
git branch -D ${BRANCH}
declare -a fb_branches=(
  "_PR_$DEVEL_DEFAULT"
  "_PR_$DEFAULT"
  "_MR_$DEVEL_DEFAULT"
  "_MR_$DEFAULT"
  "-PR-$DEVEL_DEFAULT"
  "-PR-$DEFAULT"
  "-MR-$DEVEL_DEFAULT"
  "-MR-$DEFAULT"
)
for fb in "${fb_branches[@]}"
do
  if $(git branch | grep -q "${BRANCH}${fb}"); then
    git branch -D ${BRANCH}${fb}
  fi
done

echo "Pruning the 'origin' remote."
git remote prune origin

# If we have a different remote for SSH, prune that too
if [ -n "$REMOTE" ]; then
  echo "Pruning the '$REMOTE' remote."
  git remote prune $REMOTE
fi

echo "Putting you back on your specified default branch."
git checkout $DEFAULT

echo "---------------------------"
echo "ALL DONE!"
