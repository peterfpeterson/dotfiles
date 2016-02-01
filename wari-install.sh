export WARI_ROOT=`pwd`/wari


. $WARI_ROOT/wari-setup.sh

add_repo chrome
add_repo devtoolset-3
add_repo elrepo epel
add_repo mantid
#add_repo rpmfusion-free rpmfusion-nonfree #TODO
add_repo sns

add_packages_from_distro_file

#add_package morebin mantid-developer

echo "Done"
