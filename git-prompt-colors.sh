######################################################################
# customization taken from liquidprompt
######################################################################
_LP_USER_SYMBOL="\u"

########## USER
# Yellow for root, bold if the user is not the login one, else no color.
if [[ "$EUID" -ne "0" ]] ; then  # if user is not root
    # if user is not login user
    if [[ ${USER} != "$(logname 2>/dev/null || echo $LOGNAME)" ]]; then
        LP_USER="${LP_COLOR_USER_ALT}${_LP_USER_SYMBOL}@${NO_COL}"
    else
        if [[ "${LP_USER_ALWAYS}" -ne "0" ]] ; then
            LP_USER="${LP_COLOR_USER_LOGGED}${_LP_USER_SYMBOL}@${NO_COL}"
        else
            LP_USER=""
        fi
    fi
else # root!
    LP_USER="${LP_COLOR_USER_ROOT}${_LP_USER_SYMBOL}${NO_COL}"
    LP_COLOR_MARK="${LP_COLOR_MARK_ROOT}"
    LP_COLOR_PATH="${LP_COLOR_PATH_ROOT}"
    # Disable VCS info for all paths
    if [[ "$LP_ENABLE_VCS_ROOT" != 1 ]]; then
        LP_DISABLED_VCS_PATH=/
        LP_MARK_DISABLED="$_LP_MARK_SYMBOL"
    fi
fi

######################################################################
# customization for git-prompt
######################################################################
# These are the defaults from the "Default" theme
# You just need to override what you want to have changed
override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Custom"

  # Time12a="\$(date +%H:%M)"
  # PathShort="\w";

  ## These are the color definitions used by gitprompt.sh
  GIT_PROMPT_PREFIX="("                 # start of the git info string
  GIT_PROMPT_SUFFIX=")"                 # the end of the git info string
  # GIT_PROMPT_SEPARATOR="|"              # separates each item

  # GIT_PROMPT_BRANCH="${Magenta}"        # the git branch that is active in the current directory
  # GIT_PROMPT_STAGED="${Red}●"           # the number of staged files/directories
  # GIT_PROMPT_CONFLICTS="${Red}✖ "       # the number of files in conflict
  # GIT_PROMPT_CHANGED="${Blue}✚ "        # the number of changed files

  # GIT_PROMPT_REMOTE=" "                 # the remote branch name (if any) and the symbols for ahead and behind
  # GIT_PROMPT_UNTRACKED="${Cyan}…"       # the number of untracked files/dirs
  # GIT_PROMPT_STASHED="${BoldBlue}⚑ "    # the number of stashed files/dir
  # GIT_PROMPT_CLEAN="${BoldGreen}✔"      # a colored flag indicating a "clean" repo

  ## For the command indicator, the placeholder _LAST_COMMAND_STATE_
  ## will be replaced with the exit code of the last command
  ## e.g.
  ## GIT_PROMPT_COMMAND_OK="${Green}✔-_LAST_COMMAND_STATE_ "    # indicator if the last command returned with an exit code of 0
  ## GIT_PROMPT_COMMAND_FAIL="${Red}✘-_LAST_COMMAND_STATE_ "    # indicator if the last command returned with an exit code of other than 0

  # GIT_PROMPT_COMMAND_OK="${Green}✔"    # indicator if the last command returned with an exit code of 0
  # GIT_PROMPT_COMMAND_FAIL="${Red}✘-_LAST_COMMAND_STATE_"    # indicator if the last command returned with an exit code of other than 0

  ## template for displaying the current virtual environment
  ## use the placeholder _VIRTUALENV_ will be replaced with
  ## the name of the current virtual environment (currently CONDA and VIRTUAL_ENV)
  # GIT_PROMPT_VIRTUALENV="(${Blue}_VIRTUALENV_${ResetColor}) "

  ## _LAST_COMMAND_INDICATOR_ will be replaced by the appropriate GIT_PROMPT_COMMAND_OK OR GIT_PROMPT_COMMAND_FAIL
  GIT_PROMPT_START_USER="$ResetColor[${LP_USER}\h:$Yellow\W$ResetColor"
  #GIT_PROMPT_START_ROOT="_LAST_COMMAND_INDICATOR_ ${GIT_PROMPT_START_USER}"
  GIT_PROMPT_END_USER=" ]$ "
  GIT_PROMPT_END_ROOT=" ]# "

  ## Please do not add colors to these symbols
  # GIT_PROMPT_SYMBOLS_AHEAD="↑·"             # The symbol for "n versions ahead of origin"
  # GIT_PROMPT_SYMBOLS_BEHIND="↓·"            # The symbol for "n versions behind of origin"
  # GIT_PROMPT_SYMBOLS_PREHASH=":"            # Written before hash of commit, if no name could be found
  # GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING="L" # This symbol is written after the branch, if the branch is not tracked
}

reload_git_prompt_colors "Custom"
