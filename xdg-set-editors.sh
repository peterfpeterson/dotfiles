#!/usr/bin/env sh
_editor=emacs.desktop

######################################################################
# find mimetype from
# xdg-mime query filetype /path/to/file
######################################################################
xdg-mime default "${_editor}" text/plain
#xdg-mime default "${_editor}" text/x-c++src
#xdg-mime default "${_editor}" text/x-chdr

echo "${HOME}/.config/mimeapps.list"
cat "${HOME}/.config/mimeapps.list"
