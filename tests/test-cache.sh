
. ${WAHOO}/tests/functions.sh

now_testing "cache.sh"
check_for_help_option ${WAHOO}/bin/cache.sh
NAME="cache.sh set foo bar" && todo
NAME="cache.sh get foo" && todo
NAME="cat foo.txt | cache.sh set foo" && todo
NAME="cache.sh get foo" && todo

