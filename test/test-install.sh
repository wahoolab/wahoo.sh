
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/.wahoo-setup.sh
beginTest "--help Option"
assertHelp
endTest

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
assertDir ${TMP}
endTest

beginTest "\${LOCAL_CONFIG_FILE} exists."
assertFile ${LOCAL_CONFIG_FILE}
endTest

beginTest "\${DOMAIN_CONFIG_FILE} exists."
assertFile ${DOMAIN_CONFIG_FILE}
endTest

beginTest "\${WAHOO}/domain/\${WAHOO_DOMAIN}/bin exists."
assertDir ${WAHOO}/domain/${WAHOO_DOMAIN}/bin
endTest

beginTest "PATH includes \${WAHOO}/bin."
assertOne $(echo ${PATH} | egrep -c "${WAHOO}/bin")
endTest

beginTest "PATH includes \${WAHOO}/domain/\${WAHOO_DOMAIN}/bin"
assertOne $(echo ${PATH} | egrep -c "${WAHOO}/domain/${WAHOO_DOMAIN}/bin") 
endTest

beginTest "Local copy of Korn Shell 93 is available."
assertFile ${TMP}/$(hostname)/ksh
endTest

beginTest "/tmp/wahoo exists"
assertFile /tmp/wahoo
endTest

beginTest "Current shell is Korn Shell 93."
assertPositive $(set | grep "SECONDS" | str.sh split "." | wc -l) 
endTest

beginTest "Wahoo cronjob is scheduled."
assertOne $(crontab -l | str.sh nocomment | grep -c run.sh)
endTest

