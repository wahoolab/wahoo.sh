
. ~/.wahoo

NAME=

function nowTesting {
   cat <<EOF
${LINE1}
${1}
${LINE1}
EOF
}

function success {
   printf "%-70s%10s\n" "${NAME}" "OK"    
}

function failure {
   printf "%-70s%10s\n" "${NAME}" "*FAIL*"
}

function todo {
   printf "%-70s%10s\n" "${NAME}" "?"
}

function check_for_help_option {
   FILE="${1}"
   NAME="Check for --help option"
   if $(grep "\-\-help" "${FILE}" 1> /dev/null); then
      success
   else
      failure
   fi
}

function beginTest {
   NAME="${1}"
   [[ ! -d ${TMP}/tdd ]] && mkdir ${TMP}/tdd
   rm ${TMP}/tdd/* ${TMP}/tdd/.* 2> /dev/null
}

function log_failure {
   echo "$(date) ${1}" >> ${TMP}/tdd/failures.log   
}

function exist {
   for f in $*; do
      if [[ ! -f ${TMP}/tdd/${f} ]]; then
         echo 0 && return
      fi
   done
   echo 1 
}

function grepFile {
   # $1 is name of file, $2 is pattern to search for.
   if [[ ! -f ${TMP}/tdd/${1} ]]; then
      echo 0
   else
      if $(egrep "${2}" ${TMP}/tdd/${1} 1> /dev/null); then
         echo 1
      else
         echo 0
      fi
   fi
}

function grepLog {
   # $1 is pattern to search for.
   grepFile tdd.log "${1}"
}

function fail {
   touch ${TMP}/tdd/failure
}

function assertDefined {
   [[ -z ${1} ]] && fail
}

function assertTrue {
   if [[ -z ${1} ]]; then
      fail
   elif (( ${1} == 0 )); then
      fail
   fi
}

function assertFalse {
   if [[ -z ${1} ]]; then
      fail
   elif (( ${1} == 1 )); then
      fail
   fi
}

function endTest {
   if [[ -f ${TMP}/tdd/failure ]]; then
      failure
      [[ -s ${TMP}/tdd/failures.log ]] && cat ${TMP}/tdd/failures.log
   else
      success
   fi
}

