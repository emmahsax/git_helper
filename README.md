# scripts

Various scripts that I have written to be able to do things on the command line easier.

### `change_remote.rb`

I used this script when I switched my GitHub username from `emmasax1` to `emma-sax4`. When you switch a username, GitHub only makes some changes for you. I had to go through each repository "manually" and turn the remotes from each one into a remote with the new username.

This script will go through every directory in a directory, see if it is a git directory, and then will check to see if the old username is included in the remote URL of that git directory. If it is, then the script will change the remote URL to instead point to the new username's remote URL.

### `prune-merged-branches`

This script, courtesy of [@nicksieger](https://github.com/nicksieger), runs on a single repository, which you should be in. Then, it will pull all of the branches that have a 'merged' status, and will delete any branches that had merged PRs at least four weeks ago.

This script is particularly nice when you're in a repository that has a ton of stale branches.
