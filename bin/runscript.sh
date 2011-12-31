#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0) $(basename ${1})"

# There are times when you will generate temporary scripts and you will 
# want them removed when they are done running. In this case use the 
# --remove option.
REMOVE=
while (( $# > 0)); do
   case $1 in
      --remove) REMOVE="Y" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

SCRIPT="${1}"
TMPFILE="${TMP}/$$.tmp"
if [[ -n ${REMOVE} ]]; then
   trap 'rm ${TMPFILE}* ${SCRIPT} 2> /dev/null' 0
else
   trap 'rm ${TMPFILE}* 2> /dev/null' 0
fi

(
cat <<EOF
#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

${SCRIPT}
EOF
) > ${TMPFILE}

chmod 700 ${TMPFILE}

${TMPFILE} 1>> ${TMPFILE}.stdout 2>> ${TMPFILE}.stderr

if [[ -s ${TMPFILE}.stderr ]]; then
(
   cat <<EOF
${LINE1}
Error(s) Running ${SCRIPT}
$(date) 
${LINE1}
$(cat ${TMPFILE}.stderr)
${LINE1}
File Contents
${LINE1}
$(cat ${SCRIPT})
EOF
) >> ${WAHOO}/log/stderr
wahoo.sh log "An error occurred while running ${SCRIPT} from runscript.sh."
fi

if [[ -s ${TMPFILE}.stdout ]]; then
   cat ${TMPFILE}.stdout >> ${WAHOO}/log/stdout
fi

exit 0
