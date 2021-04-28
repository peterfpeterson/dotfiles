#!/bin/bash
if [ ! -L "${HOME}/Dropbox" ]; then
    if [ -d "${HOME}/Dropbox (ORNL)" ]; then
        echo "Linking ${HOME}/Dropbox to ${HOME}/Dropbox (ORNL)"
        ln -s "${HOME}/Dropbox (ORNL)" "${HOME}/Dropbox"
    fi
fi
