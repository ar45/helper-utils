#!/bin/bash -e

__curdir=`dirname ${BASH_SOURCE[0]}`
source $__curdir/helpers


updated_apt_cache=false
apt_install()
{
	$updated_apt_cache || sudo_cmd apt-get update
	updated_apt_cache=true
	sudo_cmd apt-get install $@
}


ensure_packages()
{
	local REQUIRED_PACKAGES="$1"
	local UPGRADE_PACKAGES="$2"

	local packages_to_install pkg
	if [ "$UPGRADE_PACKAGES" = true ]; then
		packages_to_install="$REQUIRED_PACKAGES"
	else
		for pkg in $REQUIRED_PACKAGES; do
			dpkg -l $pkg >/dev/null 2>&1 || packages_to_install="$packages_to_install $pkg";
		done
	fi

	if [ ! -z "$packages_to_install" ]; then
		apt_install -y "$packages_to_install"
	fi
}


### PPA SETUP STUFF
setup_postgres_ppa()
{
    if grep -R --include='*.list' 'apt.postgresql.org/pub/repos/apt/' /etc/apt/sources*; then
        return
    fi

    sudo_cmd sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo_cmd apt-key add -
}


# Ignore if it is sourced
if [ ! -z "$*" ]; then
	"$@"
fi

