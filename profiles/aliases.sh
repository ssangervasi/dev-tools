##
# Aliases
##

# Handydandy
alias resource='source $HOME/.bashrc $HOME/.bash_profile'
alias '...'='cd $PROJECT_HOME'
alias ',,,'="cd ~/workspace"
alias tree='tree -C'
alias binweb='./bin/web'
alias ct='change_theme'

# Ruby & Rails
alias beer='bundle exec rake'
alias beer-taste='RAILS_ENV=test beer'
alias bier='bundle exec rails'
alias berps='spec'
alias belch='bundle exec spring rspec'
alias bemigrate='bundle install && beer db:migrate && beer-taste db:migrate'

# Git
alias gita="git a"
alias gitb="git b"
alias gitl="git l"
alias gits="git s"
alias hamster='git hamster'
alias gitcd='cd $(git root-dir)'
