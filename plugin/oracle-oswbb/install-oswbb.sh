#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

PLUGIN_DIR=${WAHOO}/plugin/oracle-oswbb
[[ -d ${PLUGIN_DIR} ]] || exit 1
# Already installed.
[[ -d ${TMP}/oswbb ]] && exit 0
cd ${PLUGIN_DIR}

# If local install media directory already exists, remove it.
rm -rf oswbb 2> /dev/null

# Look for install media.
t=$(ls -rt *.tar 2> /dev/null | tail -1)
if [[ -f ${t} ]]; then
   tar -xf ${t}
   # Should only be one directory to move.
   if [[ -d oswbb ]]; then
      mv oswbb ${TMP}
   else
      error.sh "$(basename $0) - Could not find oswbb directory."
      exit 1
   fi
else
   error.sh "$(basename $0) - .tar file not found."
   exit 1
fi

applog.sh "$(basename $0) - Plugin Oracle OS Watcher Black Box install complete."

exit 0
