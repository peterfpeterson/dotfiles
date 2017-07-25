export WARI_ROOT=`pwd`/wari


. $WARI_ROOT/wari-setup.sh

echo "Adding repositories"
add_repo chrome
add_repo devtoolset-3
add_repo elrepo epel
add_repo mantid
add_repo rpmfusion-free rpmfusion-nonfree
#add_repo sns

if [ ! -f ${REPO_DIR}/_copr_peterfpeterson-morebin.repo ]; then
    add_copr_repo peterfpeterson/morebin
fi

echo "Adding packages for distribution"
add_packages_from_distro_file

echo "Adding individual packages"
add_package autofs
add_package ccache
add_package colordiff
add_package conky
add_package ninja-build
add_package python2-argcomplete
add_package python3-argcomplete
add_package cmake-gui
add_package rpm-build
add_package mantid-developer
add_package morebin
add_package the_silver_searcher
add_package qt-creator
add_package vim-enhanced
add_package emacs
add_package pithos
add_package mock
add_package ncdu
add_package slock
add_package terminology
add_package hidapi-devel
add_package source-highlight
# things for awesome window manager
add_package awesome
add_package vicious # widget set
add_package i3lock # screen lock
# smart card reader
add_package opensc
add_package pcsc-tools
add_package pcsc-lite-ccid

echo "Done"
