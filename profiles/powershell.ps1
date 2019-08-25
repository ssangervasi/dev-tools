##
# Workspace!

function ... { cd $DEV_HOME }

function Welp {
    Get-Help @Args -Online
}

##
# Docker shiz
Set-Alias dc DCLazy

function  DCLazy {
    Remove-Item -Path Alias:dc
    Set-Alias dc docker-compose
    dc @Args
}

##
# SSH be like wut
function QuietlyStartSSHAgent {
    start-ssh-agent.cmd 1> $null
}