#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

if [[ -n "${1}" ]]; then   
   crlock.sh --remove "${1}"
else
   error.sh "$0 - LOCK_KEY is not defined." && exit 1
fi

exit 0
