#!/bin/bash

while [[ $# -gt 0 ]]
do
    key="$1" 
    case $key in
        -b |--branches )
            BRANCHES="$2"
            shift # past argument
            shift # past value
            ;;
        -d |--diff )
            DIFF="$2"
            shift # past argument
            shift # past value
            ;;
        -c |--comment )
            COMMENT="$2"
            shift # past argument
            shift # past value
            ;;

        *)
            echo "unknown option"
            break # unknown option
            ;;
    esac
done

switch_branches () {
    if [ "$BRANCHES"  == "" ] || [ "$DIFF" == "" ] || [ "$COMMENT" == "" ]
    then
        echo "Error: Missing properties"
        return 0 
    fi
    for branch in $(cat < "${BRANCHES}") 
    do
        echo "branch: $branch"
        git checkout -b $branch origin/$branch
        if (( $? == 128 ))
        then
            git checkout $branch
            if (( $? == 0 ))
            then
                apply_changes
                if (( !$? ))
                then
                    return 0
                fi
            else
                echo "Error: wrong branch"
                return 0
            fi
        else
            apply_changes
            if (( !$? ))
            then
                return 0
            fi
        fi
    done
}

apply_changes() {
    cd ../
    git apply --cached $DIFF
    git apply $DIFF
    if (( $? == 0))
    then
        #git commit -F $COMMENT
        if (( $? ==  0 ))
        then
            # git push
            return 1
        fi
    fi
    return 0
}
switch_branches
