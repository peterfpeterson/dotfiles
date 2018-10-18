# This is executed by interactive shells (and sourced in .bash_profile)

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Git prompt stuff
if [ -f ${HOME}/.gitprompt/gitprompt.sh ]; then
  . ${HOME}/.gitprompt/gitprompt.sh
fi

# https://github.com/github/hub/
if [ $(command -v hub) ]; then
  eval "$(hub alias -s)"
  if [ -f ${HOME}/.ssh/github_oauth ]; then
    GITHUB_TOKEN=$(cat ${HOME}/.ssh/github_oauth)
  fi
fi

if [ $(command -v vim) ]; then
  alias vi=vim
fi

# https://github.com/defunkt/gist
if [ $(command -v gist) ]; then
  alias gist="gist -c"
fi

# bash completion for ninja
if [ -f /usr/share/bash-completion/completions/ninja-bash-completion ]; then
  . /usr/share/bash-completion/completions/ninja-bash-completion
fi

# Custom bash completion
if [ -d ${HOME}/.bash_completion.d ]; then
    for f in ${HOME}/.bash_completion.d/*
    do
	. $f
    done
fi
if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    . /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
elif [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
    . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
fi

# things for homebrew
if [ $(command -v brew) ]; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

# things for rhc
if [ $(command -v rhc) ]; then
  if [ -f ${HOME}/.gem/ruby/gems/rhc-*/autocomplete/rhc_bash ]; then
    . ${HOME}/.gem/ruby/gems/rhc-*/autocomplete/rhc_bash
  elif [ -f /usr/local/share/gems/gems/rhc-*/autocomplete/rhc_bash ]; then
    . /usr/local/share/gems/gems/rhc-*/autocomplete/rhc_bash
  fi
fi


alias grep="grep --color=auto"

# Setup for tcmalloc
if [ -e /usr/lib64/libtcmalloc.so ]; then
#  export LD_PRELOAD=`readlink -f /usr/lib64/libtcmalloc.so`
  export TCMALLOC_RELEASE_RATE="10000"
fi

# do this in the ~/.ipython/ipythonrc file
#alias ipython="ipython --colors LightBG"

if [ -n "$SSH_CONNECTION" ]; then
  unset SSH_ASKPASS
fi

# Simple calculator - from https://github.com/mathiasbynens/dotfiles/blob/master/.functions
function calc() {
local result=""
result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
# └─ default (when `--mathlib` is used) is 20
#
if [[ "$result" == *.* ]]; then
# improve the output for decimal numbers
printf "$result" |
sed -e 's/^\./0./' `# add "0" for cases like ".5"` \
-e 's/^-\./-0./' `# add "0" for cases like "-.5"`\
-e 's/0*$//;s/\.$//' # remove trailing zeros
else
printf "$result"
fi
printf "\n"
}

if [ -f /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc ]; then
  alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc"
fi

if [ $(command -v ninja-build) ]; then
  alias ninja=ninja-build
fi

PATH=$HOME/bin:/usr/local/bin:$PATH
#if [ -d $HOME/miniconda2 ]; then
#   PATH=$HOME/miniconda2/bin:$PATH
#fi

# todo.txt
if [ $(command -v todo.sh) ]; then
#  alias todo="todo.sh -d ${HOME}/Dropbox/todo/todo.cfg -n"
  export TODOTXT_DEFAULT_ACTION=ls
fi

if [ -d ${HOME}/.rvm ]; then
  # automatically switch to ruby 2.1.1
  source $(${HOME}/.rvm/bin/rvm 2.1.1 do rvm env --path)
  # Load RVM into a shell session *as a function*
  if [ -s ${HOME}/.rvm/scripts/rvm ]; then
    . ${HOME}/.rvm/scripts/rvm
  fi
  # add RVM bash completion
  if [ -f $HOME/.rvm/scripts/completion ]; then
    . $HOME/.rvm/scripts/completion
  fi
fi

# source-highlighting with less
if [ $(command -v highlight) ]; then
  export LESSOPEN="| $(command -v highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-dark"
elif [ $(command -v src-hilite-lesspipe.sh) ]; then
  export LESSOPEN="| $(command -v src-hilite-lesspipe.sh) %s"
fi
alias less='less -m -N -g -i -J --line-numbers --underline-special'
export LESS=' -R '

# colorized diffs from colordiff
if [ $(command -v colordiff) ]; then
  alias diff=colordiff
fi

# flip a table if a command didn't work
PROMPT_COMMAND='[ $? -eq 0 ] || printf "(╯°□°）╯︵ ┻━┻\n"'

# whatidid
WHATIDIDDIR=${HOME}/Dropbox/whatidid
alias whatidid="${EDITOR} ${WHATIDIDDIR}/$(date '+%Y-week%V.md')"
alias whatidid_addday="echo $(date '+%F') >> ${WHATIDIDDIR}/$(date '+%Y-week%V.md')"

export GOPATH=$HOME/go
export GOARCH=x86

# gem install bundler_bash_completion
if [ $(command -v complete_bundle_bash_command) ]; then
  eval `complete_bundle_bash_command init`
fi

# add direnv https://github.com/direnv/direnv/
if [ $(command -v direnv) ]; then
  eval "$(direnv hook bash)"
fi
