

# Note: ${WAHOO}/domains/${WAHOO_DOMAIN}/bin and ${WAHOO}/bin are added in .wahoo-setup.sh, not here.

(
echo "${PATH}" | ./bin/str.sh split ":"
cat <<EOF
.
/bin
/usr/bin
/usr/sbin
/usr/local/bin
/usr/ucb
EOF
[[ -d ${ORACLE_HOME} ]] && echo "${ORACLE_HOME}/bin"
[[ -d /apps/microfocus/cobol/bin ]] && echo /apps/microfocus/cobol/bin 
[[ -d ${TUXDIR} ]] && echo ${TUXDIR}/bin
# ) | sort -u
# Advantage with perl in that the order is not changed.
) | perl -ne 'if (!defined $x{$_}) { print $_; $x{$_} = 1; }' | while read p; do
   printf "${p}:"
done

