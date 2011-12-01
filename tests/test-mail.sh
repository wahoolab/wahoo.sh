
. ${WAHOO}/tests/functions.sh

now_testing "mail.sh"
check_for_help_option ${WAHOO}/bin/mail.sh
NAME="-" && failure

