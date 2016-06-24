#!/bin/bash
alias 'alias'='alias' #lol
alias '..'="cd .."
alias '...'="cd ~/Documents/workspace"
alias 'resource'='. resource'

# Network
alias 'shacme'='ssh seb@acme.ditto.com'

# Git
alias 'gits'='git status -sb'
alias 'gitn'='git checkout -b'
alias 'gith'='git diff --name-status'
alias 'gita'='git add --all'
alias 'giti'='git add -i'
alias 'gitm'='git commit --amend'
alias 'gitl'='git log --pretty=oneline --abbrev-commit -n5'

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
