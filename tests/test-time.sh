

. ${WAHOO}/tests/functions.sh

now_testing "time.sh"

check_for_help_option ${WAHOO}/bin/time.sh
NAME="time.sh epoch"
if [[ -z $(time.sh epoch) ]]; then
   failure
else
   if (( $(time.sh epoch) > 0 )); then
      success
   else
      failure
   fi
fi

NAME="time.sh epoch --hours"
if [[ -z $(time.sh epoch --hours) ]]; then
   failure
else
   if (( $(time.sh epoch) > $(time.sh epoch --hours) && $(time.sh epoch --hours) > 0 )); then
      success
   else
      failure
   fi
fi

NAME="time.sh epoch --minutes" 
if [[ -z $(time.sh epoch --minutes) ]]; then
   failure
else
   if (( $(time.sh epoch hours) > $(time.sh epoch --minutes) && $(time.sh epoch --minutes) > 0 )); then
      success
   else
      failure
   fi
fi
