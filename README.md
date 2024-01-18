# ce-contrib-tools
Scripts and tools to help contributing to ce-provision, ce-deploy and ce-dev.

There are three scripts in this repository to make feature branching and managing your local Git repository easier. They are:

* prepare_branch.sh - creates a feature branch from the default branch
* commit.sh - prepares and pushes merge branches
* remove_branches.sh - deletes trailing feature and merge branches in your local project

# Installation
Clone the Git repo to `/opt` on your computer and make the scripts executable:

```bash
sudo git clone https://github.com/codeenigma/ce-contrib-tools.git /opt/ce-contrib-tools/
sudo chmod +x /opt/ce-contrib-tools/*.sh
```

Create links to the scripts in `/usr/local/bin` so they are available in `PATH`:

```bash
sudo ln -s /opt/ce-contrib-tools/prepare_branch.sh /usr/local/bin/prepare_branch
sudo ln -s /opt/ce-contrib-tools/commit.sh /usr/local/bin/commit
sudo ln -s /opt/ce-contrib-tools/remove_branches.sh /usr/local/bin/remove_branches
```

# prepare_branch
This takes three arguments, the name of the feature branch you want to create, the name of the remote to fetch branches from (defaults to `origin`) and the default branch to fork from (defaults to `1.x`).

## Usage
* Go to the repo you want to work in
* Execute the `prepare_branch` command with a sensible branch name, e.g. `prepare_branch --name my_new_feature`

This will switch to the default branch, ensure it is up to date with the central repo, checkout the feature branch and ensure it is up to date with the default branch. Note the command can also be used to refresh an existing feature branch. If the specified feature branche exists already the script will simply re-merge the default branch so it has the latest default branch code merged in.

To use a remote other than `origin` do something like this:

* `prepare_branch --name my_new_feature --origin my-fork`

If you want to use another live branch, for example `2.x`, then you can do something like this:

* `prepare_branch --name my_new_feature --default 2.x`

# commit
This has four optional arguments:

* `--apply` - causes the preparation of a branch to merge into the default branch
* `--default` - as with `prepare_branch`, allows you to set the default branch you're working from, defaulting to `1.x` - note, it will also set the `devel` branch to `devel-$TARGET_BRANCH` so assumes both exist - e.g. `--default 2.x` will set the default branch to `2.x` and the development branch to `devel-2.x`
* `--remote` - allows you to specify a remote other than `origin`, e.g. `--remote my-fork`
* `--skip-checks` - prevents Git from running local hooks

If you run `commit` on its own then it will only prepare a branch to merge to the development branch (defaulting to `devel`) and it will assume the remote name is `origin` and the development branch is `devel`.

## Usage
* Go to the repo you want to work in
* Check out your feature branch, e.g. `git checkout my_new_feature` or, better yet, use the `prepare_branch` command
* Work on your feature
* Add and commit your changes, e.g. `git add . && git commit -m "Adding my new feature."`
* Execute the `commit` command - without the `--apply` option it will only create a development PR branch

This will checkout and pull the development branch and the default branch in turn, to ensure they are up to date locally then, if it doesn't exist already, it will create a PR branch for merging to the development branch, e.g. `my_new_feature-PR-devel`. It will then merge `devel` into that branch, then it will merge `my_new_feature` into that branch. Finally, it will push the branch up, at which point you can go off to GitHub or GitLab and create your pull request. If you use the `--apply` option as well, e.g. `commit --apply`, then it will do the same steps for the default `1.x` branch, so  you finish with a `my_new_feature-PR-1.x` branch in GitHub ready to create a PR.

If for any reason your target remote for merges is not `origin` then you can specify a remote, e.g. `commit --apply --remote my-fork`.

If your default branch is not `1.x` then you can specify a different one, e.g. `commit --apply --default 2.x`. This will create feature branches for `2.x` and `devel-2.x` instead of the defaults.

# remove_branches
As with `prepare_branch`, this takes three arguments, the name of the feature branch you want to destroy, the name of the remote to prune from (defaults to `origin`) and the default branch to search for local merge branches (defaults to `1.x`).

## Usage
* Go to the repo you want to work in
* Execute the `remove_branches` command with the name of the feature branch you are finished with and want to delete, e.g. `remove_branches --name my_new_feature`

This will attempt to delete the feature branch and an array of possible local merge branches, which you can see in the code where we declare the variable `fb_branches`.

It will then execute a `git prune` to update the `origin` remote's local cache. If your remote is not called `origin` you can set another remote with `--remote`. Similarly, if your default branch is not `1.x` you can specify another with `--default`, just as you can with `prepare_branch`.

