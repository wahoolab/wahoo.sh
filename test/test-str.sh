
# ToDo: Add tests for new str.sh functions remove, replace and ?
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/str.sh
beginTest "--help Option"
assertHelp
endTest

beginTest "upper and ucase"
assertEquals "$(echo 'a|][_*@z' | str.sh upper) $(echo 'a|][_*@z' | str.sh ucase)" "A|][_*@Z A|][_*@Z"
endTest

beginTest "lower and lcase"
assertEquals "$(echo 'A|][_*@Z' | str.sh lower) $(echo 'A|][_*@Z' | str.sh lcase)" "a|][_*@z a|][_*@z" 
endTest

beginTest "split a:b:c"
printf "a\nb\nc\n" > ${TEST_FILE}1
echo "a:b:c" | str.sh split > ${TEST_FILE}2
assertSame ${TEST_FILE}1 ${TEST_FILE}2 
endTest

for d in ";" "-" "," "|"; do
   beginTest "split a${d}b${d}c"
   printf "a\nb\nc\n" > ${TEST_FILE}1
   echo "a${d}b${d}c" | str.sh split "${d}" > ${TEST_FILE}2
   assertSame ${TEST_FILE}1 ${TEST_FILE}2
   endTest
done

beginTest "nospace"
assertEquals "$(echo 'foo foo' | str.sh nospace)" "foofoo"
endTest

beginTest "noblank"
printf "a\n\nb\n\nc\n" > ${TEST_FILE}1
cat ${TEST_FILE}1 | str.sh noblank > ${TEST_FILE}2
printf "a\nb\nc\n" > ${TEST_FILE}1
assertSame ${TEST_FILE}1 ${TEST_FILE}2
endTest

beginTest "nocomment"
printf "a\n#b\nc\n" > ${TEST_FILE}1
cat ${TEST_FILE}1 | str.sh nocomment > ${TEST_FILE}2
printf "a\nc\n" > ${TEST_FILE}1
assertSame ${TEST_FILE}1 ${TEST_FILE}2
endTest

beginTest "left"
assertEquals "$(echo '   foo' | str.sh left)" "foo"
endTest

