# This is executed by login shells

# User specific aliases and functions
if [ -f ${HOME}/.pythonrc ]; then
  export PYTHONSTARTUP=${HOME}/.pythonrc
fi

# For homebrew
if [ -d "/usr/local/sbin" ]; then
  export PATH="/usr/local/sbin:$PATH"
else
  export PATH
fi

export EDITOR=vim

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

if [ $(command -v fortune) ]; then
    fortune -a
fi
