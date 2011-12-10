

(
cat <<EOF
$(echo "${1}" | ${WAHOO}/bin/str.sh split " " "noblank")
$(echo "${WAHOO_PLUGINS}" | ${WAHOO}/bin/str.sh split "," "noblank")
EOF
) | sort -u | while read PLUGIN; do
   if [[ -n ${PLUGIN} ]]; then
   cat <<EOF

$(cat ${WAHOO}/plugin/${PLUGIN}/.wahoo)

EOF
   fi
done   
