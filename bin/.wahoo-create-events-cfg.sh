


[[ -f ${WAHOO}/domains/${WAHOO_DOMAIN}/events.cfg ]] && return

(
cat <<EOF
# This is the events.cfg file for your domain.
EOF
) > ${WAHOO}/domains/${WAHOO_DOMAIN}/events.cfg

