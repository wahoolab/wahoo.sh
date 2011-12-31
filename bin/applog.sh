

function usage {
cat <<EOF
usage: applog.sh [options] "[string]"

Log an app message.

"[string]" is written to the \${WAHOO_APP_LOG}. 

   Examples:

      applog.sh "Program Name - Short Message"

      cat ${file} | applog.sh 

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function WriteApp {
   echo "${1}" >> ${WAHOO_APP_LOG} 
}

D="$(date)"
if [[ -z "${1}" ]]; then
   while read -r INPUT; do
      WriteApp "${D} ${INPUT}"
   done
else
   WriteApp "${D} ${1}"
fi
