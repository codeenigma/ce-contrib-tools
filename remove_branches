#!/bin/bash

BRANCH=$1

declare -a fb_branches=("_MR_test" "_MR_apply" "_PR_devel" "_PR_1x" "_PR_1.x" "_MR_devel" "_MR_1x" "_MR_1.x" "-MR-test" "-MR-apply" "-PR-devel" "-PR-1x" "-PR-1.x" "-MR-devel" "-MR-1x" "-MR-1.x")

git branch | grep -q "apply"
if [ $? -eq 0 ]; then
  git checkout apply
else
  git checkout 1.x
fi

git branch -D ${BRANCH}
for fb in "${fb_branches[@]}"
do
  if $(git branch | grep -q "${BRANCH}${fb}"); then
    git branch -D ${BRANCH}${fb}
  fi
done
