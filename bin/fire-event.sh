#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$$ $(basename $0) $*"

.wahoo-check-events.sh --fire "${1}"

exit 0
