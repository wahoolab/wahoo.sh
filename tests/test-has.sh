
. ${WAHOO}/tests/functions.sh

nowTesting "has.sh"

check_for_help_option ${WAHOO}/bin/has.sh

for t in "x x" " x" "x " " "; do
   NAME="Looking for a spaces in \"${t}\""
   if (( $(has.sh space "${t}") == 1 )); then
      success
   else
      failure
   fi
done

for t in "xx" "x" ""; do
   NAME="Looking for no spaces in \"${t}\""
   if (( $(has.sh space "${t}") == 0 )); then
      success
   else
      failure
   fi
done

for t in "x --x" "--x "--123 " --123" "--foo --A"; do
   NAME="Looking for options in \"${t}\""
   if (( $(has.sh option "${t}") == 1 )); then
      success
   else
      failure
   fi
done

for t in "x--x" " " ""; do
   NAME="Looking for no options in \"${t}\""
   if (( $(has.sh option "${t}") == 0 )); then
      success
   else
      failure
   fi
done


