#!/bin/bash -e

__curdir=`dirname ${BASH_SOURCE[0]}`
source $__curdir/helpers


get_listen_ip_port()
{
	local ip="$1"
	local port="$2"
	local new_record

	# If ip specified check for an existing record for that ip
	# in addtion, check for record with port only.
	if grep -q -E "^\s+?Listen\s+${port}\b" /etc/apache2/ports.conf; then
		echo "Already configured to be listening on port '$port'"
		return 1
	fi

	if [ -z "$ip" ]; then
		ip="0.0.0.0"
		new_record="Listen $port"
	else
		new_record="Listen $ip:$port"
	fi

	if grep -q -E "^\s+?Listen\s+${ip}:${port}\b" /etc/apache2/ports.conf; then
		echo "Already configured to be listening on port '$ip:$port'"
		return 1
	fi

	# Add the new record at the end of the file
	echo "$new_record" #>> /etc/apache2/ports.conf
}


add_listen_ip_port()
{
	record=`get_listen_ip_port "$1" "$2"` && {
		sudo_cmd sed -i -e "\$i${record}\n" /etc/apache2/ports.conf
	}
}





# Ignore if it is sourced
if [ ! -z "$*" ]; then
	"$@"
fi

