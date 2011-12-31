
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/has.sh
beginTest "--help Option"
assertHelp
endTest

for t in "x x" " x" "x " " "; do
   beginTest "space \"${t}\" (true)"
   assertTrue $(has.sh space "${t}")
   endTest
done

for t in "xx" "x" ""; do
   beginTest "space \"${t}\" (false)"
   assertFalse $(has.sh space "${t}")
   endTest
done

for t in "x --x" "--x "--123 " --123" "--foo --A" "x -foo" "-foo"; do
   beginTest "option \"${t}\" (true)"
   assertTrue $(has.sh option "${t}")
   endTest
done

for t in "x--x" " " "" "x-x"; do
   beginTest "option \"${t}\" (false)"
   assertFalse $(has.sh option "${t}")
   endTest
done


