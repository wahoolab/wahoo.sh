#!/tmp/wahoo

debug.sh -2 "$0"

function usage {
cat <<EOF
usage: rmlock.sh [lock_key]

Remove a lock created with crlock.sh.

Arguments:

   [lock_key]

      Unique key which identifies the lock. Required.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

if [[ -n "${1}" ]]; then   
   crlock.sh --remove "${1}"
else
   error.sh "$0 - LOCK_KEY is not defined." && exit 1
fi

exit 0
