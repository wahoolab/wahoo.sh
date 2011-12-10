

[[ -z ${WAHOO} ]] && return

(
cat <<EOF
# Always automatically replace /tmp/wahoo if it has been removed for some reason.
if [ ! -f /tmp/wahoo ]; then 
   cp ${WAHOO}/tmp/$(hostname)/ksh /tmp/wahoo 
   chmod 700 /tmp/wahoo
fi

# Attempt to load ~/.wahoo configuration file.
[ -f .wahoo ] && \$(. .wahoo 2> /dev/null)
[ -f ~/.wahoo ] && . ~/.wahoo

${WAHOO}/bin/.wahoo-check-tasks.sh

EOF
) > ${WAHOO}/run.sh

chmod 700 ${WAHOO}/run.sh

