
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

cd ${WAHOO}/tests

test-config.sh
test-has.sh
test-debug.sh
test-str.sh
test-wahoo.sh
test-time.sh
test-cache.sh
test-error.sh
test-wahoo-setup.sh
test-wahoo-path.sh
test-crlock.sh
test-rmlock.sh
test-wahoo-check-jobs.sh

