
. ~/.wahoo

NAME=
FILE=
TEST_DIR=${TMP}/test
TEST_LOG=${TEST_DIR}/test.log
TEST_FILE=${TEST_DIR}/test-file

function logtest {
   echo "${1}" >> ${TEST_DIR}/tests.log 
}

function fail {
   touch ${TEST_DIR}/failure
   logtest "FAILED!"
}

function assertHelp {
   logtest "$0 $*"
   if ! $(grep "\-\-help" ${FILE} 1> /dev/null); then
      fail
   fi 
}

function assertSame {
   logtest "$0 $*"
   if (( $(diff ${1} ${2} | wc -l) > 0 )) then
      fail
   fi
}

function nowTesting {
   FILE=${1}
   cat <<EOF
${LINE1}
$(basename ${FILE})
${LINE1}
EOF
}

function success {
   printf "%-70s%10s\n" "${NAME}" "OK"    
}

function failure {
   printf "%-70s%10s\n" "${NAME}" "*FAIL*"
}

function beginTest {
   NAME="${1}"
   [[ ! -d ${TEST_DIR} ]] && mkdir -p ${TEST_DIR}
   rm ${TEST_DIR}/* ${TEST_DIR}/.* 2> /dev/null
}

function exist {
   for f in $*; do
      if [[ ! -f ${TEST_DIR}/${f} ]]; then
         echo 0 && return
      fi
   done
   echo 1 
}

function grepMatch {
   logtest "$0 $*"
   # $1 is name of file, $2 is pattern to search for.
   if [[ "${1}" == $(basename "${1}") ]]; then
      f=${TEST_DIR}/${1}
   else
      f="${1}"
   fi
   if [[ ! -f ${f} ]]; then
      echo 0
   else
      echo $(egrep -c "${2}" ${f})
   fi
}

function grepFile {
   logtest "$0 $*"
   # $1 is name of file, $2 is pattern to search for.
   if [[ "${1}" == $(basename "${1}") ]]; then
      GREPFILE=${TEST_DIR}/${1}
   else
      GREPFILE="${1}"
   fi
   if [[ ! -f ${GREPFILE} ]]; then
      echo 0
   elif $(egrep "${2}" ${GREPFILE} 1> /dev/null); then
      echo 1
   else
      echo 0
   fi
}

function grepLog {
   logtest "$0 $*"
   # $1 is pattern to search for.
   grepFile ${TEST_LOG} "${1}"
}

function hasSize {
   logtest "$0 $*"
   if [[ -s ${1} || -s ${TEST_DIR}/${1} ]]; then
      echo 1
   else
      echo 0
   fi
}

function isDir {
   logtest "$0 $*"
   if [[ -d "${1}" ]]; then
      echo 1
   else
      echo 0
   fi
}

function assertDefined {
   logtest "$0 $*"
   [[ -z ${1} ]] && fail "$0 - $*"
}

function assertUndefined {
   logtest "$0 $*"
   [[ -n ${1} ]] && fail "$0 - $*"
}

function assertTrue {
   logtest "$0 $*"
   if [[ -z ${1} ]]; then
      fail "$0 - $*"
   elif (( ${1} == 0 )); then
      fail "$0 - $*"
   fi
}

function assertFile {
   logtest "$0 $*"
   [[ -f ${1} ]] || fail "$0 - $*"
}

function assertDir {
   logtest "$0 $*"
   [[ -d ${1} ]] || fail "$0 - $*"
}

function assertMissing {
   logtest "$0 $*"
   [[ ! -d ${f} && ! -f ${f} ]] || "$0 - $*"
}

function assertFalse {
   logtest "$0 $*"
   if [[ -z ${1} ]]; then
      fail "$0 - $*"
   elif (( ${1} == 1 )); then
      fail "$0 - $*"
   fi
}

function assertEquals {
   logtest "$0 $*"
   [[ "${1}" == "${2}" ]] || fail "$0 - $*"
}

function assertZero {
   logtest "$0 $*"
   (( ${1} != 0 )) && fail "$0 - $*"
}

function assertOne {
   logtest "$0 $*"
   (( ${1} == 1 )) || fail "$0 - $*"
}

function assertPositive {
   logtest "$0 $*"
   (( ${1} > 0 )) || fail "$0 - $*"
}

function assertNotZero {
   logtest "$0 $*" 
   (( ${1} == 0 )) && fail "$0 - $*"
}

function cat_test_dir {
   echo ""
   find ${TEST_DIR} -type f | while read f; do
      cat <<EOF
Dumping contents of ${f}
${LINE1}
$(cat ${f})

EOF
   done
}

function endTest {
   if [[ -f ${TEST_DIR}/failure ]]; then
      failure
      [[ -s ${TEST_DIR}/failures.log ]] && cat ${TEST_DIR}/failures.log
      cat_test_dir
   else
      success
   fi
}

