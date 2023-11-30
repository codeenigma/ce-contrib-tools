#!/bin/bash

# Check we received a feature branch name
if [ -z "$1" ]; then
  echo "You must provide a branch name. Exiting."
  exit 1
fi

BRANCH=$1

declare -a fb_branches=(
  "_MR_test"
  "_MR_apply"
  "_PR_devel"
  "_PR_1x"
  "_PR_1.x"
  "_MR_devel"
  "_MR_1x"
  "_MR_1.x"
  "_PR_2.x"
  "_PR_devel-2.x"
  "_MR_2.x"
  "_MR_devel-2.x"
  "-MR-test"
  "-MR-apply"
  "-PR-devel"
  "-PR-1x"
  "-PR-1.x"
  "-MR-devel"
  "-MR-1x"
  "-MR-1.x"
  "-PR-2.x"
  "-PR-devel-2.x"
  "-MR-2.x"
  "-MR-devel-2.x"
)

echo "NOW EXECUTING GIT COMMANDS!"
echo "---------------------------"

echo "Determining naming convention and checking out default branch."
git branch | grep -q "apply"
if [ $? -eq 0 ]; then
  git checkout apply
else
  git checkout 1.x
fi

echo "Deleting unwanted feature branches."
git branch -D ${BRANCH}
for fb in "${fb_branches[@]}"
do
  if $(git branch | grep -q "${BRANCH}${fb}"); then
    git branch -D ${BRANCH}${fb}
  fi
done

echo "Pruning the 'origin' remote."
git remote prune origin
echo "---------------------------"
echo "ALL DONE!"
