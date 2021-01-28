# This is executed by login shells

# For homebrew
if [ -d "/usr/local/sbin" ]; then
  export PATH="/usr/local/sbin:$PATH"
else
  export PATH
fi

# Get the aliases and functions
if [[ $- == *i* ]]; then  # interactive shell when "i" is in the "$-" variable
  if [ -f ~/.bashrc ]; then
    # shellcheck source=bashrc
    source ~/.bashrc
  fi
fi
