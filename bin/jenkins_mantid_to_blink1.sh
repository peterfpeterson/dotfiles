#!/bin/bash
### VARIABLES ###
# Frequency, in seconds, to poll for project status.
# Probably best not to set this to too small an interval.
POLL_FREQUENCY=60

# Path to blink-tool(1)
BLINK1_TOOL="`which blink1-tool`"
BLINK2_TOOL="`which blink2-tool`"

# URL of mantid jenkins
BUILD_URL="http://builds.mantidproject.org/job/"
# URL of git project
GIT_URL="https://api.github.com/repos/"
REPO_DESCR="mantidproject/mantid/"

# Build to monitor
PROJECT="master_clean"
PROJECT2="master_incremental"

COLOR_GREEN="0,255,0"
COLOR_RED="255,0,0"
COLOR_YELLOW="255,220,0"
COLOR_BLUE="0,0,255"
COLOR_GREEN_BUILDING="0,100,0"
COLOR_RED_BUILDING="100,0,0"
COLOR_YELLOW_BUILDING="100,90,0"
COLOR_BLUE_BUILDING="0,0,100"
COLOR_ERROR="255,255,255" # White
COLOR_ABORTED="200,200,200" # light grey
COLOR_ABORTED="100,100,100" # light grey

### FUNCTIONS ###

# Set the Blink(1) to a color in "R,G,B" format, which must be supplied
# as an argument.
function set_blink1_color
{
    $BLINK1_TOOL --rgb ${1} --led ${2} > /dev/null 2>&1
}

# return the string to pass for information about blinking to blink2-tool
function get_blink
{
    if [ $BLINK2_TOOL ]; then
        if [[ "$1" == *_anime ]]; then
            if [[ "$2" == *_anime ]]; then
                echo "-b both -n $POLL_FREQUENCY"
            else
                echo "-b 1 -n $POLL_FREQUENCY"
            fi
        elif [[ $2 == *_anime ]]; then
            echo "-b 2 -n $POLL_FREQUENCY"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

function get_github_oauth_token
{
    if [ -n "${1}" ]; then
        token=${1}
    elif [ -f ${HOME}/.ssh/github_oauth ]; then
        token=$(cat ${HOME}/.ssh/github_oauth)
    fi

    if [ ${token} ]; then
        echo "?access_token=${token}"
    else
        echo ""
    fi
}

function print_pr_details
{
    pr=${1}
    number=$(echo ${pr} | jq '.number' -M -a)
    state=$(echo ${pr} | jq '.state' -M -a | sed -s 's/\"//g')
    if [ $(echo ${pr} | jq '.merged' -M -a) == "true" ]; then
        state="${state}/merged"
    else
        state="${state}/unmerged"
    fi

    status=$(echo ${2} | jq '.state' -M -a| sed -s 's/\"//g')
    details=$(echo ${2} | jq '.statuses[] | [.context + ": " + .state]' -M -a)
    details=$(echo ${details} | sed -s 's/\"//g')

    echo "pr${number} ${state}/${status} ${details}"

    return
}

function get_pr_status
{
    status=$(echo ${1} | jq '.state' -M | sed -s 's/\"//g')
    if [ "${status}" == "failure" ]; then
        echo "red"
    elif [ "${status}" == "pending" ]; then
        echo "yellow"
    elif [ "${status}" == "success" ]; then
        echo "blue"
    else
        echo "error"
    fi
}

function get_color
{
    COLOR=$(echo $1 | sed -e 's,<color>,,' -e 's,</color>,,')
    if [ $BLINK2_TOOL ]; then
        COLOR=$(echo $1 | sed 's,_anime,,g')
    fi

    if [ "${COLOR}" == "blue" ]; then
       echo ${COLOR_BLUE}
    elif [ "${COLOR}" == "yellow" ]; then
       echo ${COLOR_YELLOW}
    elif [ "${COLOR}" == "red" ]; then
       echo ${COLOR_RED}
    elif [ "${COLOR}" == "green" ]; then
       echo ${COLOR_GREEN}
   elif [ "${COLOR}" == "aborted" ]; then
       echo ${COLOR_ABORTED}
    elif [ "${COLOR}" == "blue_anime" ]; then
       echo ${COLOR_BLUE_BUILDING}
    elif [ "${COLOR}" == "yellow_anime" ]; then
       echo ${COLOR_YELLOW_BUILDING}
    elif [ "${COLOR}" == "red_anime" ]; then
       echo ${COLOR_RED_BUILDING}
    elif [ "${COLOR}" == "aborted_anime" ]; then
       echo ${COLOR_ABORTED_BUILDING}
    else
       echo ${COLOR_ERROR}
    fi
}

# Used with trap to shut off the Blink(1) when we get a SIGINT or SIGTERM.
function cleanup
{
    # Turn the Blink(1) off
    if [ $TWO ]; then
        $BLINK1_TOOL -l $LED1 --off > /dev/null 2>&1
        $BLINK1_TOOL -l $LED2 --off > /dev/null 2>&1
    else
        $BLINK1_TOOL --off > /dev/null 2>&1
    fi
    exit $?
}


# Show usage instructions
function show_usage
{
    echo " Usage: `basename ${0}` [OPTIONS] <project> [project2]"
    echo ""
    echo " Options:"
    echo "    -h              Displays this help"
    echo "    -t <seconds>    Polling interval in seconds (default: ${POLL_FREQUENCY} s.)"
    echo "    -p <pr>         Pull request number to watch. Will always be on led 1."
    echo "    -a <token>      GitHub oauth token if needed"
    echo ""
    echo " <project> should be in the form job[/label=<build>] (default: ${PROJECT})"
    echo " Two projects can be specified, each controlling a different LED. "
    echo ""
    echo "The authorization token will also be looked for in ~/.ssh/github_oauth. See"
    echo "https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization"
    echo "for details on creating a new token."
    echo ""
}

### SETUP ###
# Get command line options
while getopts "ht:b:p:a:" OPTION
do
    case $OPTION in
        h)
            show_usage
            exit 0
            ;;
        t)
            POLL_FREQUENCY=$OPTARG
            ;;
        p)
            PULL_REQ=$OPTARG
            ;;
        a)
            TOKEN=$OPTARG
            ;;
        ?)
            show_usage
            exit 1
            ;;
    esac
done

# Get project
shift $(($OPTIND - 1))
if [ $1 ]; then
    PROJECT=$1
fi

if [ $2 ]; then
    PROJECT2=$2
fi
if [ $PROJECT2 ]; then
    TWO=true
fi
if [ $PULL_REQ ]; then
    PROJECT="pull/${PULL_REQ}"
fi

# Turn off the Blink(1) on SIGINT or SIGTERM
trap cleanup SIGINT SIGTERM

### MAIN ###
# In an infinite loop, poll the project and update the Blink(1) color.
if [ $TWO ]; then
    echo "Monitoring ${PROJECT} and ${PROJECT2}. CTRL-C to exit."
else
    echo "Monitoring ${PROJECT}. CTRL-C to exit."
fi
GITHUB_ACCESS_TOKEN=$(get_github_oauth_token ${TOKEN})

while true; do
    if [ -z "$PULL_REQ" ]; then
        STATUS=$(curl -f -s "${BUILD_URL}${PROJECT}/api/xml?xpath=/*/color")
        STATUS=$(echo $STATUS | sed -e 's,<color>,,' -e 's,</color>,,')
    else
        STATUS=$(curl -f -s ${GIT_URL}${REPO_DESCR}pulls/${PULL_REQ}${GITHUB_ACCESS_TOKEN})
        # echo "${STATUS}"
        if [ -z "${STATUS}" ]; then
            STATUS="error"
        elif [ $(echo ${STATUS} | jq '.state' | sed -s 's/\"//g') == "closed" ]; then
            print_pr_details "${STATUS}" ""
            STATUS="green"
        else
            sha=$(echo ${STATUS} | jq '.head.sha' | sed -s 's/\"//g')
            status_full=$(curl -f -s ${GIT_URL}${REPO_DESCR}status/${sha}${GITHUB_ACCESS_TOKEN})
            print_pr_details "${STATUS}" "${status_full}"
            STATUS=$(get_pr_status "${status_full}")
        fi

    fi
    if [ $TWO ]; then
       STATUS2=$(curl -f -s "${BUILD_URL}${PROJECT2}/api/xml?xpath=/*/color")
       STATUS2=$(echo $STATUS2 | sed -e 's,<color>,,' -e 's,</color>,,')
       LED1=1
       LED2=2
    else
       LED1=0
    fi
    if [[ $TWO && -n "$BLINK2_TOOL" ]]; then
        blink=$(get_blink ${STATUS} ${STATUS2})
        $BLINK2_TOOL $blink rgb=$(get_color ${STATUS}) rgb=$(get_color ${STATUS2})
        if [ -z "$blink" ]; then
            sleep ${POLL_FREQUENCY}
        fi
    else
        set_blink1_color $(get_color ${STATUS}) $LED1
        if [ $TWO ]; then set_blink1_color $(get_color ${STATUS2}) $LED2; fi
        sleep ${POLL_FREQUENCY}
    fi
done
