# This is executed by login shells

# For homebrew
if [ -d "/usr/local/sbin" ]; then
  export PATH="/usr/local/sbin:$PATH"
else
  export PATH
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
