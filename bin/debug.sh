
(( ${WAHOO_DEBUG_LEVEL} == 0 )) && return

function WriteDebug {
   echo "${1}" >> ${WAHOO_DEBUG_LOG} 
}

# Default statement level is 1 if not specied when debug.sh is called.
STATEMENT_LEVEL=1
case ${1} in
   -1) shift; STATEMENT_LEVEL=1 ;;
   -2) shift; STATEMENT_LEVEL=2 ;;
   -3) shift; STATEMENT_LEVEL=3 ;;
esac

(( ${STATEMENT_LEVEL} <= ${WAHOO_DEBUG_LEVEL} )) && WriteDebug "$(date) [${STATEMENT_LEVEL}] ${1}"

