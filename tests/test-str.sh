
. ${WAHOO}/tests/functions.sh

nowTesting "str.sh"
check_for_help_option ${WAHOO}/bin/str.sh

NAME="String to upper-case"
TEST="$(echo 'a|][_*@z' | str.sh upper) $(echo 'a|][_*@z' | str.sh ucase)"
if [[ "${TEST}" == "A|][_*@Z A|][_*@Z" ]]; then
   success
else
   failure
fi

NAME="String to lower-case"
TEST="$(echo 'A|][_*@Z' | str.sh lower) $(echo 'A|][_*@Z' | str.sh lcase)"
if [[ "${TEST}" == "a|][_*@z a|][_*@z" ]]; then
   success
else
   failure
fi

NAME="Split string a:b:c"
(
cat <<EOF
a
b
c
EOF
) > /tmp/A$$
echo "a:b:c" | str.sh split > /tmp/B$$
if (( $(diff /tmp/A$$ /tmp/B$$ | wc -l) == 0 )); then
   success
else
   failure
fi

for d in ";" "-" "," "|"; do
   NAME="Split string a${d}b${d}c"
   echo "a${d}b${d}c" | str.sh split "${d}" > /tmp/B$$
   if (( $(diff /tmp/A$$ /tmp/B$$ | wc -l) == 0 )); then
      success
   else
      failure
   fi
done

rm /tmp/A$$ /tmp/B$$ 2> /dev/null


