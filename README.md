# ce-contrib-tools
Scripts and tools to help contributing to ce-provision, ce-deploy and ce-dev.

There are three scripts in this repository to make feature branching and managing your local Git repository easier. They are:

* prepare_branch.sh - creates a feature branch from the default branch
* commit.sh - prepares and pushes merge branches
* remove_branches.sh - deletes trailing feature and merge branches in your local project

# Installation
Clone the Git repo to `/opt` on your computer and make the scripts executable:

```bash
cd /opt && sudo git clone https://github.com/codeenigma/ce-contrib-tools.git
sudo chmod +x /opt/ce-contrib-tools/*
```

Create links to the scripts in `/usr/local/bin` so they are available in `PATH`:

```bash
cd /usr/local/bin
sudo ln -s /opt/ce-contrib-tools/prepare_branch.sh prepare_branch
sudo ln -s /opt/ce-contrib-tools/commit.sh commit
sudo ln -s /opt/ce-contrib-tools/remove_branches.sh remove_branches
```

# prepare_branch
This takes one argument, the name of the feature branch you want to create.

## Usage
* Go to the repo you want to work in
* Execute the `prepare_branch` command with a sensible branch name, e.g. `prepare_branch my_new_feature`

This will switch to the default branch, ensure it is up to date with the central repo, checkout the feature branch and ensure it is up to date with the default branch. Note the command can also be used to refresh an existing feature branch. If the specified feature branche exists already the script will simply re-merge the default branch so it has the latest default branch code merged in.

# commit
This has one optional argument, the keyword `apply`, which causes the preparation of a branch to merge into the default branch. If you run `commit` on its own then it will only prepare a branch to merge to the development branch (usually `devel`).

## Usage
* Go to the repo you want to work in
* Check out your feature branch, e.g. `git checkout my_new_feature`
* Work on your feature
* Add and commit your changes, e.g. `git add . && git commit -m "Adding my new feature."`
* Execute the `commit` command - without the `apply` argument it will only create a development PR branch

This will checkout and pull the development branch and the default branch in turn, to ensure they are up to date locally then, if it doesn't exist already, it will create a PR branch for merging to the development branch, e.g. `my_new_feature-PR-devel`. It will then merge `devel` into that branch, then it will merge `my_new_feature` into that branch. Finally, it will push the branch up, at which point you can go off to GitHub or GitLab and create your pull request. If you use the `apply` keyword as well, e.g. `commit apply`, then it will do the same steps for the default `1.x` branch, so  you finish with a `my_new_feature-PR-1.x` branch in GitHub ready to create a PR.

# remove_branches
This takes one argument, the name of the feature branch you want to delete.

## Usage
* Go to the repo you want to work in
* Execute the `remove_branches` command with the name of the feature branch you are finished with and want to delete, e.g. `remove_branches my_new_feature`

This will attempt to delete the following local branches:
* `my_new_feature`
* `my_new_feature-PR-devel`
* `my_new_feature-PR-1.x`

It will then execute a `git prune` to update the `origin` remote's local cache.
