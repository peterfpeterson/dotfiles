# setup linuxbrew
if [ -d ${HOME}/.linuxbrew/bin/ ]; then
  export PATH="$HOME/.linuxbrew/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/.linuxbrew/lib:$LD_LIBRARY_PATH"
fi

# User specific aliases and functions
if [ -f ${HOME}/.pythonrc ]; then
  export PYTHONSTARTUP=${HOME}/.pythonrc
fi

export PATH
export EDITOR=vim

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
