#!/bin/bash
#
#  Install script for OnMyShelf docker
#  https://onmyshelf.cm
#

cd "$(dirname "$0")" || exit


#
#  Functions
#

print_help() {
	echo "$0 [OPTIONS]"
	echo "Options:"
	echo "   -y, --yes   Do not print confirmation, non interactive install"
	echo "   -h, --help  Print this help"
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


#
#  Main program
#

interactive=true

while [ -n "$1" ] ; do
	case $1 in
		-y|--yes)
			interactive=false
			;;
		*)
			print_help
			exit
			;;
	esac
	shift
done

if ! [ -f .env ] ; then
	echo "Copy environment variable..."
	cp env.example .env || exit
fi

if $interactive ; then
	# TODO: steps to configure OnMyShelf
	true
fi

echo "Starting OnMyShelf..."
docker-compose up -d || exit

echo
echo "OnMyShelf is ready!"
