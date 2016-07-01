#!/bin/bash
alias 'alias'='alias' #lol
alias '..'="cd .."
alias '...'="cd ~/Documents/workspace"
alias 'resource'='. resource'

# Network
alias 'shacme'='ssh seb@acme.ditto.com'

# Git
alias 'gita'='git add --all'
alias 'gitc'='git commit -m'
alias 'gith'='git diff --name-status'
alias 'giti'='git add -i'
alias 'gitl'='git log --pretty=oneline --abbrev-commit -n5'
alias 'gitm'='git commit --amend'
alias 'gitn'='git checkout -b'
alias 'gitp'='git pull --ff-only'
alias 'gits'='git status -sb'

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
