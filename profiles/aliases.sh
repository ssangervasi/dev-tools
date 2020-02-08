##
# Aliases
##

# Handydandy
alias resource='source $HOME/.bashrc $HOME/.bash_profile'
alias '..'='cd ..'
alias '...'='cd $DEV_HOME'
alias ',,,'='cd $WORKSPACE'

export TREE_DEFAULT_OPTIONS='--dirsfirst -C'
alias tree='tree ${TREE_DEFAULT_OPTIONS}'

alias tt='term-theme'
alias 'pgrep'='pgrep -lfi'
alias lsa='ls -A1lh'

# Originally for Rails, but made more generic.
alias taste='RAILS_ENV=test RACK_ENV=test FLASK_ENV=test'

# Ruby & Rails
alias be='bundle exec'
alias beer='bundle exec rake'
alias bier='bundle exec rails'
alias berps='spec'
alias belch='bundle exec spring rspec'
alias bemigrate='bundle install && beer db:migrate && taste beer db:migrate'

# Git
alias gita="git a"
alias gitb="git b"
alias gitc="git c"
alias gitl="git l"
alias gits="git s"
alias hamster='git hamster'

# Screensaver
if [[ $(uname -s 2>/dev/null) == 'Darwin' ]]; then
	# Lock the screen (OSX only)
	MAC_OS_LOCK_SCREEN='/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession'
	if [[ -f $MAC_OS_LOCK_SCREEN ]]; then
		alias 'afk'="'${MAC_OS_LOCK_SCREEN}' -suspend"
		alias 'screensave'="'/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'"
	fi
fi

# Alias pip (Win only)
# if (! which pip &> /dev/null); then
# 	alias 'pip'='python -m pip'
# fi
