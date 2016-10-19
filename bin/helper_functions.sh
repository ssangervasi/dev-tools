#!/bin/bash
src() {
    if [ "$1" ]; then
        source ~/.venvs/$1/bin/activate;
    else
        source $DEV_BIN"/.bash_profile";
    fi
}

default() {
    defval=''
    for val in "$@"
    do
        test $val && defval=$val && break;
    done
    echo $defval
}

checktime() {
    export CHECK_SECONDS=$((SECONDS-CHECK_SECONDS))
    export ELAPSED=$((CHECK_SECONDS/60)):$((CHECK_SECONDS%60))
    export CHECK_SECONDS=$SECONDS
}

changeprompt() {
    simple_prompt='\$ '
    timer_prompt='$ELAPSED\$ '
    info_prompt='\A:\u:\W\$ '
    export PROMPT_COMMAND=''
    case $1 in
        INFO)
            export PS1=$info_prompt
            ;;
        TIMER)
            export PROMPT_COMMAND=checktime
            export PS1=$timer_prompt
            ;;
        SIMPLE)
            PS1=$simple_prompt
            ;;
        *)
            PS1=$(default $1 $simple_prompt)
    esac
}

count() {
    what=$(default $1 '.')
    where=$(default $2 '.')
    ls -1 $where | grep $what --count
}

tabname() {
    echo -ne "\033]0;$*\007"
}

cls() {
    cd_to=$(default $1 '.')
    cd $cd_to
    clear
    pwd
    ls
}

gcd() {
    nav_dir=$(pwd)
    while [[ ! -d $nav_dir/.git && ! $nav_dir -ef $HOME && ! $nav_dir -ef / ]]
    do
        nav_dir=$nav_dir/..
    done
    cd $nav_dir/$1
}

gitco() {
    # Try and checkout a branch from a remote.
    # If it already exists, just check it out.
    local branch=$(default $1 'master')
    local remote_branch=$(default $2 $branch)
    local remote=$(default $3 'origin')
    git checkout --track $remote/$remote_branch -b $branch || git checkout $branch
}
gitnew() {
    local branch=$(default $1 'master')
    local remote_branch=$(default $2 $branch)
    local remote=$(default $2 'origin')
    git checkout -b $branch
    git push --set-upstream $remote $branch:$remote_branch
}

space2csv() {
    echo "$@" | sed 's/[ \n\t]\+/,/g'
}

whereami() {
    echo $PWD
}

howami() {
    echo "I'm looking nice.
    My shadow's looking nice.
        We're a real nice team!"

}

whatami() {
    echo "A man, or a mouse."
}

whyami() {
    echo "You pass butter."
}

whenami() {
    date;
}

rmcache() {
    find . -name '.cache' -or -name '*.pyc' -delete
}

mvsed() {
    for filename in $(ls -1 $1)
    do
        sed_filename=$(echo $filename | sed -E "$2");
        if [ "$filename" != "$sed_filename" -a "$sed_filename" != "" ]; then
            echo "$filename --> $sed_filename";
            mv $1/$filename $1/$sed_filename;
        fi
    done
}


vag() {
    vag_dir=$DEV_WORK/$(default $1 'web')/vagrant
    cd $vag_dir
    vagrant up && vagrant ssh
}

sublime() {
    echo ">>> Opening sublime with args: $@"
    touch $@
    sublime_app="Sublime Text"
    echo $sublime_app
    open -a "$sublime_app" $@
    echo ">>> $sublime_app running in background"
}

slackpost() {
    SLACK_MESSAGE=$@;
    test ! SLACK_WEBHOOK_URL && echo 'No SLACK_WEBHOOK_URL set!' && return 1
    SLACK_CHANNEL=$(default $SLACK_CHANNEL "@slackbot")
    SLACK_BOTNAME=$(default $SLACK_BOTNAME "HookBot")

    SLACK_PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${SLACK_MESSAGE}\", \"icon_emoji\": \":warning:\"}"
    echo "Posting to slack: " $SLACK_PAYLOAD

    curl -s -S -X POST --data-urlencode "$SLACK_PAYLOAD" "$SLACK_WEBHOOK_URL"
}

# Java is silly.
jcr() {
    rootdir=$(default $1 '.')
    find $rootdir -name '*.java' | xargs javac
    test $2 && java $2
}

source pypackage.sh
source ssh_bash_profile.sh