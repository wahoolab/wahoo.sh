

. ${WAHOO}/tests/functions.sh

now_testing "time.sh"
check_for_help_option ${WAHOO}/bin/time.sh
NAME="time.sh epoch" && todo
NAME="time.sh epoch --hours" && todo
NAME="time.sh epoch --minutes" && todo

