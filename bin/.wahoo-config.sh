
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
PATH=\${WAHOO}/domain/\${WAHOO_DOMAIN}/bin:\${WAHOO}/bin:${PATH}

# Not a good idea to mess with this one, as you want to ensure consistent use of this in scripts.
HOSTNAME=$(hostname)

# Stores the OS Type in UPPERCASE. Valid values are AIX, LINUX, and SUNOS.
OSTYPE=${OSTYPE}

# Wahoo temporary directory. Used for temp space of course.
TMP=\${WAHOO}/tmp

# Application log file.
WAHOO_APP_LOG=\${WAHOO}/log/wahoo.log

# 0=Off, 1=Minimal Logging, 2=Debug, 3=Maximum Logging
# Usually this should be set to 1.
WAHOO_DEBUG_LEVEL=1

# Name of debug file. 
WAHOO_DEBUG_LOG=\${WAHOO}/log/debug.log

# Name of default audit log file (used when messages are tagged with the KEYWORD "AUDIT".
WAHOO_AUDIT_LOG=\${WAHOO}/log/audit.log

# List of files to log messages to. Separate each file using a comma.
WAHOO_MESSAGE_LOGS=\${WAHOO}/log/messages.log

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

# monitor_reboots.sh
# Keyword(s) used to route messages for this monitor. If more than one keyword separate with a comma.
# Leave blank if you do not want to monitor this host.
MONITOR_REBOOTS_KEYWORDS="CRITICAL"

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------

# Oracle OS Watcher Black Box
OSWBB_SNAPSHOT_SECONDS=
OSWBB_ARCHIVE_HOURS=
OSWBB_LOG_FILE=\${WAHOO}/log/oswbb.log

# You can configure settings for the entire domain in this file. These settings will over-ride the settings
# in ~/.wahoo.
. \${WAHOO}/domain/\${WAHOO_DOMAIN}/.wahoo

EOF

