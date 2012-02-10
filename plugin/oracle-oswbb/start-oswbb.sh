#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -3 "$$ $(basename $0)"

# These need to be set in one of the .wahoo config files.
[[ -z ${OSWBB_SNAPSHOT_SECONDS} ]] && exit 0
[[ -z ${OSWBB_ARCHIVE_HOURS} ]] && exit 0
OSWBB_LOG_FILE=${OSWBB_LOG_FILE:-${WAHOO}/log/oswbb.log}

# Program is not installed yet.
[[ ! -d ${TMP}/oswbb ]] && exit 1

# If program is not already running.
if (( $(psgrep "OSWatcher" | wc -l) == 0 )); then
   cd ${TMP}/oswbb
   nohup ./OSWatcher.sh ${OSWBB_SNAPSHOT_SECONDS} ${OSWBB_ARCHIVE_HOURS} 1>> ${OSWBB_LOG_FILE} &
   applog.sh "$(basename $0) - Oracle OS Watcher Black Box has been started."
fi

exit 0
