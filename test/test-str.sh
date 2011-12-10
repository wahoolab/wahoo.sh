
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "str.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/str.sh | wc -l)
endTest

beginTest "upper and ucase"
assertTrue $([[ "$(echo 'a|][_*@z' | str.sh upper) $(echo 'a|][_*@z' | str.sh ucase)" == "A|][_*@Z A|][_*@Z" ]] && echo 1)
endTest

beginTest "lower and lcase"
assertTrue $([[ "$(echo 'A|][_*@Z' | str.sh lower) $(echo 'A|][_*@Z' | str.sh lcase)" == "a|][_*@z a|][_*@z" ]] && echo 1)
endTest

beginTest "split a:b:c"
printf "a\nb\nc\n" > ${TMP}/tdd/file1
echo "a:b:c" | str.sh split > ${TMP}/tdd/file2
assertFalse $(diff ${TMP}/tdd/file1 ${TMP}/tdd/file2 | wc -l)
endTest

for d in ";" "-" "," "|"; do
   beginTest "split a${d}b${d}c"
   printf "a\nb\nc\n" > ${TMP}/tdd/file1
   echo "a${d}b${d}c" | str.sh split "${d}" > ${TMP}/tdd/file2
   assertFalse $(diff ${TMP}/tdd/file1 ${TMP}/tdd/file2 | wc -l)
   endTest
done

beginTest "nospace"
assertTrue $( [[ $(echo "foo foo" | str.sh nospace) == "foofoo" ]] && echo 1)
endTest

beginTest "noblank"
printf "a\n\nb\n\nc" > ${TMP}/tdd/file1
cat ${TMP}/tdd/file1 | str.sh noblank > ${TMP}/tdd/file2
printf "a\nb\nc" > ${TMP}/tdd/file1
assertFalse $(diff ${TMP}/tdd/file1 ${TMP}/tdd/file2 | wc -l)
endTest

beginTest "nocomment"
printf "a\n#b\nc" > ${TMP}/tdd/file1
cat ${TMP}/tdd/file1 | str.sh nocomment > ${TMP}/tdd/file2
printf "a\nc" > ${TMP}/tdd/file1
assertFalse $(diff ${TMP}/tdd/file1 ${TMP}/tdd/file2 | wc -l)
endTest

beginTest "left"
assertTrue $( [[ $(echo "   foo" | str.sh left) == "foo" ]] && echo 1)
endTest

