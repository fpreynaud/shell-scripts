#!/bin/bash
declare -a interfaces
default_ip=192.168.1.2
interfaces=($(ip l | grep -v link/ | awk '{print $2}' | cut -f1 -d: | tail -n +2))
function inarray(){
	value="$1"
	shift
	for val in "$@"; do
		if test $val = $value; then
			return 0
		fi
	done
	return 1
}

echo -e "\x1b[34;1mAvailable Interfaces"
echo -e "---------------------\x1b[m"
for interface in ${interfaces[@]}; do
	echo $interface
done
echo

read -p "Choose NAT interface to configure (${interfaces[0]}): " nat_interface 
if test -z $nat_interface; then
	nat_interface=${interfaces[0]}
else
	while ! inarray $nat_interface $interfaces; do
		read -p "Incorrect interface entered. Choose interface: (${interfaces[0]})" nat_interface 
		if test -z $nat_interface; then
			nat_interface=${interfaces[0]}
			break
		fi
	done
fi
echo "You chose $nat_interface"

read -p "Choose bridge interface to configure (${interfaces[1]}): " bridge_interface 
if test -z $bridge_interface; then
	bridge_interface=${interfaces[1]}
else
	while ! inarray $bridge_interface $interfaces; do
		read -p "Incorrect interface entered. Choose interface (${interfaces[1]}): " bridge_interface 
		if test -z $bridge_interface; then
			bridge_interface=${interfaces[1]}
		fi
	done
fi
echo "You chose $bridge_interface"

echo -e "\n\x1b[34;1mConfiguring IP address for $bridge_interface\x1b[m"
read -p "Enter IP adress to set for $bridge_interface ($default_ip): " ipaddr
if test -z "$ipaddr"; then
	ipaddr="$default_ip"
fi
echo "IP address for $bridge_interface: $ipaddr"
echo nmcli device modify $bridge_interface ipv4.method manual ipv4.addr "$ipaddr"
nmcli device modify $bridge_interface ipv4.method manual ipv4.addr "$ipaddr"

echo -e "\n\x1b[34;1mConfiguring network routes\x1b[m"
echo ip route add $(echo $ipaddr | cut -f1-3 -d.).0/24 dev $bridge_interface
ip route add $(echo $ipaddr | cut -f1-3 -d.).0/24 dev $bridge_interface

echo -e "\n\x1b[34;1mEnabling IP forwarding\x1b[m"
echo sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.ip_forward=1

echo -e "\n\x1b[34;1mConfiguring iptables rules\x1b[m"
echo iptables -A FORWARD -i $bridge_interface -o $nat_interface -j ACCEPT
iptables -A FORWARD -i $bridge_interface -o $nat_interface -j ACCEPT
echo iptables -A FORWARD -i $nat_interface -o $bridge_interface -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $nat_interface -o $bridge_interface -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
echo iptables -t nat -A POSTROUTING -o $nat_interface -j MASQUERADE
iptables -t nat -A POSTROUTING -o $nat_interface -j MASQUERADE
