#!/bin/bash
src() {
    if [ "$1" ]; then
        source ~/.venvs/$1/bin/activate
    else 
        source ~/.bash_profile;
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

count() {
    what=$(default $1 '.')
    where=$(default $2 '.')
    ls -1 $where | grep $what --count
}

tabname() {
    echo -ne "\033]0;$*\007"   
}

cls() {
    clear
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
    find . -name '.cache' | xargs rm -r
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
