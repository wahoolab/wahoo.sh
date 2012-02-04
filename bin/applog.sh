# Not invoking a shell here, the assumption is we should be in ksh
# when this script is called.

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

function usage {
cat <<EOF
usage: applog.sh 

Log a string to the application log file \${WAHOO_APP_LOG}.

Note - All applog entries make a debug level 1 call.

Example:

   applog.sh "Program Name - Short Message"

   cat somefile.txt | applog.sh 

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function WriteToAppLog {
   echo "${1}" >> ${WAHOO_APP_LOG} 
   # App log is always a debug level 1 call.
   debug.sh -1 "$$ applog.sh ${1}"
}

D="$(date)"
if [[ -z "${1}" ]]; then
   while read -r INPUT; do
      WriteToAppLog "${D} ${INPUT}"
   done
else
   WriteToAppLog "${D} ${1}"
fi
