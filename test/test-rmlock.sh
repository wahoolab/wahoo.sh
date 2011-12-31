
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/rmlock.sh
beginTest "--help Option"
assertHelp
endTest

beginTest "rmlock.sh"
crlock.sh --remove foo && crlock.sh foo
assertTrue $(crlock.sh foo || echo 1)
rmlock.sh foo
assertTrue $(crlock.sh foo && echo 1)
rmlock.sh foo
endTest
