

function usage {
cat <<EOF
usage: .wahoo-path.sh

Returns a value for PATH which has various directories added if they exist.

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

# Note: ${WAHOO}/domain/${WAHOO_DOMAIN}/bin and ${WAHOO}/bin are added in .wahoo-setup.sh, not here.

WAHOO=${WAHOO:-$(pwd)}

(
echo "${PATH}" | ${WAHOO}/bin/str.sh split ":"
cat <<EOF
.
/bin
/usr/bin
/usr/sbin
/usr/local/bin
/usr/ucb
EOF
[[ -d ${ORACLE_HOME} ]] && echo "${ORACLE_HOME}/bin"
# ToDo: Could search a much broader group of disks for cobol/bin.
[[ -d /apps/microfocus/cobol/bin ]] && echo /apps/microfocus/cobol/bin 
[[ -d ${TUXDIR} ]] && echo ${TUXDIR}/bin
# ) | sort -u
# Advantage with perl in that the order is not changed.
) | perl -ne 'if (!defined $x{$_}) { print $_; $x{$_} = 1; }' | while read p; do
   [[ -d ${p} ]] && printf "${p}:"
done

