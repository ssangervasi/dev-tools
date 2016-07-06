#!/bin/bash
alias 'alias'='alias' #lol
alias '..'='cd ..'

# Get ... to work on my different machines
work_osx='~/Documents/workspace'
work_win='/b/Documents/GitHub'
if (test -d $work_osx ); then
	alias '...'='cd '$work_osx;
elif (test -d $work_win ); then
	alias '...'='cd '$work_win;
else
	alias '...'='cd $DEV_BIN'
fi

# Network
alias 'shacme'='ssh seb@acme.ditto.com'

# Git
alias 'gita'='git add --all'
alias 'gitc'='git commit -m'
alias 'gith'='git diff --name-status'
alias 'gitg'='git log -n10 --oneline --first-parent --decorate --left-right'
alias 'giti'='git add -i'
alias 'gitl'='git log --pretty=oneline --abbrev-commit -n5'
alias 'gitm'='git commit --amend'
alias 'gitn'='git checkout -b'
alias 'gitp'='git pull --ff-only'
alias 'gits'='git status -sb'

# Lock the screen (OSX only)
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Alias pip (for windows)
if (! which pip &> /dev/null); then
	alias 'pip'='python -m pip'
fi