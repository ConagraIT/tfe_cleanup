#!/usr/bin/env bash

TFE_ORG=Conagra
GH_ORG=ConagraIT
set +e

for WORKSPACE in $(tfh workspace list -org $TFE_ORG | grep -vf keep.txt); do
    echo
    echo "WORKSPACE: $WORKSPACE"

    # DELETE VARIABLES FIRST TO ENSURE NO DESTRUCTION OF RESOURCES HAPPENS
    # VARS=$(tfh pullvars -name $WORKSPACE -org $TFE_ORG -env true | awk -F '=' '{print$1}')
    # echo "confirm delete variables in workspace: $WORKSPACE? [yes|no]" 
    # read CONFIRM
    # if [ "$CONFIRM" == "yes" ]; then
    #     for VAR in $VARS; do
    #         # TODO: remove dry-run
    #         tfh pushvars -name $WORKSPACE -org $TFE_ORG -delete-env $VAR
    #     done
    # fi

    # DELETE WORKSPACES
    echo "confirm delete workspace: $WORKSPACE? [yes|no]" 
    read CONFIRM
    if [ "$CONFIRM" == "yes" ]; then
        echo "tfh workspace delete -name $WORKSPACE -org $TFE_ORG"
        # TODO: uncomment
        tfh workspace delete -name $WORKSPACE -org $TFE_ORG
    else
        echo "NOT RUNNING $CMD"
    fi

    # DELETE GITHUB REPO
    # See if repo already exists on github by trying to list it an looking at return code
    REPO=git@github.com:$GH_ORG/$WORKSPACE.git
    echo "checking for REPO: $REPO"
    set +e
    git ls-remote $REPO 2&>1 /dev/null
    LS_RESULT=$?
    set -e
    if [ $LS_RESULT -ne 0 ]; then
        echo "repo $REPO doesnt appear to exist"
    else
        # The repo most exist
        echo "confirm delete github repo $REPO"
        read CONFIRM
        if [ "$CONFIRM" == "yes" ]; then
            echo hub delete $REPO
            # TODO: uncomment
            hub delete -y $GH_ORG/$WORKSPACE
        else
            echo "NOT DELETEING REPO $REPO"
        fi
    fi
    echo "done with $WORKSPACE"
    echo
done
