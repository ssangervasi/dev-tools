#!/bin/bash
default() {
    defval=''
    for val in "$@"
    do
        test $val && defval=$val && break;
    done
    echo $defval
}

src() {
    if [ ! "$1" ]; then
        source $DEV_BIN"/.bash_profile";
        return 0;
    fi
    osx_activate='bin/activate'
    win_activate='Scripts/activate'
    venvs=$(default $VENVS '~/.venvs')
    activate=$venvs/$1/$osx_activate
    if (! test -e $activate); then
        activate=$venvs/$1/$win_activate;
    fi
    source $activate
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

rmcache() {
    find . -name '.cache' -or -name '*.pyc' -delete
}

mvsed() {
    for filename in $(ls -1 $1)
    do
        sed_filename=$(echo $filename | sed -E "$2");
        if [ "$filename" != "$sed_filename" -a "$sed_filename" != "" ]
        then
            echo "$filename --> $sed_filename";
            mv $1/$filename $1/$sed_filename;
        fi
    done
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

# Python is silly too
mkpy() {
    test $1 && mkdir -p $1
    target_dir=$(default $1 '.')
    touch $target_dir/__init__.py
}
