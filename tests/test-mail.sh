
. ${WAHOO}/tests/functions.sh

nowTesting "mail.sh"
check_for_help_option ${WAHOO}/bin/mail.sh
NAME="-" && failure

