
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

function usage {
cat <<EOF
usage: .wahoo-setup.sh

Run when installing, moving or patching your \${WAHOO_HOME}. Should be run
from \${WAHOO_HOME}/setup.sh.

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

# Need to export all variables automatically.
set -a

TMPFILE=/tmp/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

touch ~/wahoo_setup.log && chmod 600 ~/wahoo_setup.log

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
   echo ${RESULT}
}

if [[ $0 != ".wahoo-setup.sh" && $0 != "./.wahoo-setup.sh" && $0 != $(pwd)/.wahoo-setup.sh ]]; then
   echo "ERROR: setup must be run from the \${WAHOO_HOME}/bin directory." && exit 1
fi

# cd to what is or will be ${WAHOO} (top level directory for wahoo).
cd ..

TMP=$(pwd)/tmp
 
# Create required directories in ${WAHOO}.
for d in tmp domain log event; do
   [[ ! -d ${d} ]] && mkdir -p ${d}
   chmod 700 ${d}
done

# Try to locate Korn Shell 93 and install as /tmp/wahoo
PATH_TO_KSH=
if [[ -f ./domain/${WAHOO_DOMAIN}/resource/$(uname)-$(uname -m)/ksh ]]; then
   PATH_TO_KSH="./domain/${WAHOO_DOMAIN}/resource/$(uname)-$(uname -m)/ksh" 
else
   PATH_TO_KSH=$(which ksh)
   printf "What is the full path to the Korn Shell 93 binary [${PATH_TO_KSH}] > " && read ANSWER
   PATH_TO_KSH=${ANSWER:-${PATH_TO_KSH}}
fi

if [[ ! -f /tmp/wahoo ]]; then
   if [[ -f ${PATH_TO_KSH} ]]; then
      cp ${PATH_TO_KSH} /tmp/wahoo
      chmod 700 /tmp/wahoo
   else
      echo "Setup failed to locate a copy of Korn Shell 93."
      exit 1
   fi
fi

# If this variable is not set then we have a new install and the ~/.wahoo file did not exist.
if [[ -z ${WAHOO_HOME} || -z ${WAHOO} ]]; then
   . ./bin/.wahoo-functions.sh   
 
   typeset -u WAHOO_PROD

   while (( $# > 0)); do
      case $1 in
         --domain) shift; WAHOO_DOMAIN="${1}"    ;;
         --prod)   shift; WAHOO_PROD="${1}"      ;;
         --name)   shift; SIMPLE_HOSTNAME="${1}" ;;
         *)        break                          ;;
      esac
      shift
   done

   if [[ -z ${WAHOO_DOMAIN} ]]; then
      printf "Define the WAHOO_DOMAIN  > " && read WAHOO_DOMAIN
      [[ -n ${WAHOO_DOMAIN} ]] || exit 1
   fi

   if [[ -z ${WAHOO_PROD} ]]; then
       printf "Is this a production host (Y or N) [N] > " && read WAHOO_PROD
       [[ -n ${WAHOO_PROD} ]] || WAHOO_PROD="N"
   fi

   if [[ -z ${SIMPLE_HOSTNAME} ]]; then
      printf "Define the SIMPLE_HOSTNAME > " && read SIMPLE_HOSTNAME
      [[ -n ${SIMPLE_HOSTNAME} ]] || SIMPLE_HOSTNAME=$(hostname)
   fi

   # We will only set this for a new install, after this it could be that the user really wants it to be null.
   [[ -z ${MESSAGE_SUBJECT_PREFIX} ]] && MESSAGE_SUBJECT_PREFIX="[${WAHOO_DOMAIN}]"
   if [[ -z ${WAHOO_MAIL_PROGRAM} ]]; then
      printf "\n%s\n\n" "Please select the program to use for sending mail."
      (which mail; which mailx; echo ".wahoo-mock-mail.sh") | select_input_by_item_number
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

mkdir -p ./domain/${WAHOO_DOMAIN}/resource/$(uname)-$(uname -m)
cp /tmp/wahoo ./domain/${WAHOO_DOMAIN}/resource/$(uname)-$(uname -m)/ksh

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

* * * * * ${WAHOO_HOME}/bin/.wahoo-run.sh 1> ${WAHOO_HOME}/log/stdout 2> ${WAHOO_HOME}/log/stderr
EOF

