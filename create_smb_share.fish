function info
	echo -e "\x1b[34m[*]\x1b[m $argv" 
end
function success
	echo -e "\x1b[32m[+]\x1b[m $argv" 
end
function failure
	echo -e "\x1b[31m[-]\x1b[m $argv" 
end

function check_samba
	set samba_installed (dpkg -l '*samba*' | grep '^ii\s\+samba\s\+')

	info "Checking that samba is installed"
	if test -n $samba_installed
		success "Samba is installed"
		return 0
	else
		failure "Samba is not installed"
		return 1
	end
end

function install_samba
	info "Installing samba"
	sudo apt install -y samba
end

function create_user
	set user $argv[1]
	info "Creating user $user"
	sudo useradd -M -s /sbin/nologin $user
	sudo passwd smbuser

	info "Enabling user in samba"
	sudo smbpasswd -a $user
	sudo smbpasswd -e $user
end

function main
	argparse "h/help" "u/user=" "n/name=" -- $argv

	if set -q _flag_help
		echo "create_smb_share.fish [-u USER(smbuser)] [-n NAME(share)] PATH"
		return 0
	end

	if test (count $argv) -lt 1
		failure "No path specified"
		return
	end

	set name "share"
	set user "smbuser"
	set path $argv[1]

	if set -q _flag_name
		set name $_flag_name
	end

	if set -q _flag_user
		set user $_flag_user
	end

	if not check_samba
		if install_samba
			success "Samba install successful"
			sudo systemctl disable smbd
		else
			failure "Samba install failed"
			return 1
		end
	end

	if not systemctl status smbd >/dev/null 2>&1
		info "Starting smbd service"
		sudo systemctl start smbd
	end

	if not id $user >/dev/null 2>&1
		failure "User $user does not exist"
		create_user $user
	end

	info "Updating smb.conf"
	mkdir -p $path

	printf "a\n\n[%s]\n\tpath = %s\n\tvalid users = %s\n\tforce user = %s\n\tbrowsable = yes\n\tguest ok = yes\n\tread only = no\n\twritable = yes\n.\nw\nq\n" $name $path $user $user | sudo ed /etc/samba/smb.conf

	info "Restarting smbd service to take conf into account"
	sudo systemctl restart smbd
end

main $argv
