#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

fire-event.sh "wahoo-stop"

# Stop Oracle OS Watcher Black Box if it is installed.
if [[ -d ${TMP}/oswbb ]]; then
   # If not running this will throw an error so we ignore.
   ${TMP}/oswbb/stopOSWbb.sh 2> /dev/null
fi

statengine.sh --stop

touch /tmp/.wahoo-stop

exit 0
