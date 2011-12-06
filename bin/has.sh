
function usage {
cat <<EOF
usage: has.sh [option] "[string]"

Misc. "has" functions.

Options:

   "has_option"
   
      Checks string for a command line option using the double-dash (--)
      format. Returns 1 if true, 0 if false.

   "has_space"

      Checks string for a space. Returns 1 if true, 0 if false.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function has_option {
   # Does "${STRING}" contain one or more "--" type options? Returns 1 (true) or 0 (false).
   ARGUMENTS="${1}"
   # foo--foo is OK, first egrep gets rid of those, anything else with --foo will get counted.
   echo "${ARGUMENTS}" | egrep -v "[A-Z|a-z|0-9]\-\-[A-Z|a-z|0-9]|[A-Z|a-z|0-9]\-[A-Z|a-z|0-9]" | egrep "\-[A-Z|a-z|0-9]" | wc -l
}

function has_space {
   # Does "${STRING}" contain one or more spaces? 1 (true) or 0 (false).
   STRING="${1}" 
   echo "${STRING}" | grep " " | wc -l
}

case "${1}" in
   "option") 
      has_option "${2}" ;;
   "space")
      has_space "${2}" ;;
   *)
      error.sh "has.sh - Error" ;;
esac
