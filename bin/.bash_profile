# Source this file in your actual ~/.bash_profile or ~/.bashrc

# Expose custom path
export DEV_BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="$DEV_BIN:$PATH"

if [ ! -d '$DEV_WORK' ]; then
    dev_envs="workspace Documents/workspace repo"
    for work in $dev_envs; do
        if [ -d ~/$work ]; then
            export DEV_WORK=~/$work
            break
        fi
    done
fi

# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_WORK/projects
source /usr/local/bin/virtualenvwrapper.sh

# Go
export GOROOT=$DEV_WORK/go

# Tools
source "aliases.sh"
source "helper_functions.sh"

# Custom terminal
source "colors.sh"
changeprompt INFO

# Other tools:
add_to_path="$DEV_WORK/arcanist/bin
             /usr/local/go/bin
             /b/Go/bin"
for path_dir in $add_to_path; do
    if (test -d $path_dir); then
        export PATH=$path_dir":"$PATH
    fi
done