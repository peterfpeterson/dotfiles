# This is executed by interactive shells (and sourced in .bash_profile)

PATH=$HOME/bin:/usr/local/bin:$PATH
export GOPATH=$HOME/go

# interactive shell when "i" is in the "$-" variable
if [[ ! $- == *i* ]]; then
  return  # don't execute any more of the file
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# Git prompt stuff
if [ -f "${HOME}/.gitprompt/gitprompt.sh" ]; then
  export GIT_PROMPT_SHOW_UNTRACKED_FILES=no
  if ! [[ $(hostname) == "analysis"* ]]; then
    source "${HOME}/.gitprompt/gitprompt.sh"
  fi
fi

# https://github.com/github/hub/
if [ "$(command -v hub)" ]; then
  eval "$(hub alias -s)"
  if [ -f "${HOME}/.ssh/github_oauth" ]; then
    export GITHUB_TOKEN=$(cat ${HOME}/.ssh/github_oauth)
  fi
fi

if [ "$(command -v vim)" ]; then
  alias vi=vim
  export EDITOR=vim
fi

# https://github.com/defunkt/gist
if [ "$(command -v gist)" ]; then
  alias gist="gist -c"
fi

# bash completion for ninja
if [ -f /usr/share/bash-completion/completions/ninja-bash-completion ]; then
  source /usr/share/bash-completion/completions/ninja-bash-completion
fi

# Custom bash completion
if [ -d "${HOME}/.bash_completion.d" ]; then
    for f in "${HOME}"/.bash_completion.d/*
    do
	source "$f"
    done
fi
if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
elif [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
fi

# things for homebrew
if [ "$(command -v brew)" ]; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
  fi
fi

# things for rhc
if [ "$(command -v rhc)" ]; then
  if [ -f "${HOME}/.gem/ruby/gems/rhc-*/autocomplete/rhc_bash" ]; then
    source "${HOME}/.gem/ruby/gems/rhc-*/autocomplete/rhc_bash"
  elif [ -f /usr/local/share/gems/gems/rhc-*/autocomplete/rhc_bash ]; then
    source /usr/local/share/gems/gems/rhc-*/autocomplete/rhc_bash
  fi
fi


alias grep="grep --color=auto"
alias subdir="ls -d */"

# Setup for tcmalloc
if [ -e /usr/lib64/libtcmalloc.so ]; then
#  export LD_PRELOAD=`readlink -f /usr/lib64/libtcmalloc.so`
  export TCMALLOC_RELEASE_RATE="10000"
fi

# do this in the ~/.ipython/ipythonrc file
#alias ipython="ipython --colors LightBG"

# User specific aliases and functions
if [ -f "${HOME}/.pythonrc" ]; then
  export PYTHONSTARTUP=${HOME}/.pythonrc
fi

if [ -n "$SSH_CONNECTION" ]; then
  unset SSH_ASKPASS
fi

# Simple calculator - from https://github.com/mathiasbynens/dotfiles/blob/master/.functions
function calc() {
local result=""
result="$(echo "scale=10;$*" | bc --mathlib | tr -d '\\\n')"
# └─ default (when `--mathlib` is used) is 20
#
if [[ "$result" == *.* ]]; then
  # improve the output for decimal numbers
  echo "$result" |
  sed -e 's/^\./0./' `# add "0" for cases like ".5"` \
  -e 's/^-\./-0./' `# add "0" for cases like "-.5"`\
  -e 's/0*$//;s/\.$//' # remove trailing zeros
else
  echo "$result"
fi
  echo
}

if [ -f /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc ]; then
  alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc"
fi

if [ "$(command -v ninja-build)" ]; then
  alias ninja=ninja-build
fi

if [ "$(command -v ninja)" ]; then
  export RIPGREP_CONFIG_PATH=${HOME}/.ripgreprc
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/SNS/users/pf9/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/SNS/users/pf9/miniconda3/etc/profile.d/conda.sh" ]; then
        source "/SNS/users/pf9/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/SNS/users/pf9/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# todo.txt
if [ "$(command -v todo.sh)" ]; then
#  alias todo="todo.sh -d ${HOME}/Dropbox/todo/todo.cfg -n"
  export TODOTXT_DEFAULT_ACTION=ls
fi

if [ -d "${HOME}/.rvm" ]; then
  # automatically switch to ruby 2.1.1
  source $("${HOME}/.rvm/bin/rvm" 2.1.1 do rvm env --path)
  # Load RVM into a shell session *as a function*
  if [ -s "${HOME}/.rvm/scripts/rvm" ]; then
    source "${HOME}/.rvm/scripts/rvm"
  fi
  # add RVM bash completion
  if [ -f "$HOME/.rvm/scripts/completion" ]; then
     source "$HOME/.rvm/scripts/completion"
  fi
fi

# source-highlighting with less
if [ "$(command -v bat)" ]; then
   alias less=bat
else
    if [ "$(command -v highlight)" ]; then
      LESSOPEN="| $(command -v highlight) %s --out-format xterm256 --line-numbers --quiet --force --style solarized-dark"
      export LESSOPEN
    elif [ "$(command -v src-hilite-lesspipe.sh)" ]; then
      LESSOPEN="| $(command -v src-hilite-lesspipe.sh) %s"
      export LESSOPEN
    fi
    alias less='less -m -N -g -i -J --line-numbers --underline-special'
    export LESS=' -R '
fi

# colorized diffs from colordiff
if [ "$(command -v colordiff)" ]; then
  alias diff=colordiff
fi

# diff two normalized xml files
diffxml() {
    diff <(xmllint --exc-c14n "$1") <(xmllint --exc-c14n "$2")
}

# gem install bundler_bash_completion
if [ "$(command -v complete_bundle_bash_command)" ]; then
  complete_bundle_bash_command init
fi

# extra fzf definitions https://github.com/junegunn/fzf
if [ "$(command -v fzf)" ]; then
  complete -F _fzf_path_completion pycharm
  if [ "$(command -v rg)" ]; then
    alias fzfpreview="rg --files | fzf --preview 'less {}'"
  else
    alias fzfpreview="fzf --preview 'less {}'"
  fi

  _fzf_complete_ssh_notrigger() {
    FZF_COMPLETION_TRIGGER='' _fzf_host_completion
  }
  complete -o bashdefault -o default -F _fzf_complete_ssh_notrigger ssh

  # shellcheck source=fzf.bash
  if [ -f "$HOME/.fzf.bash" ]; then
    # shellcheck source=fzf.bash
    source "$HOME/.fzf.bash"
  fi

  # based on https://medium.com/@GroundControl/better-git-diffs-with-fzf-89083739a9cb
  fzfdiff() {
    git diff --name-only "$@" | fzf -m --ansi --preview 'git diff "$@" --color=always -- {-1}'
  }

  #determines search program for fzf
  if [ "$(command -v rg)" ]; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden'
  elif [ "$(command -v ag)" ]; then
    export FZF_DEFAULT_COMMAND='ag -p ~/.gitexcludes -g ""'
  fi
fi


# https://github.com/bellecp/fast-p to search pdfs for things in the first page
if [ "$(command -v fzf && command -v fast-p)" ]; then
  # body modified from the project's README
  findpdf () {
    open=xdg-open   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    if [ "$(command -v rg)" ]; then
      # find files with ripgrep
      rg --files -t pdf \
          | fast-p \
          | fzf --read0 --reverse -e -d $'\t'  \
                --preview-window down:80% --preview '
                     v=$(echo {q} | tr " " "|");
                     echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
                     ' \
          | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
    elif  [ "$(command -v ag)" ]; then
      # find files with silver searcher
      ag -U -g ".pdf$" \
          | fast-p \
          | fzf --read0 --reverse -e -d $'\t'  \
                --preview-window down:80% --preview '
                     v=$(echo {q} | tr " " "|");
                     echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
                     ' \
          | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
    else
      echo "Not configured to find files"
    fi
  }
fi

# add direnv https://github.com/direnv/direnv/
if [ "$(command -v direnv)" ]; then
  eval "$(direnv hook bash)"
fi

# flip a table if a command didn't work
function table_flip() {
  local result=$?
  if [ $result -eq 148 ]; then  # SIGTSTP
    #echo "¯\(°_o)/¯"        # on systems with crappy fonts
    echo "¯\(ッ)/¯"         # on "modern" systems use "utf8 katakana tu" for the face
  elif [ $result -ne 0 ]; then  # all other non-zero
    echo "(╯°□°)╯⏜ ┻━┻ ⏜ $result"
  fi
}
if [ -z "${PROMPT_COMMAND}" ]; then  # empty
    PROMPT_COMMAND='table_flip'
elif [[ ! "${PROMPT_COMMAND}" == *"table_flip"* ]]; then
    # table flip isn't already there
    echo "adding table flip to ${PROMPT_COMMAND}"
    if [[ "${PROMPT_COMMAND}" == *"_direnv_hook"* ]]; then
        # stick in table flip with direnv enabled
        PROMPT_COMMAND="${PROMPT_COMMAND/_direnv_hook/_direnv_hook||table_flip}"
    else
        # normal table flip
        PROMPT_COMMAND="table_flip;${PROMPT_COMMAND}"
    fi
fi

if [ "$(command -v fortune)" ]; then
    fortune -a
fi
