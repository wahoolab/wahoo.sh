
. ${WAHOO}/tests/functions.sh

now_testing "fire-event.sh"
check_for_help_option ${WAHOO}/bin/fire-event.sh
NAME="-" && failure

