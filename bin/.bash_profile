# Source this file in your actual ~/.bash_profile or ~/.bashrc

# Expose custom path
export DEV_BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="$DEV_BIN:$PATH"

if (test -z $DEV_WORK); then
    dev_osx=~/Documents/workspace
    dev_linux=~/repo
    dev_win=/b/Documents/GitHub
    for work in $dev_osx $dev_linux $dev_win $DEV_BIN; do
        echo $work
        if (test -d $work ); then
            DEV_WORK=$work
            break
        fi
    done
    export DEV_WORK
fi

# Tools
source "aliases.sh"
source "helper_functions.sh"

# Custom terminal
source "colors.sh"
changeprompt INFO

# Other tools:
if (test -d $DEV_WORK/arcanist/bin); then
    export PATH="$DEV_WORK/arcanist/bin:$PATH"
fi