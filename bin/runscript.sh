#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

SCRIPT="${1}"
TMPFILE="${TMP}/$$.tmp"
# trap 'rm ${TMPFILE}* ${SCRIPT} 2> /dev/null' 0

(
cat <<EOF
#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

${SCRIPT}
EOF
) > ${TMPFILE}

chmod 700 ${TMPFILE}

echo $LINE1
cat ${TMPFILE}
echo $LINE1

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
