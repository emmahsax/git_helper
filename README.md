# scripts

Various scripts that I have written to be able to do things on the command line easier.

#### `change_remote.rb`

I used this script when I switched my GitHub username from `emmasax1` to `emma-sax4`. When you switch a username, GitHub only makes some changes for you. I had to go through each repository "manually" and turn the remotes from each one into a remote with the new username.

This script will go through every directory in a directory, see if it is a git directory, and then will check to see if the old username is included in the remote URL of that git directory. If it is, then the script will change the remote URL to instead point to the new username's remote URL.

#### `prune-merged-branches`

This script, courtesy of [@nicksieger](https://github.com/nicksieger), runs on a single repository, which you should be in. Then, it will pull all of the branches that have a 'merged' status, and will delete any branches that had merged PRs at least four weeks ago.

This script is particularly nice when you're in a repository that has a ton of stale branches.

#### `new_branch.rb`

This script is useful for making new branches in a repository on the command line. I mostly use it with the base branch as `master`, but technically it'd work with any branch. To run the script, you must currently be `cd`ed into the repository on your local machine that you want to make the new branch for. Then, run:
```
/path/to/this/directory/new_branch.rb my_new_feature_branch
```

If you're getting stuck, you can run the command with a `--help` flag instead, to get some more information.

#### `pull_request.rb`

This script can be used to handily make new pull requests and to merge pull requests from the command line. The script uses the [`Octokit::Client`](https://octokit.github.io/octokit.rb/Octokit/Client.html) to do this, so make sure you have a `~/.automation/config.yml` file set up:
```
# default GitHub user
:github_user: github-user
:github_token: QPHNXYfNwA1m1LTF7c8xY8pfj5t13vzb0GkA3ZoU

# other GitHub user
:other:
  :github_user: other-github-user
  :github_token: tEBvYBpZi4OIRtS43mLpjLdR6Sp14xSbMZgBgNsv
```

Then, you can call the file, and send in a flag indicating whether to create a pull request (and then pass in the title of the PR) or to merge a pull request (and then pass in the number of the PR).
```
./pull_request.rb -c 'Title of pull request'
./pull_request.rb -m 101
```

To use the other user you have set up to merge/create, indicate that as the next flag:
```
./pull_request.rb -c 'Title of pull request' -u other
./pull_request.rb -m 101 -u other
```

NOTE: The order of the flags is _very_ important... mainly because I don't feel like making the argument parser any fancier.

If you're getting stuck, you can run the command with a `--help` flag instead, to get some more information.
