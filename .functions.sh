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


# Returns docker compose command
compose_command() {
	# check if compose plugin is installed
	docker compose version &> /dev/null
	if [ $? = 0 ] ; then
		echo docker compose
		return 0
	fi

	# if not, try old docker-compose
	docker-compose version &> /dev/null
	if [ $? = 0 ] ; then
		echo docker-compose
		return 0
	fi

	return 1
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
	$compose_command pull || exit

	echo
	echo "Starting OnMyShelf..."
	$compose_command up -d || exit

	echo
	echo "Waiting to be ready..."
	for i in $(seq 1 50) ; do
		$compose_command logs server 2> /dev/null | grep -q "Starting Apache server" && break
		sleep 1
	done

	# recheck
	if ! $compose_command ps server | grep -Eq '(healthy|running)' ; then
		echo "Failed to start! Check the logs with the command: $compose_command logs"
		exit 3
	fi

	# get server url
	url=$(get_config HTTP_PORT)
	echo $url | grep -q : || url=localhost:$url

	echo
	echo "OnMyShelf is ready!"
	echo "Check it now: http://$url"
}


# initialize compose command
compose_command=$(compose_command)
