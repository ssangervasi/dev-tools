# Go
export GOROOT="$DEV_HOME/go"
add_to_path "/usr/local/go/bin" "/b/Go/bin"

# Rust Cargo -- should be in bashrc.sh?
add_to_path "$HOME/.cargo/bin"

# Haskell Stack Binaries
add_to_path "$HOME/.local/bin"

##
# These things are slow to source, so on-demand aliases
#   speed up the creation of new shells a lot.
##

##
# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_HOME/projects

#
# Venvevnenvnenvnnvnenvnnev
#

virtualenvwrapper_lazy() {
  echo 'Dang this tool is janky'
  unset virtualenvwrapper
  source /usr/local/bin/virtualenvwrapper.sh
}

virtualenvwrapper() {
  virtualenvwrapper_lazy && virtualenvwrapper $@
}

#
# Conda
#

conda() {
  conda_lazy && conda $@;
}

conda_lazy() {
  # Gotta unset up top or else we get an oroborous situation.
  unset conda
  conda_init
  if ! which &>/dev/null conda; then
    echo_error "Conda didn't slither into your path."
    return $YA_DUN_GOOFED
  fi

  echo_info "Using conda: $(which conda)"
  echo_info "    version: $(conda --version)"
}

# Generated by Miniconda3 4.6.14 installer
# I think this snakey boi does some string hacks which might polute bashrc again,
#   in which case move the new one into here.
conda_init() {
  # >>> conda init >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$(CONDA_REPORT_ERRORS=false '/miniconda3/bin/conda' shell.bash hook 2> /dev/null)"
  if [ $? -eq 0 ]; then
      \eval "$__conda_setup"
  else
      if [ -f "/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/miniconda3/etc/profile.d/conda.sh"
          CONDA_CHANGEPS1=false conda activate base
      else
          \export PATH="/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda init <<<
}

##
# Ruby

#
# rbenv
#

rbenv_lazy() {
  if ! which rbenv &>/dev/null; then
    echo_error "You ain't got no rbenv"
    return $YA_DUN_GOOFED
  fi
  if [[ $(type -t rbenv) != 'function' ]]; then
    return 0
  fi
  unset rbenv
  eval "$(rbenv init -)"
  echo_info "Using rbenv:" $(which rbenv)
  return 0
}

rbenv() {
  rbenv_lazy && rbenv
}

#
# RVM
#

rvm_lazy() {
  local rvm_dir="$HOME/.rvm"
  if [[ ! -s "$rvm_dir/scripts/rvm" ]]; then
    echo_error "You ain't got no rvm"
    return $YA_DUN_GOOFED
  fi
  if [[ $(type -t rvm) != 'function' ]]; then
    return 0
  fi
  unset rvm
  export PATH="$PATH:$rvm_dir/bin"
  source "$HOME/.rvm/scripts/rvm"
  echo_info "Using rvm:" $(which rvm)
  return 0
}

rvm() {
  rvm_lazy && rvm $@;
}

#
# bundler
#

bundle_lazy() {
  futility_log 'bundle_lazy'

  if [[ $(type -t bundle) != 'function' ]]; then
    return 0
  fi
  unset bundle
  rvm_lazy || rbenv_lazy
  if [[ $? > 0 ]]; then
    echo_error 'Could find ruby environment for bundler'
    return $YA_DUN_GOOFED
  fi
  echo_info 'Using bundler:' $(which bundler)
  load_ruby_speccial_plugin
  return 0
}

bundle() {
  bundle_lazy && bundle $@
}

futility_log "it's defined"

##
# JS

#
# NVM
#

nvm() {
  nvm_lazy && nvm $@
}

nvm_lazy() {
  if [[ -n $NVM_DIR ]]; then
    echo_info "Uh, $NVM_DIR is already set. I think we're done here."
    stacktrace
    return 0
  fi
  export NVM_DIR="$HOME/.nvm"
  unset nvm

  # This loads nvm
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  fi
  # This loads nvm bash_completion
  if [[ -s "$NVM_DIR/bash_completion" ]]; then
    source "$NVM_DIR/bash_completion"
  fi

  if [[ -z $(type -t nvm) ]]; then
    echo_error "NVM decided to NeVerMind you. You should be Not Very Mad."
    return $YA_DUN_GOOFED
  fi
  echo_info "Using nvm node: $(nvm current)"
  # Use the current dirs environment, if any.
  nvm use &> /dev/null
}
