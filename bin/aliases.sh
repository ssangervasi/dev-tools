#!/bin/bash
alias '..'="cd .."
alias '...'="cd ~/Documents/workspace"
alias 'resource'='. resource'

# Network
alias 'shacme'='ssh seb@acme.ditto.com'

# Git
alias 'gits'='git status -sb'
alias 'gith'='git diff --name-status'
alias 'giti'='git add -i'
alias 'gitl'='git log --pretty=oneline --abbrev-commit -n5'

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
