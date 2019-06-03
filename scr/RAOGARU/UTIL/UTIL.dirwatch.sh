# ############################################################
# UTIL DIRWATCH FUNCTIONS - Directory Watch and Execute Commands
# ############################################################
# ------------------------------------------------------------
# UTIL DIRWATCH actions
action_L1="xx "
action_L2="yy "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
xx,none,xx_description \
yy,none,yy_description \
zz,none,zz_description \
"
# ------------------------------------------------------------
# Global variable overwrites

# ------------------------------------------------------------
# Module specific environment variables

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
f_module_action () {
INPUT
ECHO "not coded yet"
}
# ------------------------------------------------------------

# Be strict
set -e
set -u
set -o pipefail

# Required to loop over newlines instead of spaces
IFS=$'\n'

############################################################
# Variables
############################################################

# Versioning
MY_NAME="watcherd"
MY_DATE="2017-09-30"
MY_URL="https://github.com/devilbox/watcherd"
MY_AUTHOR="cytopia <cytopia@everythingcli.org>"
MY_GPGKEY="0xA02C56F0"
MY_VERSION="0.1"
MY_LICENSE="MIT"

# Default settings
INTERVAL=1
VERBOSE=0
WATCHER="bash"
WATCH_DIR=
CMD_ADD=
CMD_DEL=
CMD_TRIGGER=

# Do not create subshell when comparing directories
# This is useful when running this script by supervisord
# as it would otherwise see too many process spawns.
WITHOUT_SUBSHELL=1



############################################################
# Functions
############################################################

function print_help() {
	printf "Usage: %s %s\n" "${MY_NAME}" "-p <path> -a <cmd> -d <cmd> [-t <cmd> -w <str> -i <int> -v]"
	printf "       %s %s\n" "${MY_NAME}" "--help"
	printf "       %s %s\n" "${MY_NAME}" "--version"
	printf "\n"
	printf "%s\n" "${MY_NAME} will look for directory changes (added and deleted directories) under the specified"
	printf "path (-p) and will execute specified commands or shell scripts (-a, -d) depending on the event.\n"
	printf "Once all events have happened during one round (-i), a trigger command can be executed (-t).\n"
	printf "Note, the trigger command will only be execute when at least one add or delete command has succeeded with exit code 0."
	printf "\n"
	printf "\nRequired arguments:\n"
	printf "  -p <path>     %s\n" "Path to directoy to watch for changes."
	printf "  -a <cmd>      %s\n" "Command to execute when a directory was added."
	printf "                %s\n" "You can also append the following placeholders to your command string:"
	printf "                %s\n" "%p The full path of the directory that changed (added, deleted)."
	printf "                %s\n" "%n The name of the directory that changed (added, deleted)."
	printf "                %s\n" "Example: -a \"script.sh -f %p -c %n -a %p\""
	printf "  -d <cmd>      %s\n" "Command to execute when a directory was deletd."
	printf "                %s\n" "You can also append the following placeholders to your command string:"
	printf "                %s\n" "%p The full path of the directory that changed (added, deleted)."
	printf "                %s\n" "%n The name of the directory that changed (added, deleted)."
	printf "                %s\n" "Example: -b \"script.sh -f %p -c %n -a %p\""
	printf "\nOptional arguments:\n"
	printf "  -t <cmd>      %s\n" "Command to execute after all directories have been added or deleted during one round."
	printf "                %s\n" "No argument will be appended."
	printf "  -w <str>      %s\n" "The directory watcher to use. Valid values are:"
	printf "                %s\n" "'inotify': Uses inotifywait to watch for directory changes."
	printf "                %s\n" "'bash':    Uses a bash loop to watch for directory changes."
	printf "                %s\n" "The default is to use 'bash' as the watcher."
	printf "  -i <int>      %s\n" "When using the bash watcher, specify the interval in seconds for how often"
	printf "                %s\n" "to look for directory changes."
	printf "  -v            %s\n" "Verbose output."
	printf "\nMisc arguments:\n"
	printf "  --help        %s\n" "Show this help screen."
	printf "  --version     %s\n" "Show version information."
}

function print_version() {
	printf "Name:    %s\n" "${MY_NAME}"
	printf "Version: %s (%s)\n" "${MY_VERSION}" "${MY_DATE}"
	printf "Author:  %s (%s)\n" "${MY_AUTHOR}" "${MY_GPGKEY}"
	printf "License: %s\n" "${MY_LICENSE}"
	printf "URL:     %s\n" "${MY_URL}"
}

function get_subdirs() {
	local path="${1}"
	find "${path}" -type d \! -name "$( basename "${path}" )" -prune | sort
}

function action() {
	local directory="${1}"  # Directory to work on
	local action="${2}"     # Add/Del command to execute
	local info="${3}"       # Output text (ADD or DEL) for verbose mode
	local verbose="${4}"    # Verbose?
	local name
	name="$( basename "${directory}" )"

	# Fill with placeholder values
	action="${action//%p/${directory}}"
	action="${action//%n/${name}}"

	if eval "${action}"; then
		if [ "${verbose}" -gt "0" ]; then
			printf "%s: [%s] [OK]  %s succeeded: %s\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )" "${info}" "${directory}"
		fi
		return 0
	else
		if [ "${verbose}" -gt "0" ]; then
			printf "%s: [%s] [ERR] %s failed:    %s\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )" "${info}" "${directory}"
		fi
		return 1
	fi
}

function trigger() {
	local action="${1}"    # Trigger command to run
	local changes="${2}"   # Only run trigger when changes == 1
	local verbose="${3}"   # Verbose?

	# Only run trigger when command has been specified (not empty)
	if [ -n "${action}" ]; then
		if [ "${changes}" -eq "1" ]; then
			if  eval "${action}"; then
				if [ "${verbose}" -gt "0" ]; then
					printf "%s: [%s] [OK]  %s succeeded: %s\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )" "TRIGGER" "${action}"
				fi
				return 0
			else
				if [ "${verbose}" -gt "0" ]; then
					printf "%s: [%s] [ERR] %s failed:    %s\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )" "TRIGGER" "${action}"
				fi
				# Also return 0 here in order to not abort the loop
				return 0
			fi
		fi
	fi
}



############################################################
# Read command line arguments
############################################################

while [ $# -gt 0  ]; do
	case "${1}" in
		-p)
			shift
			if [ ! -d "${1}" ]; then
				>&2 echo "Specified directory with -p does not exist: '${1}'."
				exit 1
			fi
			WATCH_DIR="${1}"
			;;
		-a)
			shift
			if [ "${1:0:1}" = "-" ]; then
				>&2 echo "Specified add command cannot start with '-': '${1}'."
				exit 1
			fi
			CMD_ADD="${1}"
			;;
		-d)
			shift
			if [ "${1:0:1}" = "-" ]; then
				>&2 echo "Specified del command cannot start with '-': '${1}'."
				exit 1
			fi
			CMD_DEL="${1}"
			;;
		-t)
			shift
			if [ "${1:0:1}" = "-" ]; then
				>&2 echo "Specified trigger command cannot start with '-': '${1}'."
				exit 1
			fi
			CMD_TRIGGER="${1}"
			;;
		-w)
			shift
			if [ "${1}" != "bash" ] && [ "${1}" != "inotify" ]; then
				>&2 echo "Specified watcher with -w must either be 'bash; or 'inotify': '${1}'."
				exit
			fi
			if [ "${1}" = "inotify" ]; then
				if ! command -v inotifywait >/dev/null 2>&1; then
					>&2 echo "Specified watcher 'inotify' requires 'inotifywait' binary. Not found."
					exit
				fi
			fi
			WATCHER="${1}"
			;;
		-i)
			shift
			if ! echo "${1}" | grep -Eq '^[1-9][0-9]*$'; then
				>&2 echo "Specified interval with -i is not a valid integer > 0: '${1}'."
				exit 1
			fi
			INTERVAL="${1}"
			;;
		-v)
			VERBOSE="1"
			;;
		--help)
			print_help
			exit 0
			;;
		--version)
			print_version
			exit 0
			;;
		*)
			echo "Invalid argument: ${1}"
			echo "Type '${MY_NAME} --help' for available options."
			exit 1
			;;
	esac
	shift
done

# Make sure required arguments are set
if [ -z "${WATCH_DIR}" ]; then
	>&2 echo "Error: -p is required. Type --help for more information."
	exit 1
fi
if [ -z "${CMD_ADD}" ]; then
	>&2 echo "Error: -a is required. Type --help for more information."
	exit 1
fi
if [ -z "${CMD_DEL}" ]; then
	>&2 echo "Error: -d is required. Type --help for more information."
	exit 1
fi



############################################################
# Main entrypoint
############################################################

# Log startup
if [ "${VERBOSE}" -gt "0" ]; then
	printf "%s: [%s] Starting daemon.\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )"
fi


CHANGES=0
ALL_DIRS="$( get_subdirs "${WATCH_DIR}" )"

if [ "${WITHOUT_SUBSHELL}" -eq "1" ]; then
	LFT_FILE="$( mktemp )"
	RGT_FILE="$( mktemp )"
fi

# Initial add
for d in ${ALL_DIRS}; do
	# Only CHANGE if adding was successful
	if action "${d}" "${CMD_ADD}" "ADD:" "${VERBOSE}"; then
		CHANGES=1
	fi
done
trigger "${CMD_TRIGGER}" "${CHANGES}" "${VERBOSE}"
CHANGES=0


###
### Endless loop over changes
###

	if [ "${VERBOSE}" -gt "0" ]; then
		printf "%s: [%s] Using bash loop to watch for changes.\n" "${MY_NAME}" "$( date '+%Y-%m-%d %H:%M:%S' )"
	fi
	while true; do
		# Get all directories
		NEW_DIRS="$( get_subdirs "${WATCH_DIR}" )"

		# Compare against previously read directories
		if [ "${WITHOUT_SUBSHELL}" -eq "1" ]; then
			echo "${ALL_DIRS}" > "${LFT_FILE}"
			echo "${NEW_DIRS}" > "${RGT_FILE}"
			ADD_DIRS="$( comm -13 "${LFT_FILE}" "${RGT_FILE}" )"
			DEL_DIRS="$( comm -23 "${LFT_FILE}" "${RGT_FILE}" )"
		else
			ADD_DIRS="$( comm -13 <(echo "${ALL_DIRS}") <(echo "${NEW_DIRS}") )"
			DEL_DIRS="$( comm -23 <(echo "${ALL_DIRS}") <(echo "${NEW_DIRS}") )"
		fi

		# Run ADD command
		for d in $ADD_DIRS; do
			if action "${d}" "${CMD_ADD}" "ADD:" "${VERBOSE}"; then
				CHANGES=1
			fi
		done

		# Run DEL command
		for d in $DEL_DIRS; do
			if action "${d}" "${CMD_DEL}" "DEL:" "${VERBOSE}"; then
				CHANGES=1
			fi
		done

		# Trigger if changes are present
		trigger "${CMD_TRIGGER}" "${CHANGES}" "${VERBOSE}"

		# Reset changes
		CHANGES=0

		# Update index to currently existing directories
		ALL_DIRS="${NEW_DIRS}"

		# Wait before restarting loop
		sleep "${INTERVAL}"
	done
