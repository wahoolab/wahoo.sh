

(
cat <<EOF
$(echo "${1}" || split " ")
$(echo "${WAHOO_PLUGINS}" | ${WAHOO}/bin/str.sh split ",")
EOF
) | sort -u | while read PLUGIN; do
   cat <<EOF

$(cat ${WAHOO}/plugin/${PLUGIN}/.wahoo)

EOF
done   
