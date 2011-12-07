

function usage {
cat <<EOF
usage: debug.sh [options] "[string]"

Log a debug message.

"[string]" is written to the \${WAHOO_DEBUG_LOG} (defaults to 
\${WAHOO}/log/debug.log. There are three debug levels. The default level is 1.
The debug level must be less than or equal to the \${WAHOO_DEBUG_LEVEL} in 
order to write to the file.

   # Level 1 (minimal)
   debug.sh "Foo"
   debug.sh -1 "Foo"

   # Level 2 (detailed)
   debug.sh -2 "Foo"

   # Level 3 (ridiculous)
   debug.sh -3 "Foo"

When you make a debug call you will typically want to include the program name
and the message in the string, like this.

debug.sh "Program Name - Short Message"

A time stamp and the debug level will be prepended to "[string]".

debug.sh can also read from standard input. If you make a debug call like this
you should not specify a "[string]".

   # Level 1 
   cat foo.txt | debug.sh -1

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# set -x
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

(( ${STATEMENT_LEVEL} > ${WAHOO_DEBUG_LEVEL} )) && return

if [[ -z "${1}" ]]; then
   WriteDebug "$(date) [${STATEMENT_LEVEL}] WRITING INPUT FROM STANDARD IN"
   while read INPUT; do
      WriteDebug "${INPUT}"
   done
   WriteDebug "$(date) [${STATEMENT_LEVEL}] DONE"
else
    WriteDebug "$(date) [${STATEMENT_LEVEL}] ${1}"
fi
