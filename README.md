# git_helper [![Maintainability](https://api.codeclimate.com/v1/badges/d53da11f17c38cc81b5b/maintainability)](https://codeclimate.com/github/emmasax4/git_helper/maintainability) ![Develop](https://github.com/emmasax4/git_helper/workflows/Develop/badge.svg)

## Gem Usage

```bash
gem install git_helper
```

Some of the commands in this gem can be used without any additional configuration. However, others utilize special GitHub or GitLab configuration. To provide access tokens for this, create a `~/.git_helper/config.yml` file. The contents should look like this:

```
:github_user:  GITHUB-USERNAME
:github_token: GITHUB-TOKEN
:gitlab_user:  GITLAB-USERNAME
:gitlab_token: GITLAB-TOKEN
```

To create or see what access tokens you have, look [here for GitHub personal access tokens](https://github.com/settings/tokens) and [here for GitLab access tokens](https://gitlab.com/profile/personal_access_tokens). You could either have one set of tokens for each computer you use, or just have one set of tokens for all computers that you rotate periodically.

Once the gem is installed, run this to view the help screen:
```bash
git-helper --help
```

To see what version of git_helper you're running, run:
```bash
git-helper --version
```

## Plugin Usage

As an additional option, you can set each of the following commands to be a git plugin, meaning you can call them in a way that feels even more git-native:

```bash
# As a Gem                            # As a Plugin
git-helper clean-branches             git clean-branches
git-helper code-request --create      git code-request --create
```

To do this, download the `plugins.zip` file in the root of this directory. Unzip and place the contents in the appropriate location:

```bash
mkdir ~/.git_helper
unzip path/to/downloaded/plugins.zip -d ~/.git_helper
```

Now, the plugins will live in `~/.git_helper/plugins/*`. Add the following line to your `~/.bash_profile`:

```
export PATH=/path/to/computer/home/.git_helper/plugins:$PATH
```

And then run `source ~/.bash_profile`.

## Alias Usage

To make the commands even shorter, I recommend setting aliases. You can either set aliases through git itself, like this (only possible if you also use the plugin option):

```bash
git config --global alias.nb new-branch
```

And then running `git nb` maps to `git new-branch`, which through the plugin, maps to `git-helper new-branch`.

Or you can set the alias through your `~/.bashrc` (which is my preferred method because it can make the command even shorter, and doesn't require the plugin usage). To do this, add lines like this to the `~/.bashrc` file and run `source ~/.bashrc`:

```bash
alias gnb="git new-branch"
```

And then, running `gnb` maps to `git new-branch`, which again routes to `git-helper new-branch`.

For a full list of the git aliases I prefer to use, check out my [Git Aliases gist](https://gist.github.com/emmasax4/e8744fe253fba1f00a621c01a2bf68f5).

If you're going to make using git workflows easier, might as well provide lots of options 😃.

## Commands

### `change-remote`

This can be used when switching the owners of a GitHub repo. When you switch a username, GitHub only makes some changes for you. With this command, you no longer have to manually walk through local repo and switch the remotes from each one into a remote with the new username.

This command will go through every directory in a directory, and see if it is a git directory. It will then ask the user if they wish to process the git directory in question. The command does not yet know if there's any changes to be made. If the user says 'yes', then it will check to see if the old username is included in the remote URL of that git directory. If it is, then the command will change the remote URL to instead point to the new username's remote URL. To run the command, run:

```bash
git-helper change-remote OLD-OWNER NEW-OWNER
```

### `checkout-default`

This command will check out the default branch of whatever repository you're currently in. It looks at what branch the `origin/HEAD` remote is pointed to on your local machine, versus querying GitHub/GitLab for that, so if your local machine's remotes aren't up to date, then this command won't work as expected. To run this command, run:

```bash
git-helper checkout-default
```

If your local branches aren't right (run `git branch --remote` to see), then run:

```bash
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/CORRECT-DEFAULT-BRANCH-GOES-HERE
```

### `clean-branches`

This command will bring you to the repository's default branch, `git pull`, `git fetch -p`, and will clean up your local branches on your machine by seeing which ones are existing on the remote, and updating yours accordingly. To clean your local branches, run:

```bash
git-helper clean-branches
```

### `code-request`

This command can be used to handily make new GitHub/GitLab pull/merge requests and to merge those requests from the command line. The command uses either the [`Octokit::Client`](https://octokit.github.io/octokit.rb/Octokit/Client.html) or [`Gitlab` client](https://github.com/NARKOZ/gitlab) to do this, so make sure you have a `~/.git_helper/config.yml` file set up in the home directory of your computer. For instructions on how to do that, see [Gem Usage](#gem-usage).

After setup is complete, you can call the file, and send in a flag indicating whether to create a code request, `-c`, or to merge a code request, `-m`.

```bash
git-helper code-request -c
# OR
git-helper code-request -m
```

If you're trying to create a code request, the command will provide an autogenerated code request title based on your branch name. It will separate the branch name by `'_'` if underscores are in the branch, or `'-'` if dashes are present. Then it will join the list of words together by spaces. If there's a pattern in the form of `jira-123` or `jira_123` in the first part of the branch name, then it'll add `JIRA-123` to the first part of the code request. You can respond 'yes' or 'no'. If you respond 'no', you can provide your own code request title.

The command will also ask you if the default branch of the repository is the proper base branch to use. You can say 'yes' or 'no'. If you respond 'no', then you can give the command your chosen base base.

Lastly, for GitHub, it'll ask the user to apply any code request templates found at any `*/pull_request_template.md` file or any file in `.github/PULL_REQUEST_TEMPLATE/*.md`. Applying any template is optional, and a user can make an empty pull request if they desire. For GitLab, it'll ask the user to apply any merge request templates found at any `*/merge_request_template.md` file or any file in `.gitlab/merge_request_templates/*.md`. Applying any template is optional, and from the command's standpoint, a user can make an empty merge request if they desire. If a GitLab project automatically adds a template, then it may create a merge request with a default template anyway.

If you're requesting to merge a code request, the command will ask you the number ID of the code request you wish to merge. For GitHub, the command will also ask you what type of merge to do: regular merging, squashing, or rebasing. The commit message to use during the merge/squash/rebase will be the title of the pull request. For GitLab, the command will also ask you what type of merge to do: regular merging or squashing. The commit message to use during the merge/squash will be the title of the merge request.

If you're getting stuck, you can run the command with a `--help` flag instead, to get some more information.

### `empty-commit`

For some reason, I'm always forgetting the commands to create an empty commit. So with this command, it becomes easy. The commit message of this commit will be `'Empty commit'`. To run the command, run:

```bash
git-helper empty-commit
```

### `forget-local-commits`

This command is handy if you locally have a bunch of commits you wish to completely get rid of. This command basically does a hard reset to `origin/HEAD`. Once you forget them, they're completely gone, so run carefully. To test it out, run:

```bash
git-helper forget-local-commits
```

### `new-branch`

This command is useful for making new branches in a repository on the command line. To run the command, run:

```bash
git-helper new-branch
# OR
git-helper new-branch NEW_BRANCH_NAME
```

The command either accepts a branch name right away or it will ask you for the name of your new branch. Make sure your input does not contain any spaces or special characters.

## Contributing

To submit a feature request, bug ticket, etc, please submit an official [GitHub Issue](https://github.com/emmasax4/git_helper/issues/new).

To report any security vulnerabilities, please view this project's [Security Policy](https://github.com/emmasax4/git_helper/security/policy).

This repository does have a standard [Code of Conduct](https://github.com/emmasax4/git_helper/blob/main/.github/code_of_conduct.md).

## Releasing

To make a new release of this gem:

1. Merge the pull request via the big green button
2. Run `git tag vX.X.X` and `git push --tag`
3. Make a new release [here](https://github.com/emmasax4/git_helper/releases/new)
4. Run `gem build *.gemspec`
5. Run `gem push *.gem` to push the new gem to RubyGems
6. Run `rm *.gem` to clean up your local repository

To set up your local machine to push to RubyGems via the API, see the [RubyGems documentation](https://guides.rubygems.org/publishing/#publishing-to-rubygemsorg).
