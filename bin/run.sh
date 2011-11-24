#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

${WAHOO}/bin/.wahoo-check-jobs.sh 1>> ${WAHOO}/log/stdout 2>> ${WAHOO}/log/stderr

exit

