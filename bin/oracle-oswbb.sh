#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

# These first two parameters should only be set in a .wahoo config file.
# OSWBB_SNAPSHOT_SECONDS=
# OSWBB_ARCHIVE_HOURS=

if [[ -n ${OSWBB_SNAPSHOT_SECONDS} && -n ${OSWBB_ARCHIVE_HOURS} ]]; then
   if (( $(psgrep "OSWatcher" | wc -l) == 0 )); then
      ${WAHOO}/plugin/oracle-oswbb/install-oswbb.sh
      ${WAHOO}/plugin/oracle-oswbb/start-oswbb.sh 
   fi
fi

exit 0
