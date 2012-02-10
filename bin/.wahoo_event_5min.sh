#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

oracle-oswbb.sh
statengine.sh --check-daemon 1> /dev/null
monitor_reboots.sh

exit 0
