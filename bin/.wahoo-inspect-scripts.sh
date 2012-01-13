#!/tmp/wahoo

function rule {
cat <<EOF
${1}   
${LINE1}
EOF
}

function issue {
cat <<EOF

# WARNING: ${1}
# ${LINE1}
EOF
while read -r INPUT; do
   echo "${INPUT}"
done
}

rule "Use grep -c instead of piping to wc -l"
find ${WAHOO} -type f -name "*.sh" | while read f; do
   if $(egrep "grep" ${f} | grep "wc -l" 1> /dev/null); then
      egrep "grep" ${f} | grep "wc -l" | issue ${f}
   fi
done
