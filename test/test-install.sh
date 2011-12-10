
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "This Installation"

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
   beginTest "Variable ${p} is defined."
   assertDefined $(echo $(eval "echo \${${p}}"))
   endTest
done

beginTest "\${TMP} directory exists."
assertTrue $([[ -d ${TMP} ]] && echo 1 )
endTest

beginTest "\${LOCAL_CONFIG_FILE} exists."
assertTrue $([[ -f ${LOCAL_CONFIG_FILE} ]] && echo 1 )
endTest

beginTest "\${DOMAIN_CONFIG_FILE} exists."
assertTrue $([[ -f ${DOMAIN_CONFIG_FILE} ]] && echo 1 )
endTest

beginTest "\${WAHOO}/domain/\${WAHOO_DOMAIN}/bin exists."
assertTrue $([[ -d ${WAHOO}/domain/${WAHOO_DOMAIN}/bin ]] && echo 1 )
endTest

beginTest "PATH includes \${WAHOO}/bin."
assertTrue $(echo ${PATH} | egrep "${WAHOO}/bin" | wc -l)
endTest

beginTest "PATH includes \${WAHOO}/domain/\${WAHOO_DOMAIN}/bin"
assertTrue $(echo ${PATH} | egrep "${WAHOO}/domain/${WAHOO_DOMAIN}/bin" | wc -l) 
endTest

beginTest "Local copy of Korn Shell 93 is available."
assertTrue $([[ -f ${TMP}/$(hostname)/ksh ]] && echo 1)
endTest

beginTest "/tmp/wahoo exists"
assertTrue $([[ -f /tmp/wahoo ]] && echo 1)
endTest

beginTest "Current shell is Korn Shell 93."
assertTrue $([[ -f /tmp/wahoo ]] && echo 1 )
assertTrue $(set | grep "SECONDS" | str.sh split "." | wc -l) 
endTest

beginTest "Wahoo cronjob is scheduled."
assertTrue $(crontab -l | str.sh nocomment | grep run.sh | wc -l)
endTest

beginTest "events.cfg file exists"
assertFile ${WAHOO}/domain/${WAHOO_DOMAIN}/events.cfg
endTest
