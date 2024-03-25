# Check if command(s) exists
# Usage: lb_command_exists COMMAND [COMMAND...]
lb_command_exists() {
	which "$@" &> /dev/null
}


# Edit a file with sed command
# Usage: lb_edit PATTERN FILE
lb_edit() {
	# usage error
	[ $# -lt 2 ] && return 1

	# Test sed command
	sed --version &> /dev/null
	case $? in
		0)
			# normal sed command
			lb__oldsed=false
			;;
		127)
			# command sed not found
			lb_error "libbash.sh: [ERROR] cannot found sed command. Some functions will not work properly."
			lb__load_result=2
			;;
		*)
			# old sed command (mostly on macOS)
			lb__oldsed=true
			;;
	esac

	if [ "$lb__oldsed" = true ] ; then
		sed -i '' "$@"
	else
		sed -i "$@"
	fi
}


# Ask a question to user to answer by yes or no
# Usage: lb_yesno [OPTIONS] TEXT
lb_yesno() {
	# default options
	local yes_default=false cancel_mode=false
	local yes_label=$lb__yes_shortlabel no_label=$lb__no_shortlabel cancel_label=$lb__cancel_shortlabel

	# set labels if missing
	[ -z "$yes_label" ] && yes_label=y
	[ -z "$no_label" ] && no_label=n
	[ -z "$cancel_label" ] && cancel_label=c

	# get options
	while [ $# -gt 0 ] ; do
		case $1 in
			-y|--yes)
				yes_default=true
				;;
			-c|--cancel)
				cancel_mode=true
				;;
			--yes-label)
				[ -z "$2" ] && return 1
				yes_label=$2
				shift
				;;
			--no-label)
				[ -z "$2" ] && return 1
				no_label=$2
				shift
				;;
			--cancel-label)
				[ -z "$2" ] && return 1
				cancel_label=$2
				shift
				;;
			*)
				break
				;;
		esac
		shift # load next argument
	done

	# question is missing
	[ -z "$1" ] && return 1

	# print question (if not quiet mode)
	if [ "$lb_quietmode" != true ] ; then
		# defines question
		local question
		if $yes_default ; then
			question="$(echo "$yes_label" | tr '[:lower:]' '[:upper:]')/$(echo "$no_label" | tr '[:upper:]' '[:lower:]')"
		else
			question="$(echo "$yes_label" | tr '[:upper:]' '[:lower:]')/$(echo "$no_label" | tr '[:lower:]' '[:upper:]')"
		fi

		# add cancel choice
		$cancel_mode && question+="/$(echo "$cancel_label" | tr '[:upper:]' '[:lower:]')"

		# print question
		echo -e -n "$* ($question): "
	fi

	# read user input
	local choice
	read choice

	# defaut behaviour if input is empty
	if [ -z "$choice" ] ; then
		if $yes_default ; then
			return 0
		else
			return 2
		fi
	fi

	# compare to confirmation string
	if [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" != "$(echo "$yes_label" | tr '[:upper:]' '[:lower:]')" ] ; then

		# cancel case
		if $cancel_mode && [ "$(echo "$choice" | tr '[:upper:]' '[:lower:]')" = "$(echo "$cancel_label" | tr '[:upper:]' '[:lower:]')" ] ; then
			return 3
		fi

		# answer is no
		return 2
	fi
}


# Get parameter from config file
# Usage: get_config PARAM
get_config() {
	grep -E "^$1=" .env 2> /dev/null | cut -d= -f2
}


# Set parameter in config file
# Usage: set_config PARAM VALUE
set_config() {
	# check if line exists
	if grep -q "$1=" .env ; then
		lb_edit "s/^#*$1=.*/$1=$2/" .env
	else
		# line does not exists: insert in file
		echo "$1=$2" >> .env
	fi

	if [ $? != 0 ] ; then
		echo "Failed to change $1=$2. Please make this change in .env file manually and retry."
		return 1
	fi
}


# Installs a package
# Usage: install_pkg PACKAGE
install_pkg() {
	local cmd

	# try to find package manager
	for cmd in apt-get dnf yum apk notfound ; do
		lb_command_exists $cmd && break
	done

	case $cmd in
		apt-get)
			if [ $1 = docker ] ; then
				# on debian family, the docker package is named docker.io
				apt-get install -y docker.io
			else
				apt-get install -y $1
			fi
			;;
		dnf|yum)
			$cmd install -y $1
			;;
		apk)
			apk add $1
			;;
		*)
			echo "Package manager not found! Please install $1 manually."
			return 1
			;;
	esac
}


# Change version
change_version() {
	# ignore if not defined
	[ -z "$version" ] && return 0

	# change version if needed
	if [ "$version" != "$(get_config VERSION)" ] ; then
		set_config VERSION "$version" || exit
	fi
}


# Update git project
pull_project() {
	# ignore if git not installed
	lb_command_exists git || return 0

	# ignore if .git does not exists (if installed from a zip archive)
	[ -d .git ] || return 0

	echo "Update project..."
	git pull
	echo
}


# Start OnMyShelf
start_server() {
	echo
	echo "Pulling docker image..."
	docker compose pull || exit

	echo
	echo "Starting OnMyShelf..."
	docker compose up -d || exit

	echo
	echo "Waiting to be ready..."
	ready=false
	for i in $(seq 1 50) ; do
		sleep 1
		# check logs to see if Apache is ready
		docker compose logs server 2> /dev/null | grep -q "Starting Apache server" || continue
		
		# check container status
		docker compose ps server | grep -Eq '(healthy|running)' || continue
		
		# ready: quit loop
		ready=true
		break
	done

	if ! $ready ; then
		echo "Failed to start! Check the logs with the command: docker compose logs"
		exit 3
	fi

	# get server url
	url=$(get_config HTTP_PORT)
	echo $url | grep -q : || url=localhost:$url

	echo
	echo "OnMyShelf is ready!"
	echo "Check it now: http://$url"
}


# check if docker command exists
if ! lb_command_exists docker ; then
	echo "Docker is required but seems to be missing on this system."
	lb_yesno "Do you want to install it?" || exit 1

	install_pkg docker
	echo

	# re-check docker command
	if ! lb_command_exists docker ; then
		echo "Failed to find docker command."
		echo "Please install it manually: https://docs.docker.com/get-docker/"
		exit 1
	fi
fi

# check if docker compose command exists
if ! docker compose version &> /dev/null ; then
	echo "The docker compose tool is required but seems to be missing on this system."
	lb_yesno "Do you want to install it?" || exit 1
	
	install_pkg docker-compose-plugin
	echo

	# re-check if docker compose command exists
	if ! docker compose version &> /dev/null ; then
		echo "Failed to find docker compose command."
		echo "Please install it manually: https://docs.docker.com/compose/install/"
		exit 1
	fi
fi
