
. ${WAHOO}/tests/functions.sh

now_testing "Wahoo Installation"

# Verify variable have values when required.
(
cat <<EOF
WAHOO 
WAHOO_HOME 
WAHOO_DOMAIN 
LOCAL_CONFIG_FILE 
DOMAIN_CONFIG_FILE
HOSTNAME
OSTYPE
WAHOO_DEBUG_LEVEL
WAHOO_DEBUG_LOG
TMP
SIMPLE_HOSTNAME
EOF
) | while read p; do
   NAME="Variable ${p} is defined."
   if [[ -n $(echo $(eval "echo \${${p}}")) ]]; then
      success
   else
      failure
   fi
done

NAME="\${TMP} directory exists."
if [[ -d ${TMP} ]]; then
   success
else
   failure
fi

NAME="\${LOCAL_CONFIG_FILE} exists."
if [[ -f ${LOCAL_CONFIG_FILE} ]]; then
   success
else
   failure
fi

NAME="\${DOMAIN_CONFIG_FILE} exists."
if [[ -f ${DOMAIN_CONFIG_FILE} ]]; then
   success
else
   failure
fi

NAME="\${WAHOO}/domains/\${WAHOO_DOMAIN}/bin exists."
if [[ -d ${WAHOO}/domains/${WAHOO_DOMAIN}/bin ]]; then
   success
else
   failure
fi

NAME="PATH includes \${WAHOO}/bin."
if (( $(echo ${PATH} | egrep "${WAHOO}/bin" | wc -l) )); then
   success
else
   failure
fi

NAME="PATH includes \${WAHOO}/domains/\${WAHOO_DOMAIN}/bin"
if (( $(echo ${PATH} | egrep "${WAHOO}/domains/${WAHOO_DOMAIN}/bin" | wc -l) )); then
   success
else
   failure
fi

NAME="Local copy of Korn Shell 93 is available."
if [[ -f ${TMP}/$(hostname)/ksh ]]; then
   success
else
   failure
fi

NAME="/tmp/wahoo exists"
if [[ -f /tmp/wahoo ]]; then
   success
else
   failure
fi

NAME="Current shell is Korn Shell 93."
if [[ -f /tmp/wahoo ]]; then
   if (( $(set | grep "SECONDS" | str.sh split "." | wc -l) > 1 )); then
      success
   else
      failure
   fi
   exit 0
else
   failure
fi

NAME="Wahoo cronjob is scheduled."
if (( $(crontab -l | str.sh nocomment | grep run.sh | wc -l) > 1 )); then
   failure
else
   success
fi
