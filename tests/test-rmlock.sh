
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "rmlock.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/rmlock.sh | wc -l)
endTest

beginTest "rmlock.sh"
crlock.sh --remove foo && crlock.sh foo
assertTrue $(crlock.sh foo || echo 1)
rmlock.sh foo
assertTrue $(crlock.sh foo && echo 1)
rmlock.sh foo
endTest
