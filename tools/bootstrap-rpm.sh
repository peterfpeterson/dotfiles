#!/bin/bash

REPO_DIR="/etc/yum.repos.d/"
if [ ! -d $REPO_DIR ]; then
    echo "yum/dnf are not detected"
    exit
fi

# find the command for installing
DNF=`which yum`
if [ $(command -v dnf) ]; then
    DNF=`which dnf`
fi
echo "Installing using '${DNF}'"

# determine what the operating system is
RELEASE=""
if [ -f /etc/redhat-release ]; then
    RELEASE=`cat /etc/redhat-release`
elif [ $(command -v lsb_release) ]; then
    RELEASE=`lsb_release -d`
else
    echo "Failed to determine release description"
    exit 1
fi

# default list of repositories to install
REPOS=""

# repositories depend on os
if [[ $RELEASE == *Fedora* ]]; then
    echo "Found fedora"
    REPOS="rpmfusion-free rpmfusion-nonfree fedora-nvidia google-chrome"
elif [[ $RELEASE == *"Red Hat Enterprise Linux"* ]]; then
    echo "Assuming RHEL"
    REPOS="epel rpmfusion"
else
    echo "Do not know codename '$RELEASE'"
    exit 1
fi

function installUrl
{
    URL=${1}
    echo "sudo ${DNF} install --nogpgcheck ${URL}"
    sudo ${DNF} install --nogpgcheck ${URL}
}

function addRepo
{
    URL=${1}
    if [[ $DNF == *dnf ]]; then
        CMD="${DNF} config-manager"
    elif [[ $DNF == *yum ]]; then
        CMD="yum-config-manager"
    else
        echo "Something went wrong"
        exit 1
    fi
    echo "sudo ${CMD} --add-repo=${URL}"
    sudo ${CMD} --add-repo=${URL}
}

FEDORA=`rpm -E %fedora`
# do the right thing for rpms
echo "Setting up repositories: $REPOS"
for ITEM in $REPOS
do
    if [ ! -f "$REPO_DIR/$ITEM.repo" ]; then
      FILE=""
      case "$ITEM" in
          google-chrome)
              echo "Get the google-chrome rpm from https://www.google.com/chrome/browser/desktop/index.html"
              exit 1
              ;;

	epel)
          echo "$ITEM is not installed"
	  FILE=http://download.fedoraproject.org/pub/epel/$(rpm -E %rhel)/x86_64/epel-release-$(rpm -E %rhel)-8.noarch.rpm
          installUrl $FILE
	  ;;

        rpmfusion-free)
            installUrl http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            ;;

        rpmfusion-nonfree)
            installUrl http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            ;;

        fedora-nvidia)
            if [ ! $(rpm -E %fedora) == "%fedora" ]; then
                addRepo http://negativo17.org/repos/fedora-nvidia.repo
            elif [ ! $(rpm -E %rhel) == "%rhel" ]; then
                addRepo http://negativo17.org/repos/epel-nvidia.repo
            else
                echo "Do not have url for fedora-nvidia"
                exit 1
            fi
            ;;
        *)
            echo "Do not no how to install '$ITEM.repo'"
            exit
      esac
    fi
done
