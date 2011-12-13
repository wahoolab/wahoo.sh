
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

touch ~/wahoo_setup.log && chmod 600 ~/wahoo_setup.log

function setuplog {
   echo "$(date) ${1}" >> ~/wahoo_setup.log
}

function first_file_found {
   # SEARCH_PATHS="/bin /usr /"
   SEARCH_PATHS="${1}"
   # FILE_NAMES="mail mailx"
   FILE_NAMES="${2}"
   for FILE_NAME in ${FILE_NAMES} ; do
      for SEARCH_PATH in ${SEARCH_PATHS}; do
	 if [[ -d ${SEARCH_PATH} ]]; then
	    RESULT=$(find ${SEARCH_PATH} -type f -name ${FILE_NAME} 2> /dev/null | tail -1)
	 fi
	 [[ -n ${RESULT} ]] && break
      done
      [[ -n ${RESULT} ]] && break
   done
   setuplog "first_file_found looked in ${SEARCH_PATH} for files ${FILE_NAMES} and RESULT=${RESULT}"
   echo ${RESULT}
}

if [[ $0 != ".wahoo-setup.sh" && $0 != "./.wahoo-setup.sh" && $0 != $(pwd)/.wahoo-setup.sh ]]; then
   setuplog "ERROR: setup is being run from $(pwd)!"
   echo "ERROR: setup must be run from the \${WAHOO_HOME}/bin directory." && exit 1
fi

cd ..

TMP=$(pwd)/tmp
 
# Create required directories in ${WAHOO}.
for d in tmp domain log task task/$(hostname); do
   [[ ! -d ${d} ]] && mkdir -p ${d}
done

# Check if we have a copy of ksh 93. 
if [[ ! -f ${TMP}/$(hostname)/ksh ]]; then
   PATH_TO_KSH=$(which ksh)
   printf "What is the full path ksh 93 binary [${PATH_TO_KSH}] > " && read ANSWER
   PATH_TO_KSH=${ANSWER:-${PATH_TO_KSH}}
   mkdir -p ${TMP}/$(hostname)
   cp -p ${PATH_TO_KSH} ${TMP}/$(hostname)/ksh
fi

# Copy ksh 93 to /tmp/wahoo which gives us a known/universal location for the ksh binary (used in header of scripts).
if [[ ! -f /tmp/wahoo ]]; then
   cp -p ${TMP}/$(hostname)/ksh /tmp/wahoo
fi

# If this variable is not set then we have a new install and the ~/.wahoo file did not exist.
if [[ -z ${WAHOO_HOME} || -z ${WAHOO} ]]; then
   # There are things we do for a new install only.
   printf "Define the WAHOO_DOMAIN  > " && read WAHOO_DOMAIN
   [[ -z ${WAHOO_DOMAIN} ]] && exit 1
   typeset -u WAHOO_PROD
   printf "Is this a production host (Y or N) [Y] > " && read WAHOO_PROD
   printf "Define the SIMPLE_HOSTNAME > " && read SIMPLE_HOSTNAME
   [[ -z ${SIMPLE_HOSTNAME} ]] && SIMPLE_HOSTNAME=$(hostname)
   # We will only set this for a new install, after this it could be that the user really wants it to be null.
   [[ -z ${MESSAGE_SUBJECT_PREFIX} ]] && MESSAGE_SUBJECT_PREFIX="[${WAHOO_DOMAIN}]"
   [[ -z ${WAHOO_MAIL_PROGRAM} ]] && MAIL_PROGRAM=$(first_file_found "/bin /usr /" "mailx mail")
   [[ ! -d tmp ]] && mkdir tmp
else
   # Backup the current config file and keep a reference to the file name for use later.
   BACKUP_CONFIG_FILE=${TMP}/.wahoo.$(date +"%Y%m%d_%H%M%S")
   [[ -f ~/.wahoo ]] && cp -p ~/.wahoo ${BACKUP_CONFIG_FILE}
   # Go ahead and remove any backups of this file older than 30 days.
   find ${TMP} -name ".wahoo.*" -mtime +30 -exec rm {} \;
fi

[[ -z ${WAHOO_ZIP_PROGRAM} ]] && WAHOO_ZIP_PROGRAM=$(first_file_found "/bin /usr /" "gzip compress")
WAHOO_HOME=$(pwd)
WAHOO=${WAHOO_HOME}
OSTYPE=$(uname -s | ./bin/str.sh ucase)

# Check if domain exists and create if it does not.
if [[ ! -d ${WAHOO}/domain/${WAHOO_DOMAIN} ]]; then
   mkdir -p ${WAHOO}/domain/${WAHOO_DOMAIN}/bin && chmod 700 ${WAHOO}/domain/${WAHOO_DOMAIN}/bin
fi

DOMAIN_CONFIG_FILE=${WAHOO_HOME}/domain/${WAHOO_DOMAIN}/.wahoo
LOCAL_CONFIG_FILE=~/.wahoo

# Check if log directory exists and create if it does not.
[[ ! -d ${WAHOO}/log ]] && mkdir ${WAHOO}/log

# Create an empty .wahoo config file in the domain directory. The settings in this file can over-ride the settings
# in the ~/.wahoo config file.
if [[ ! -f ${WAHOO}/domain/${WAHOO_DOMAIN}/.wahoo ]]; then
   touch ${WAHOO}/domain/${WAHOO_DOMAIN}/.wahoo 
   chmod 600  ${WAHOO}/domain/${WAHOO_DOMAIN}/.wahoo
fi

PATH=$(./bin/.wahoo-path.sh)

# Create tmp/ subdirectories here if there are any.

(
cat <<EOF

# This prevents the file from being loaded more than once.
[[ -n \${WAHOO} ]] && return

# Always automatically replace /tmp/wahoo if it has been removed for some reason.
$(echo "[[ ! -f /tmp/wahoo ]] && cp ${TMP}/$(hostname)/ksh /tmp/wahoo && chmod 700 /tmp/wahoo")

# -----------------------------------------------------------------------------
# REQUIRED
# -----------------------------------------------------------------------------

# Automatically export all variables.
set -a 

# Treat unset parameters as an error when substituting.
set +o nounset

# Root directory of the Wahoo Shell Scripting Framework.
# WAHOO_HOME=/u01/app/wahoo
WAHOO_HOME=${WAHOO_HOME}

# A shorter way of saying WAHOO_HOME in scripts.
WAHOO=\${WAHOO_HOME}

# This string identifies the group of servers this install is a part of.
# WAHOO_DOMAIN="acmeco"
WAHOO_DOMAIN=${WAHOO_DOMAIN}

# Variables to reference the config files. Domain values take precedence over local values.
LOCAL_CONFIG_FILE=${LOCAL_CONFIG_FILE}
DOMAIN_CONFIG_FILE=${DOMAIN_CONFIG_FILE}

# 
PATH=\${WAHOO}/domain/${WAHOO_DOMAIN}/bin:\${WAHOO}/bin:${PATH}

# Not a good idea to mess with this one, as you want to ensure consistent use of this in scripts.
HOSTNAME=$(hostname)

# Stores the OS Type in UPPERCASE. Valid values are AIX, LINUX, and SUNOS.
OSTYPE=${OSTYPE}

# Wahoo temporary directory. Used for temp space of course.
TMP=${WAHOO_HOME}/tmp

# Application log file.
WAHOO_APP_LOG=\${WAHOO}/log/wahoo.log

# 0=Off, 1=Minimal Logging, 2=Debug, 3=Maximum Logging
# Usually this should be set to 1.
WAHOO_DEBUG_LEVEL=1

# Name of debug file. 
WAHOO_DEBUG_LOG=${WAHOO}/log/debug.log

# Name of default audit log file (used when messages are tagged with the KEYWORD "AUDIT".
WAHOO_AUDIT_LOG=${WAHOO}/log/audit.log

# Name of file messages are log to when messages are routed using the LOG keyword.
WAHOO_MESSAGE_LOG=${WAHOO}/log/messages.log

# 80 single dashes. Used in scripts.
LINE1=$(printf %80s|tr ' ' "-")

# 80 double dashes. Used in scripts.
LINE2=$(printf %80s|tr ' ' "=")

# -----------------------------------------------------------------------------
# OPTIONAL
# -----------------------------------------------------------------------------

# This variable points to the file delivered Wahoo events file.
WAHOO_EVENTS_FILE=\${WAHOO}/bin/.wahoo-events.cfg

# Y is this is a production host, N or null if this host is not production. When scripting only test for Y.
WAHOO_PROD=${WAHOO_PROD}

# Most hostnames are too hard to remember, this is where you get to define a much more sensible name.
# SIMPLE_HOSTNAME="prod-db1"
SIMPLE_HOSTNAME="${SIMPLE_HOSTNAME}"

# Name of program to send email with, almost always mail or mailx.
WAHOO_MAIL_PROGRAM=${WAHOO_MAIL_PROGRAM}

# Program to be used for compressing files (usually gzip or compress).
WAHOO_ZIP_PROGRAM=${WAHOO_ZIP_PROGRAM}

# Default list of email addresses to be used when emails are sent.
# WAHOO_EMAILS="admin@wahoolab.com,appgroup@acmeco.com"
WAHOO_EMAILS="${WAHOO_EMAILS}"

# These addresses should direct to a pager/SMS.
# WAHOO_PAGERS="pager@wahoolab.com,johndoe@anymail.com"
WAHOO_PAGERS="${WAHOO_PAGERS}"

# This is the string which will begin the subject line of all emails.
MESSAGE_SUBJECT_PREFIX="${MESSAGE_SUBJECT_PREFIX}"

# KEYWORD_OVERRIDES="CRITICAL=WARNING,LOG=TRASH"
KEYWORD_OVERRIDES=

# If you forget to clean up your .tmp files in ${TMP} the task can be automated here.
DELETE_TMP_FILES_AFTER_N_DAYS=${DELETE_TMP_FILES_AFTER_N_DAYS}

# Used for test purposes only.
WAHOO_TEST=

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# crlock.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Applies an expiration time to every lock if --expire option was not defined. When this parameter is set I am
# preventing any lock from being held longer than the time defined. This is helpful when things go wrong and for 
# whatever reason one or more locks are not released. This will help clear up problems automatically when your
# doesn't handle it. Defaults to 129600 (36 hours). Set to 0 or empty to disable.
# MAX_LOCK_SECONDS=129600
MAX_LOCK_SECONDS=129600

# -----------------------------------------------------------------------------
# Built In Monitors
# -----------------------------------------------------------------------------

# monitor_localhost_for_reboot.sh
# Must be 'Y' (default) to enable this monitor.
MONITOR_LOCALHOST_FOR_REBOOT_ENABLED=Y
# Keyword(s) used to route messages for this monitor. If more than one keyword separate with a comma.
MONITOR_LOCALHOST_FOR_REBOOT_KEYWORDS="CRITICAL"

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------

# List of plugins to attempt to install. Use the appropriate directory name from \${WAHOO}/plugin.
# WAHOO_PLUGINS="plugin, plugin"
WAHOO_PLUGINS=

$(${WAHOO}/bin/.wahoo-get-plugins-config.sh "oracle-os-watcher")

# You can configure settings for the entire domain in this file. These settings will over-ride the settings
# in ~/.wahoo.
. \${WAHOO}/domain/\${WAHOO_DOMAIN}/.wahoo

EOF
) > ~/.wahoo

if [[ -f ${BACKUP_CONFIG_FILE} ]]; then
   ${WAHOO}/bin/.wahoo-merge-config-files.sh ${BACKUP_CONFIG_FILE} ~/.wahoo
fi

# Create the run.sh program which is called from cron and runs everything.
${WAHOO}/bin/.wahoo-create-run-sh.sh

# Create the default events.cfg file in your domain directory if it does not exist.
${WAHOO}/bin/.wahoo-create-events-cfg.sh

# Create tasks which are part of default install.
${WAHOO}/bin/.wahoo-create-default-tasks.sh

# Create default event folders.
${WAHOO}/bin/.wahoo-create-default-events.sh

cat <<EOF
$LINE1
In order to enable automated schedules and provide event responses you will 
need to add the following to your crontab file. We suggest you run this 
manually first and ensure there are no issues.

* * * * * ${WAHOO_HOME}/run.sh

EOF

