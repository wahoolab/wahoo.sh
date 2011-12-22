
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# Need to export all variables automatically.
set -a

TMPFILE=/tmp/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

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
for d in tmp domain log; do
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
   . ./bin/.wahoo-functions.sh   
   # There are things we do for a new install only.
   printf "Define the WAHOO_DOMAIN  > " && read WAHOO_DOMAIN
   [[ -z ${WAHOO_DOMAIN} ]] && exit 1
   typeset -u WAHOO_PROD
   printf "Is this a production host (Y or N) [N] > " && read WAHOO_PROD
   [[ -z ${WAHOO_PROD} ]] && WAHOO_PROD="N"
   printf "Define the SIMPLE_HOSTNAME > " && read SIMPLE_HOSTNAME
   [[ -z ${SIMPLE_HOSTNAME} ]] && SIMPLE_HOSTNAME=$(hostname)
   # We will only set this for a new install, after this it could be that the user really wants it to be null.
   [[ -z ${MESSAGE_SUBJECT_PREFIX} ]] && MESSAGE_SUBJECT_PREFIX="[${WAHOO_DOMAIN}]"
   if [[ -z ${WAHOO_MAIL_PROGRAM} ]]; then
      printf "\n%s\n\n" "Please select the program to use for sending mail."
      (which mail; which mailx) | select_input_by_item_number
      read SELECTION
      WAHOO_MAIL_PROGRAM=${item[$SELECTION]}
   fi       
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

${WAHOO}/bin/.wahoo-config.sh > ~/.wahoo
if [[ -f ${BACKUP_CONFIG_FILE} ]]; then
   ${WAHOO}/bin/.wahoo-merge-config-files.sh ${BACKUP_CONFIG_FILE} ~/.wahoo
fi

# Must set WAHOO to nothing so we can reload .wahoo.
WAHOO=
. ~/.wahoo

# Create the run.sh program which is called from cron and runs everything.
. ${WAHOO}/bin/.wahoo-functions.sh
create_run_file

# Create default events.
${WAHOO}/bin/.wahoo-create-default-events.sh

cat <<EOF
$LINE1
In order to enable automated schedules and provide event responses you will 
need to add the following to your crontab file. We suggest you run this 
manually first and ensure there are no issues.

* * * * * ${WAHOO_HOME}/run.sh
EOF

