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
    start-ssh-agent.cmd #1> Out-Null
}

# function Prompt { "Horse" }
# function prompt {
#    # The at sign creates an array in case only one history item exists.
#    $history = @(get-history)
#    if($history.Count -gt 0)
#    {
#       $lastItem = $history[$history.Count - 1]
#       $lastId = $lastItem.Id
#    }

#    $nextCommand = $lastId + 1
#    $currentDirectory = get-location
#    "PS: $nextCommand $currentDirectory >"
# }