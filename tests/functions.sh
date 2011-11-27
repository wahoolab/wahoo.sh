
. ~/.wahoo

function now_testing {
   cat <<EOF
${LINE1}
${1}
${LINE1}
EOF
}

function success {
   printf "%-60s%20s\n" "${NAME}" "OK"    
}

function failure {
   printf "%-60s%20s\n" "${NAME}" "*FAIL*"
}

function todo {
   printf "%-60s%20s\n" "${NAME}" "?"
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

