#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

fire-event.sh "wahoo-start"
rm /tmp/.wahoo-stop 2> /dev/null
