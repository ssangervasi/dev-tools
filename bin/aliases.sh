#!/bin/bash
alias 'alias'='alias' #lol
alias '..'='cd ..'
alias 'devbin'='cd $DEV_BIN'
alias '...'='cd $DEV_WORK'

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

# Alias pip (Win only)
if (! which pip &> /dev/null); then
	alias 'pip'='python -m pip'
fi


# Acme shortcuts
alias 'shacme'='ssh seb@acme.ditto.com'
alias 'racme'=$DEV_WORK'/web/acme/manage.py runserver --settings=acme.test_settings'