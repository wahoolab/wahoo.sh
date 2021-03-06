
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

[[ -z ${WAHOO} ]] && echo "\${WAHOO} is not defined!" && exit 1
[[ ! -f /tmp/wahoo ]] && echo "/tmp/wahoo not found!" && exit 1

# ToDo: Check all f in bin check for test-${f}.sh.

cat <<EOF

The following files may be missing tests.
-----------------------------------------
$(
cd ${WAHOO}/bin
ls * | while read f; do
   [[ ! -f ${WAHOO}/test/test-${f} ]] && echo ${f}
done
)

EOF

cd ${WAHOO}/test

test-install.sh
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
test-wahoo-check-events.sh
test-mail.sh
test-fire-event.sh
test-route-message.sh
