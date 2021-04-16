#!/bin/sh

# System installation script for Arch Linux

CONF_VERSION="1.1.0"

cb="$(tput setaf 0)"
cr="$(tput setaf 1)"
cg="$(tput setaf 2)"
cy="$(tput setaf 3)"
cb="$(tput setaf 4)"
cm="$(tput setaf 5)"
cc="$(tput setaf 6)"
cw="$(tput setaf 7)"
sb="$(tput bold)"
sn="$(tput sgr0)"
sr="$(tput smso)"
su="$(tput smul)"

print() {
	case "$1" in
		t|title)
			shift;
			printf "%s\n" "${sb}${cg}### $*${sn}"
			;;
		s|step)
			shift;
			printf "%s\n" "${sb}${cm}=== $*${sn}"
			;;
		l|list)
			shift;
			printf "%s\n" "${sb}${cb}  - $*${sn}"
			;;
		w|warning)
			shift;
			printf "%s\n" "${sb}${cy}::: $*${sn}"
			;;
		e|error)
			shift;
			printf "%s\n" "${sb}${cr}!!! $*${sn}"
			exit 1
			;;
		i|input)
			shift;
			rg="$1";
			shift;
			user_input=''
			user_input_correct='false'
			while [ "$user_input_correct" != 'true' ]; do
				printf "%s" "${sb}${cc}==> $* ${sn}";
				read;
				user_input="$REPLY"
				if [ -n "$rg" ] && echo "$user_input" | grep -Evq "^$rg$"; then
					print w 'Invalid input, try again!';
					user_input='';
				else
					user_input_correct='true'
				fi;
			done;
			;;
		p|protected)
			shift;
			rg="$1";
			shift;
			user_input=''
			user_input_correct='false'
			while [ "$user_input_correct" != 'true' ]; do
				printf "%s" "${sb}${cc}==> $* ${sn}";
				stty -echo
				read;
				user_input="$REPLY"
				stty echo
				printf '\n'
				if [ -n "$rg" ] && echo "$user_input" | grep -Evq "^$rg$"; then
					print w 'Invalid input, try again!';
					user_input='';
				else
					user_input_correct='true'
				fi;
			done;
			;;
		c|confirm)
			shift;
			def="$1";
			shift;
			user_input=''
			while [ -z "$user_input" ]; do
				case "$def" in
					y|Y)
						printf "%s" "${sb}${cc}==> $* [Y/n] ${sn}";
						def='y';;
					n|N)
						printf "%s" "${sb}${cc}==> $* [y/N] ${sn}";
						def='n';;
					*)
						printf "%s" "${sb}${cc}==> $* [y/n] ${sn}";
						def='';;
				esac
				read user_input
				case "$user_input" in
					y|Y)
						[ "$def" != 'n' ];
						return $?;;
					n|N)
						[ "$def" = 'n' ];
						return $?;;
					*)
						[ "$def" != '' ] && return 0;
						user_input='';
						print w 'Invalid input, try again!';;
				esac
			done;
			;;
		*)
			printf '%s\n' "$*"
			;;
	esac
}

check_environment() {

	print t 'Checking installation environment'

	print s 'Verifying installation environment'
	grep -q '^ID=arch$' /etc/os-release || {
		command -v pacman 1>/dev/null 2>/dev/null && \
		print w 'This script is intended for Arch Linux!' && \
		print w 'Derivative distributions are not officially supported.' || \
		print e 'This script is intended for Arch Linux!'
	}
	grep -q 'archiso' /etc/hostname || {
		print w 'Not in the default installation environment!'
		print w 'proceed with caution!'
	}

	print s 'Checking root privileges'
	[ "$(whoami)" = 'root' ] || {
		print w "${cr}Warning: insufficient privileges!"
		print w "${cr}Rerun as root or installer might misbehave."
	}

	print s 'Checking internet connection'
	ping -q -W 20 -c 1 1.1.1.1 1>/dev/null 2>/dev/null || \
	print e 'Not connected to the internet!'

	print s 'Checking boot mode'
	[ -n "$(ls -A /sys/firmware/efi/efivars)" ] || \
	print e 'Not booted in UEFI mode!'

}

parse_options() {
	WARN_PARAMS='false'
	CONF_PASS_PROMPT='p'
	while getopts M:T:D:E:S:H:K:B:R:A:U:u:p:x:s:d:c:F:f:Yih o; do
		case $o in
			# Hostname
			(M) CONF_HOSTNAME="$OPTARG";
				WARN_PARAMS='true';;
			# Timezone
			(T) CONF_TIMEZONE="$OPTARG";
				WARN_PARAMS='true';;
			# Installation disk
			(D) CONF_DISK="$OPTARG";
				WARN_PARAMS='true';;
            # Home partition size
			(H) if [ "$OPTARG" = '0' ]; then
					CONF_HOME='no'
					CONF_HOME_SIZE='no'
				else
					CONF_HOME='yes'
					CONF_HOME_SIZE="$OPTARG"
				fi;
				WARN_PARAMS='true';;
			# Enable LTS kernel
			(K) if [ "$OPTARG" = 'yes' ]; then
					CONF_LTS_KERNEL='yes';
					CONF_LTS='linux-lts';
				else
					CONF_LTS_KERNEL='no';
					CONF_LTS='';
				fi;
				WARN_PARAMS='true';;
			# Add direct UEFI boot entry
			(B) if [ "$OPTARG" = 'yes' ]; then
					CONF_UEFI_ENRTY='yes';
				else
					CONF_UEFI_ENRTY='no';
				fi;
				WARN_PARAMS='true';;
			# Repository mirror countries
			(R) CONF_MIRRORS="$OPTARG";
				WARN_PARAMS='true';;
			# Enable Arch User Repository
			(A) if [ "$OPTARG" = 'no' ]; then
					CONF_AUR='no';
				else
					CONF_AUR='yes';
				fi;
				WARN_PARAMS='true';;
			# Create primary user
			(U) if [ "$OPTARG" = 'no' ]; then
					CONF_ADD_USER='no';
				else
					CONF_ADD_USER='yes';
				fi;
				WARN_PARAMS='true';;
			# Username
			(u) CONF_USER="$OPTARG";
				WARN_PARAMS='true';;
			# Password
			(p) CONF_PASS="$OPTARG";
				CONF_PASS_ROOT="$OPTARG";
				CONF_PASS_PROVIDED='true'
				WARN_PARAMS='true';;
			# Enable passwordless sudo
			(x) if [ "$OPTARG" = 'no' ]; then
					CONF_PASSWORDLESS='no';
				else
					CONF_PASSWORDLESS='yes';
				fi;
				WARN_PARAMS='true';;
			# Default user shell
			(s) CONF_SHELL="$OPTARG";
				WARN_PARAMS='true';;
			# Chroot into system for manual modifications
			(c) if [ "$OPTARG" = 'yes' ]; then
					CONF_CHROOT='yes';
				else
					CONF_CHROOT='no';
				fi;
				WARN_PARAMS='true';;
			# Read configuration from file
			(F) CONF_PREFSRFILE="$OPTARG";
				WARN_PARAMS='true';;
			# Save configuration to file
			(f) CONF_PREFSWFILE="$OPTARG";;
			# Skip configuration confirmation
			(Y) CONF_SKIP_CONFIRMATION='true';
				print w 'Configuration confirmation will be skipped!';;
			# Insecure - show passwords in summary
			(i) CONF_INSECURE='true';
				CONF_PASS_PROMPT='i';
				print w 'Insecure mode: passwords will be visible!';;
			# Show usage help and exit
			(h) print t "System installer $CONF_VERSION";
				print s 'Host configuration';
				print l 'M' "${sn}${sb}${cc}HOSTNAME     " "${sn}Hostname";
				print l 'T' "${sn}${sb}${cc}TIMEZONE     " "${sn}Timezone";
				print l 'D' "${sn}${sb}${cc}DISK         " "${sn}Installation disk";
				print l 'H' "${sn}${sb}${cc}HOME_SIZE    " "${sn}Separate home partition size (${sb}0${sn} to disable)";
				print l 'K' "${sn}${sb}${cc}yes/no       " "${sn}Server mode (LTS kernel)";
				print l 'B' "${sn}${sb}${cc}yes/no       " "${sn}Add direct UEFI boot entry";
				print l 'R' "${sn}${sb}${cc}MIRRORS      " "${sn}Repository mirror countries";
				print l 'A' "${sn}${sb}${cc}yes/no       " "${sn}Enable Arch User Repository";
				print l 'U' "${sn}${sb}${cc}yes/no       " "${sn}Create primary user";
				print s 'User configuration';
				print l 'u' "${sn}${sb}${cc}USER         " "${sn}Username";
				print l 'p' "${sn}${sb}${cc}PASS         " "${sn}Password (for root if user is disabled)";
				print l 'x' "${sn}${sb}${cc}yes/no       " "${sn}Enable passwordless sudo";
				print l 's' "${sn}${sb}${cc}SHELL        " "${sn}Default user shell";
				print s 'Post installation';
				print l 'c' "${sn}${sb}${cc}yes/no       " "${sn}Chroot into system for manual modifications";
				print s 'Miscellaneous';
				print l 'F' "${sn}${sb}${cc}CONFIG_TOML  " "${sn}Read configuration from file";
				print l 'f' "${sn}${sb}${cc}CONFIG_TOML  " "${sn}Save configuration to file ${sb}${cw}(/mnt prefix for new system)";
				print l 'Y' "${sn}${sb}${cc}             " "${sn}Skip configuration confirmation ${sb}${cr}(dangerous)";
				print l 'i' "${sn}${sb}${cc}             " "${sn}Insecure mode – show passwords ${sb}${cy}(not recommended)";
				print l 'h' "${sn}${sb}${cc}             " "${sn}Show usage help and exit";
				exit;;
			(*) print e 'Invalid argument';;
		esac
	done
	shift "$((OPTIND - 1))"
	if [ "$WARN_PARAMS" = 'true' ]; then
		print s 'Using passed arguments'
		print w 'Warning: passed arguments are not validated!'
		print w 'If they are invalid, installation will fail.'
	fi
}

configure_host() {

	print t 'Host configuration'

	if [ -z "$CONF_HOSTNAME" ]; then
		print i '[a-zA-Z0-9-]+' 'Hostname:'
		conf_hostname="$user_input"
	else
		conf_hostname="$CONF_HOSTNAME"
	fi

	if [ -z "$CONF_TIMEZONE" ]; then
		while [ -z "$conf_timezone" ]; do
			print i '.+' 'Timezone:'
			if [ -f "/usr/share/zoneinfo/$user_input" ]; then
				conf_timezone="$user_input"
			else
				print w 'Invalid timezone!'
			fi
		done
	else
		conf_timezone="$CONF_TIMEZONE"
	fi

	if [ -z "$CONF_DISK" ]; then
		print s 'Select installation disk'
		lsblk -no NAME,SIZE,TYPE,FSTYPE
		avail_disks="$(lsblk -rno NAME,TYPE | awk '$2 == "disk" {d=sprintf("%s%s%s",d,(NR==1)?"":"|","("$1")")} END {print "("d")"}')"
		print i "$avail_disks" 'Install to:'
		conf_disk="$user_input"
	else
		conf_disk="$CONF_DISK"
	fi

	if echo "$conf_disk" | grep -q '^nvme'; then
		part_prefix="p"
	else
		part_prefix=""
	fi

	if [ -z "$CONF_DISK_2" ]; then
		print s 'Select 2nd installation disk'
		lsblk -no NAME,SIZE,TYPE,FSTYPE
		avail_disks_2="$(lsblk -rno NAME,TYPE | awk '$2 == "disk" {d=sprintf("%s%s%s",d,(NR==1)?"":"|","("$1")")} END {print "("d")"}')"
		print i "$avail_disks_2" 'Install to:'
		conf_disk_2="$user_input"
	else
		conf_disk_2="$CONF_DISK_2"
	fi

	if echo "$conf_disk_2" | grep -q '^nvme'; then
		part_prefix_2="p"
	else
		part_prefix_2=""
	fi

    if [ -z "$CONF_HOME_SIZE" ]; then
        conf_home='no'
		conf_home_size='no'
        home_size_default="$(lsblk -o NAME,SIZE -b -r -n "/dev/$conf_disk" | awk "\$1 == \"$conf_disk\" {gb=int(\$2)/10**9} END {if(gb>40) print int(gb*0.625); else print 0}")"
		if [ "$home_size_default" != '0' ]; then
            if ! print c 'N' 'Enable separate home partition'; then
                conf_home='yes'
                print i '$|^([1-9][0-9]*)' "Home partition size in gigabytes [$home_size_default]:"
                if [ -z "$user_input" ]; then
                    conf_home_size="$home_size_default"
                else
                    conf_home_size="$user_input"
                fi
            fi
        fi
	else
		conf_home="$CONF_HOME"
		conf_home_size="$CONF_HOME_SIZE"
	fi

	if [ -z "$CONF_LTS_KERNEL" ]; then
		if print c 'N' 'Install in server mode (LTS kernel)'; then
			conf_lts_kernel='no'
		else
			conf_lts_kernel='yes'
			conf_lts='linux-lts'
		fi
	else
		conf_lts_kernel="$CONF_LTS_KERNEL"
		conf_lts="$CONF_LTS"
	fi

	if [ -z "$CONF_UEFI_ENRTY" ]; then
		if print c 'Y' 'Add direct UEFI boot entry'; then
			conf_uefi_entry='yes'
		else
			conf_uefi_entry='no'
		fi
	else
		conf_uefi_entry="$CONF_UEFI_ENRTY"
	fi

	if [ -z "$CONF_MIRRORS" ]; then
		repo_countries='AU|AT|BD|BY|BE|BA|BR|BG|CA|CL|CN|CO|HR|CZ|DK|EC|FI|FR|GE|DE|GR|HK|HU|IS|IN|ID|IR|IE|IL|IT|JP|KZ|KE|LV|LT|LU|MD|NL|NC|NZ|MK|NO|PK|PY|PH|PL|PT|RO|RU|RS|SG|SK|SI|ZA|KR|ES|SE|CH|TW|TH|TR|UA|GB|US|VN'
		repo_countries_default='DE GB'
		print i "$|( *(($repo_countries) +)*(($repo_countries) *))" "Repository mirror countries [$repo_countries_default]:"
		if [ -z "$user_input" ]; then
			conf_mirrors="$repo_countries_default"
		else
			conf_mirrors="$(echo "$user_input" | sed 's/^ *//g; s/ \+/ /g; s/ *$//g')"
		fi
	else
		conf_mirrors="$CONF_MIRRORS"
	fi

	if [ -z "$CONF_AUR" ]; then
		if print c 'Y' 'Enable Arch User Repository'; then
			conf_aur='yes'
		else
			conf_aur='no'
		fi
	else
		conf_aur="$CONF_AUR"
	fi

	if [ -z "$CONF_ADD_USER" ] && [ -z "$CONF_USER" ]; then
		if print c 'Y' 'Add primary user'; then
			conf_add_user='yes'
		else
			conf_add_user='no'
		fi
	else
		conf_add_user="$CONF_ADD_USER"
	fi

	if [ "$conf_add_user" = 'no' ]; then
		if [ "$CONF_PASS_PROVIDED" != 'true' ]; then
			print "$CONF_PASS_PROMPT" '.+' 'Enter root password:'
			conf_pass_root="$user_input"
			print "$CONF_PASS_PROMPT" '.+' 'Repeat root password:'
			repeat_pass_root="$user_input"
			[ "$conf_pass_root" = "$repeat_pass_root" ] || \
			print e 'Password mismatch!'
			CONF_PASS_PROVIDED='true'
		else
			conf_pass_root="$CONF_PASS_ROOT"
		fi
	fi

}

configure_user() {

	[ "$conf_add_user" = 'no' ] && \
	return

	print t 'User configuration'

	if [ -z "$CONF_USER" ]; then
		while [ -z "$conf_user" ]; do
			print i '[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30})' 'Username:'
			if id -u "$user_input" >/dev/null 2>/dev/null; then
				print w 'User already exists!'
			else
				conf_user="$user_input"
			fi
		done
	else
		conf_add_user='yes'
		conf_user="$CONF_USER"
	fi

	if [ -z "$CONF_PASS" ] && [ "$CONF_PASS_PROVIDED" != 'true' ]; then
		print "$CONF_PASS_PROMPT" '.*' 'Enter password:'
		conf_pass="$user_input"
		print "$CONF_PASS_PROMPT" '.*' 'Repeat password:'
		repeat_pass="$user_input"
		[ "$conf_pass" = "$repeat_pass" ] || \
		print e 'Password mismatch!'
		CONF_PASS_PROVIDED='true'
	else
		conf_pass="$CONF_PASS"
	fi

	if [ -z "$CONF_PASSWORDLESS" ]; then
		conf_passwordless='no'
		print c 'Y' 'Passwordless sudo?' && \
		conf_passwordless='yes'
	else
		conf_passwordless="$CONF_PASSWORDLESS"
	fi

	if [ -z "$CONF_SHELL" ]; then
		shell_default='zsh'
		print i '$|(bash)|(fish)|(zsh)|(ksh)|(tcsh)|(xonsh)' "Default shell [$shell_default]:"
		if [ -z "$user_input" ]; then
			conf_shell="$shell_default"
		else
			conf_shell="$user_input"
		fi
	else
		conf_shell="$CONF_SHELL"
	fi

}

configuration_summary() {

	print t 'Configuration summary'

	print s 'Host settings'
	print l 'Hostname:' "${sn}${sb}$conf_hostname"
	print l 'Timezone:' "${sn}${sb}$conf_timezone"
	print l 'Installation disk:' "${sn}${sb}$conf_disk"
	print l '2nd installation disk:' "${sn}${sb}$conf_disk_2"
    print l 'Home partition:' "${sn}${sb}$conf_home_size"
	print l 'Server mode (LTS kernel):' "${sn}${sb}$conf_lts_kernel"
	print l 'Direct UEFI boot entry:' "${sn}${sb}$conf_uefi_entry"
	print l 'Pacman mirror countries:' "${sn}${sb}$conf_mirrors"
	print l 'Arch User Repository:' "${sn}${sb}$conf_aur"
	[ "$CONF_INSECURE" = 'true' ] && [ "$conf_add_user" = 'no' ] && \
	print l 'Root password:' "${sn}${sb}${conf_pass_root:-${cy}empty}"

	if [ "$conf_add_user" = 'yes' ]; then
		print s 'User settings'
		print l 'Username:' "${sn}${sb}$conf_user"
		[ "$CONF_INSECURE" = 'true' ] && \
		print l 'Password:' "${sn}${sb}${conf_pass:-${cy}empty}"
		print l 'Passwordless sudo:' "${sn}${sb}$conf_passwordless"
		print l 'Shell:' "${sn}${sb}$conf_shell"
	else
		print l 'Add primary user:' "${sn}${sb}$conf_add_user"
	fi

	if [ -n "$CONF_CHROOT" ]; then
		print s 'Post installation'
		if [ -n "$CONF_CHROOT" ]; then
			print l 'Chroot into system:' "${sn}${sb}$CONF_CHROOT"
		fi
	fi

	if [ "$CONF_SKIP_CONFIRMATION" != 'true' ]; then
		print w 'Warning: proceeding with the installation'
		print w 'will wipe all data from the installation disk!'
		print w 'Type YES to continue.'
		print i '.*' 'Continue?'
		[ "$user_input" = 'YES' ] || \
		print e 'Aborting installation!'
	fi

}

logfile() {

	CONF_LOGFILE=$(mktemp /tmp/install-system.XXX.log)

}

pre_installation() {

	print t 'Preparing installation' && \

	print s 'Update the system clock' && \
	timedatectl set-ntp true &>> "$CONF_LOGFILE" && \

	print s 'Update installer repository mirrors' && \
	mirror_country_url="$(echo "$conf_mirrors" | awk '{for (i=1;i<NF;i++) {query=query "&country=" $i}} END {print query}')" && \
	curl -L "https://www.archlinux.org/mirrorlist/?protocol=https&ip_version=4&ip_version=6&use_mirror_status=on$mirror_country_url" 2>> "$CONF_LOGFILE" | sed 's/^#//' > /etc/pacman.d/mirrorlist && \

	print s 'Prepare required packages' && \
	pacman -Sy --noconfirm --needed arch-install-scripts dosfstools btrfs-progs zstd gptfdisk curl awk efibootmgr &>> "$CONF_LOGFILE" && \

	print s 'Unmount all partitions on disk' && {
		umount -R /mnt &>> "$CONF_LOGFILE" || \
		umount -Rv "/dev/$conf_disk"?* &>> "$CONF_LOGFILE" || \
		umount -Rv "/dev/$conf_disk_2"?* &>> "$CONF_LOGFILE" || \
		true
	} && \

	print s 'Format disk' && \
	sgdisk --zap-all "/dev/$conf_disk" &>> "$CONF_LOGFILE" &&\
	sgdisk --zap-all "/dev/$conf_disk_2" &>> "$CONF_LOGFILE" &&\
	sgdisk "/dev/$conf_disk" -o -n 1:0:512M -t 1:ef00 -N 2 -t "2:8303" &>> "$CONF_LOGFILE" && \
	sgdisk "/dev/$conf_disk_2" -o -N 1 -t "1:8303" &>> "$CONF_LOGFILE" && \

	print s 'Format boot partition' && \
	yes | mkfs.vfat -F32 -n EFI "/dev/${conf_disk}${part_prefix}1" && \

	print s 'Format root partition & label it' && \
	mkfs.btrfs -L "archlinux" -d raid0 -m raid0 -f "/dev/${conf_disk}${part_prefix}2" "/dev/${conf_disk_2}${part_prefix_2}1" && \

	print s 'Mount partitions' && \
	mount "/dev/${conf_disk}${part_prefix}2" /mnt && \
	btrfs sub cr /mnt/@ && \
	btrfs sub cr /mnt/@tmp && \
	btrfs sub cr /mnt/@log && \
	btrfs sub cr /mnt/@pkg && \
	btrfs sub cr /mnt/@snapshots && \
	btrfs sub cr /mnt/@home && \
	umount /mnt && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvol=@ "/dev/${conf_disk}${part_prefix}2" /mnt && \
	mkdir -p /mnt/{boot/efi,boot/loader/entries,home,var/log,var/cache/pacman/pkg,btrfs,tmp,etc/tmpfiles.d} && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvol=@log "/dev/${conf_disk}${part_prefix}2" /mnt/var/log && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvol=@pkg "/dev/${conf_disk}${part_prefix}2" /mnt/var/cache/pacman/pkg && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvol=@tmp "/dev/${conf_disk}${part_prefix}2" /mnt/tmp && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvol=@home "/dev/${conf_disk}${part_prefix}2" /mnt/home && \
	mount -o relatime,space_cache=v2,ssd,compress-force=zstd,subvolid=5 "/dev/${conf_disk}${part_prefix}2" /mnt/btrfs && \
	mount "/dev/${conf_disk}${part_prefix}1" /mnt/boot && \
	print s 'Removing tmp files on reboot' && {
	tee -a /mnt/etc/tmpfiles.d/tmp.conf << END
D! /tmp 1777 root root 0
END
	} \
}

installation() {

	print t 'Installing system' && \

	print s 'Install Arch Linux base system' && \
	if [ "$conf_lts_kernel" = 'yes' ]; then
		pacstrap /mnt base base-devel linux-lts booster linux-firmware btrfs-progs zstd networkmanager sudo nano $conf_shell &>> "$CONF_LOGFILE"
	else
		pacstrap /mnt base base-devel linux-zen booster linux-firmware btrfs-progs zstd networkmanager sudo nano $conf_shell &>> "$CONF_LOGFILE"
	fi && \

	print s 'Enable NetworkManager service' && \
	arch-chroot /mnt systemctl enable NetworkManager &>> "$CONF_LOGFILE" && \

	print s 'Generate fstab entries' && \
	genfstab -U /mnt >> /mnt/etc/fstab && \

	print s 'Set timezone' && \
	ln -sf "/usr/share/zoneinfo/$conf_timezone" /mnt/etc/localtime &>> "$CONF_LOGFILE" && \
	arch-chroot /mnt hwclock --systohc &>> "$CONF_LOGFILE" && \

	print s 'Configure localization' && \
	echo 'en_US.UTF-8 UTF-8' >> /mnt/etc/locale.gen && \
	arch-chroot /mnt locale-gen &>> "$CONF_LOGFILE" && \
	echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf && \

	print s 'Set default console font' && {
	tee -a /mnt/etc/vconsole.conf &>> "$CONF_LOGFILE" << END
KEYMAP=us
FONT=default8x16
END
	} && \

	print s 'Set hostname and populate hosts file' && \
	echo "$conf_hostname" > /mnt/etc/hostname && {
	tee -a /mnt/etc/hosts &>> "$CONF_LOGFILE" << END
127.0.0.1   localhost
::1         localhost
127.0.1.1   $conf_hostname.localdomain $conf_hostname
END
	} && \
	print s 'Configure pacman and makepkg' && \
	curl -L "https://www.archlinux.org/mirrorlist/?protocol=https&ip_version=4&ip_version=6&use_mirror_status=on$mirror_country_url" 2>> "$CONF_LOGFILE" | sed 's/^#//' > /mnt/etc/pacman.d/mirrorlist && \
	sed 's/[ \t#]*MAKEFLAGS.*$/MAKEFLAGS="-j$(nproc)"/' -i /mnt/etc/makepkg.conf && \
	sed 's/^#Color$/Color/; s/^#TotalDownload$/TotalDownload/; s/^#VerbosePkgLists$/VerbosePkgLists/;' -i /mnt/etc/pacman.conf && \

	print s 'Detect CPU vendor and install microcode' && {
	grep -qi 'vendor.*intel' /proc/cpuinfo && cpu_vendor='intel'
	grep -qi 'vendor.*amd' /proc/cpuinfo && cpu_vendor='amd'
	[ -n "$cpu_vendor" ] && arch-chroot /mnt pacman -Sy --noconfirm --needed "${cpu_vendor}-ucode" &>> "$CONF_LOGFILE"
	true
	} && \
	print s 'Setup bootloader' && \
	arch-chroot /mnt bootctl install &>> "$CONF_LOGFILE" && {
	tee /mnt/boot/loader/loader.conf &>> "$CONF_LOGFILE" << END
timeout 0
default arch
END
	} &&
	root_volume="root=LABEL=archlinux"
	if [ "$conf_lts_kernel" = 'yes' ]; then
		tee /mnt/boot/loader/entries/arch.conf &>> "$CONF_LOGFILE" << END
title    Arch Linux (LTS)
linux    /vmlinuz-linux-lts
$([ -n "$cpu_vendor" ] && echo "initrd   /${cpu_vendor}-ucode.img")
initrd   /booster-linux-lts.img
options  $root_volume rw rootflags=subvol=@ intel_iommu=on vfio-pci.ids=10de:1401,10de:0fba add_efi_memmap
END
	else
		tee /mnt/boot/loader/entries/arch.conf &>> "$CONF_LOGFILE" << END
title    Arch Linux
linux    /vmlinuz-linux-zen
$([ -n "$cpu_vendor" ] && echo "initrd   /${cpu_vendor}-ucode.img")
initrd   /booster-linux-zen.img
options  $root_volume rw rootflags=subvol=@ quiet loglevel=3 add_efi_memmap
END
	fi && \

	if [ "$conf_uefi_entry" = 'yes' ]; then
		print s 'Create direct UEFI boot entry' && \
		root_volume="root=LABEL=archlinux"
		if [ "$conf_lts_kernel" = 'yes' ]; then
			efibootmgr --disk "/dev/${conf_disk}${part_prefix}" --part 1 --create --label 'Arch (LTS)' --loader '/vmlinuz-linux-lts' --unicode "${root_volume} rw rootflags=subvol=@ intel_iommu=on vfio-pci.ids=10de:1401,10de:0fba add_efi_memmap initrd=\\${cpu_vendor}-ucode.img initrd=\booster-linux-lts.img" --verbose  &>> "$CONF_LOGFILE"
		else
			efibootmgr --disk "/dev/${conf_disk}${part_prefix}" --part 1 --create --label 'Arch' --loader '/vmlinuz-linux-zen' --unicode "${root_volume} rw rootflags=subvol=@ quiet loglevel=3 add_efi_memmap initrd=\\${cpu_vendor}-ucode.img initrd=\booster-linux-zen.img" --verbose  &>> "$CONF_LOGFILE"
		fi
	fi && \

	if [ "$conf_add_user" = 'yes' ]; then
		print s 'Create user account' && \
		arch-chroot /mnt useradd -m -u 1000 -U -s "/usr/bin/$conf_shell" "$conf_user" &>> "$CONF_LOGFILE" && \
		if [ -z "$conf_pass" ]; then
			arch-chroot /mnt passwd -d "$conf_user" &>> "$CONF_LOGFILE"
		else
			arch-chroot /mnt su -c "echo '$conf_user:$conf_pass' | chpasswd" &>> "$CONF_LOGFILE"
		fi && \
		if [ "$conf_passwordless" = 'yes' ]; then
			echo "$conf_user ALL=(ALL) NOPASSWD: ALL" > "/mnt/etc/sudoers.d/$conf_user"
		else
			echo "$conf_user ALL=(ALL) ALL" > "/mnt/etc/sudoers.d/$conf_user"
		fi
	else
		print s 'Set root password' && \
		if [ -z "$conf_pass_root" ]; then
			arch-chroot /mnt passwd -d root
		else
			arch-chroot /mnt su -c "echo 'root:$conf_pass_root' | chpasswd"
		fi
	fi && \

	if [ "$conf_aur" = 'yes' ]; then
		print s 'Enable Arch User Repository' && \
		pacman -Sy --noconfirm --needed fakeroot binutils git &>> "$CONF_LOGFILE" && \
		useradd -m builder &>> "$CONF_LOGFILE" && \
		su builder -c '
			cd ~ &&
			git clone https://aur.archlinux.org/paru-bin.git &&
			cd paru-bin &&
			makepkg
		' &>> "$CONF_LOGFILE" && \
		aur_helper_package="$(find /home/builder/paru-bin -name '*.pkg.*' -printf '%P')" && \
		mkdir -p /mnt/var/cache/pacman/pkg &>> "$CONF_LOGFILE" && \
		mv "/home/builder/paru-bin/$aur_helper_package" "/mnt/var/cache/pacman/pkg/$aur_helper_package" &>> "$CONF_LOGFILE" && \
		arch-chroot /mnt pacman -U "/var/cache/pacman/pkg/$aur_helper_package" --noconfirm &>> "$CONF_LOGFILE" && \
		rm -f "/mnt/var/cache/pacman/pkg/$aur_helper_package" &>> "$CONF_LOGFILE" && \
		print w "Use ${cw}paru${cy} to install packages from Arch User Repository"
	fi

}

post_installation() {

	print t 'Post installation'

	if [ -z "$CONF_CHROOT" ]; then
		print c 'N' 'Chroot into system for manual modifications?' || \
		arch-chroot /mnt "/usr/bin/${conf_shell:-bash}"
	elif [ "$CONF_CHROOT" = 'yes' ]; then
		arch-chroot /mnt "/usr/bin/${conf_shell:-bash}"
	fi

	preferences_write || \
	print w 'Warning: Unable to save configuration to file'

	print s 'Unmount filesystem'
	umount -R /mnt && \

	print s 'Installation complete' && \
	print w 'Reboot and eject your installation media'

}

preferences_write() {

	if [ -n "$CONF_PREFSWFILE" ] && touch "$CONF_PREFSWFILE"; then

		print s 'Exporting configuration to file'

		mkdir -p "$(dirname "$CONF_PREFSWFILE")" && \
		tee "$CONF_PREFSWFILE" &>> "$CONF_LOGFILE" << END
[installer]
version =		"$CONF_VERSION"

[host]
hostname =		"$conf_hostname"
timezone =		"$conf_timezone"
disk =			"$conf_disk"
home =			"$conf_home"
home_size =		"$conf_home_size"
lts_kernel = 		"$conf_lts_kernel"
lts =			"$conf_lts"
uefi_entry = 		"$conf_uefi_entry"
mirrors =		"$conf_mirrors"
aur = 			"$conf_aur"
add_user = 		"$conf_add_user"

[user]
user = 			"$conf_user"
pass = 			"$conf_pass"
pass_root = 		"$conf_pass_root"
pass_provided =		"$CONF_PASS_PROVIDED"
passwordless = 		"$conf_passwordless"
shell = 		"$conf_shell"

[misc]
skip_confirmation = 	"$CONF_SKIP_CONFIRMATION"
END

fi

}

preferences_read() {

	if [ -n "$CONF_PREFSRFILE" ]; then

		print s 'Importing configuration from file'
		if test -f "$CONF_PREFSRFILE"; then
			conf_prefsrfile="$CONF_PREFSRFILE"
		else
			conf_prefsrfile="$(mktemp /tmp/install-system-preferences.XXX.toml)"
			if ! curl -L "$CONF_PREFSRFILE" > "$conf_prefsrfile" 2> "$CONF_LOGFILE"; then
				print e "Unable to fetch configuration file: '$CONF_PREFSRFILE'"
			fi
		fi

		if test -f "$conf_prefsrfile" && head -n1 "$conf_prefsrfile" | grep -qz '^\[installer\]'; then

			regex_match='[ \t]*=[ \t]*"\(.*\)"$/\1/p'

			CONV_PREFSVER="$(sed -n "s/^version$regex_match" "$conf_prefsrfile")"

			if [ "$CONV_PREFSVER" = "$(printf "%s\n%s" "$CONV_PREFSVER" "$CONF_VERSION" | sort -V | head -n1)" ]; then
				[ "$CONV_PREFSVER" != "$CONF_VERSION" ] && \
				print w 'Caution: Compatibility mode with older version.'
			else
				print e "Newer configuration file: $CONV_PREFSVER > $CONF_VERSION"
			fi

			[ -z "$CONF_HOSTNAME" ] && \
				CONF_HOSTNAME="$(sed -n "s/^hostname$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_TIMEZONE" ] && \
				CONF_TIMEZONE="$(sed -n "s/^timezone$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_DISK" ] && \
				CONF_DISK="$(sed -n "s/^disk$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_DISK_2" ] && \
				CONF_DISK_2="$(sed -n "s/^disk$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_HOME" ] && \
				CONF_HOME="$(sed -n "s/^home$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_HOME_SIZE" ] && \
				CONF_HOME_SIZE="$(sed -n "s/^home_size$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_LTS_KERNEL" ] && \
				CONF_LTS_KERNEL="$(sed -n "s/^lts_kernel$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_LTS" ] && \
				CONF_LTS="$(sed -n "s/^lts$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_UEFI_ENRTY" ] && \
				CONF_UEFI_ENRTY="$(sed -n "s/^uefi_entry$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_MIRRORS" ] && \
				CONF_MIRRORS="$(sed -n "s/^mirrors$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_AUR" ] && \
				CONF_AUR="$(sed -n "s/^aur$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_ADD_USER" ] && \
				CONF_ADD_USER="$(sed -n "s/^add_user$regex_match" "$conf_prefsrfile")"
			
			[ -z "$CONF_USER" ] && \
				CONF_USER="$(sed -n "s/^user$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_PASS" ] && \
				CONF_PASS="$(sed -n "s/^pass$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_PASS_ROOT" ] && \
				CONF_PASS_ROOT="$(sed -n "s/^pass_root$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_PASS_PROVIDED" ] && \
				CONF_PASS_PROVIDED="$(sed -n "s/^pass_provided$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_PASSWORDLESS" ] && \
				CONF_PASSWORDLESS="$(sed -n "s/^passwordless$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_SHELL" ] && \
				CONF_SHELL="$(sed -n "s/^shell$regex_match" "$conf_prefsrfile")"
			[ -z "$CONF_SKIP_CONFIRMATION" ] && \
				CONF_SKIP_CONFIRMATION="$(sed -n "s/^skip_confirmation$regex_match" "$conf_prefsrfile")"

		else
			print e "Invalid configuration file: '$CONF_PREFSRFILE'"
		fi
	fi

}

parse_options "$@" && check_environment && logfile && preferences_read && \
configure_host && configure_user && configuration_summary && \
pre_installation && installation && post_installation || {
	print w "Log file: ${sn}${sb}$CONF_LOGFILE"
	print e 'Fatal error, halting installation!'
}

exit
