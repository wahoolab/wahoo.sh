#!/tmp/wahoo 

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: script.sh [options]

Options:

   --foo    Does something.

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

while (( $# > 0)); do
   case $1 in
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

exit 0
