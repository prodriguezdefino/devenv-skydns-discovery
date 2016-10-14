#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# add alias for the dev env
alias devenv='sh $DIR/devenv.sh'

case "$1" in
    down)
        source internal/devenv-down.sh
        ;;
    reload)
        source internal/devenv-reload-containers.sh
        ;;
    logs)
        source internal/devenv-logs.sh "$2"
        ;;
    status)
        source internal/devenv-status.sh "$2"
        ;;
    up)
        source internal/devenv-up.sh
        ;;
    inspect)
        source internal/devenv-inspect.sh "$2"
        ;;
    stop)
        source internal/devenv-stop.sh "$2"
        ;;
    remove)
        source internal/devenv-remove.sh "$2"
        ;;
    run)
        runparam=""
        for var in ${@:2}
        do
            runparam="$runparam $var"
        done
        source internal/devenv-run.sh "$runparam" 
        ;;
     
    *)
        echo $"Usage: $0 {down|reload|logs <container>|up|inspect <container>|status <-a>|run <parameters>|remove <container>|stop <container>}"
        exit 1
esac