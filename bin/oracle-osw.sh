#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0) $*"

OSW_ENABLED=${OSW_ENABLED:-}
OSW_INTERVAL=${OSW_INTERVAL:-60}
OSW_HOURS_TO_STORE=${OSW_HOURS_TO_STORE:-24}
OSW_ZIP=${OSW_ZIP:-"Y"}
OSW_LOGFILE="${WAHOO}/log/oracle-osw.log"

while (( $# > 0)); do
   case $1 in
      --stop)  OSW_ENABLED="N"; wahoo.sh config "OSW_ENABLED" "N" ;;
      --start) OSW_ENABLED="Y"; wahoo.sh config "OSW_ENABLED" "Y" ;;
      --check-daemon) DEFAULT_ACTION="Y" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

function get_zip_program {
if [[ -n ${OSW_ZIP} ]]; then
   if $(which gzip 1> /dev/null); then
      echo "gzip"
   elif $(which compress 1> /dev/null); then
      echo "compress"
   fi
fi
}

function get_osw_prcs_count {
   N=$(ps -ef | grep "OSWatcher.sh" | grep -cv "grep")
   debug.sh -3 "$$ get_osw_prcs_count=${N}" 
   echo ${N}
}

debug.sh -3 "$$ OSW_ENABLED=${OSW_ENABLED}"

if [[ ${OSW_ENABLED} == "Y" ]] && (( $(get_osw_prcs_count) == 0 )); then
   [[ ! -d ${TMP}/oracle-osw ]] && cp -rp ${WAHOO}/plugin/oracle-osw ${TMP}
   debug.sh -3 "$$ Starting OSW"
   cd ${TMP}/oracle-osw
   ./startOSW.sh ${OSW_INTERVAL} ${OSW_HOURS_TO_STORE} $(get_zip_program)  1>> ${OSW_LOGFILE}
   if (( $(get_osw_prcs_count) > 0 )); then
      debug.sh -1 "$$ Oracle OS Watcher is started"
   else
      error.sh "$0 - Failed to start Oracle OS Watcher!"
   fi
elif [[ ${OSW_ENABLED} != "Y" ]] && (( $(get_osw_prcs_count) > 0 )); then
   cd ${TMP}/oracle-osw
   ./stopOSW.sh 1>> ${OSW_LOGFILE}
   debug.sh -3 "$$ Stopping OSW" 
   if (( $(get_osw_prcs_count) == 0 )); then
      debug.sh -1 "$$ Oracle OS Watcher is stopped"
   else
      error.sh "$0 - Failed to stop Oracle OS Watcher!"
   fi
fi

(( ${WAHOO_DEBUG_LEVEL} >= 3 )) && debug.sh -3 "$$ Oracle OS Watcher process count is $(get_osw_prcs_count)"

exit 0
