#!/bin/bash

# default list of repositories to install
REPOS=""

# repositories depend on os
if [ $(command -v lsb_release) ]; then
  LINUX_CODENAME=$(lsb_release -c | sed 's/[ \t]*Codename:[ \t]*//')
  case "$LINUX_CODENAME" in
    Santiago)
      REPOS="epel rpmfusion virtualbox"
      ;;
    *)
      echo "Do not know codename\"$LINUX_CODENAME\""
      exit 1
  esac
else
  echo "Must have lsb_release to run this script"
  exit
fi

# do the right thing for rpms
if [ $(command -v yum) ]; then
  REPO_DIR="/etc/yum.repos.d/"

  for ITEM in $REPOS
  do
    if [ ! -f "$REPO_DIR/$ITEM.repo" ]; then
      FILE=""
      case "$ITEM" in
	epel)
          echo "$ITEM is not installed"
	  FILE=http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
          sudo yum localinstall --nogpgcheck $FILE
	  ;;
	virtualbox)
          echo "$ITEM is not installed"
	  FILE=virtualbox.repo
	  wget http://download.virtualbox.org/virtualbox/rpm/el/$FILE
	  sudo cp $FILE $REPO_DIR
	  ;;
	rpmfusion)
	  if [ ! -f "$REPO_DIR/rpmfusion-free-updates.repo" ]; then
            echo "$ITEM-free is not installed"
            FILE=http://download1.rpmfusion.org/free/el/updates/6/x86_64/rpmfusion-free-release-6-1.noarch.rpm
            sudo yum localinstall --nogpgcheck $FILE
	  fi
	  if [ ! -f "$REPO_DIR/rpmfusion-nonfree-updates.repo" ]; then
            echo "$ITEM-nonfree is not installed"
            FILE=http://download1.rpmfusion.org/nonfree/el/updates/6/x86_64/rpmfusion-nonfree-release-6-1.noarch.rpm
            sudo yum localinstall --nogpgcheck $FILE
	  fi
      esac
    fi
  done
else
  echo "don't have yumm"
  exit 1
fi
