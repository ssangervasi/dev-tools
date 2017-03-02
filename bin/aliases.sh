#!/bin/bash
alias 'alias'='alias' #lol
alias '..'='cd ..'
alias 'devbin'='cd $DEV_BIN'
alias '...'='cd $DEV_WORK'
alias 'lsa'='ls -a'
alias 'lsd'='echo Lucy in the Sky with Diamonds && ls -a $DEV_WORK'

# Git
alias 'gita'='git add --all .'
alias 'gitb'='git branch -vv'
alias 'gitc'='git commit -m'
alias 'gith'='git diff --name-status'
alias 'gitg'='git log -n10 --oneline --first-parent --decorate --graph --left-right'
alias 'giti'='git add -i'
alias 'gitl'='git log --pretty=oneline --abbrev-commit -n5'
alias 'gitm'='git commit --amend'
alias 'gitn'='git checkout -b'
alias 'gitp'='git pull --ff-only'
alias 'gits'='git status -sb --ignore-submodules=dirty'

# Tree
alias 'treef'='tree . --prune -P'

# Grep processes with preferred ps args
alias 'greps'='ps -eo pid,pcpu,pmem,time,user,command | grep -E '

# Lock the screen (OSX only)
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Alias pip (Win only)
if (! which pip &> /dev/null); then
	alias 'pip'='python -m pip'
fi
