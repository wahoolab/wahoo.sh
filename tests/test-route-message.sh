
. ${WAHOO}/tests/functions.sh

now_testing "route-message.sh"
check_for_help_option ${WAHOO}/bin/route-message.sh

KEYWORD_OVERRIDES=

NAME="Email message to alternate email addresses."
if (( $(echo "foo" | route-message.sh --keywords EMAIL --test --emails "john@doe.com" | wc -l) == 2 )); then
   if [[ $(cat ${TMP}/messages/test/.emails) == "john@doe.com" ]]; then
      success
   else
      failure
   fi
else
   failure
fi

NAME="Email message to alternate pager addresses."
if (( $(echo "foo" | route-message.sh --keywords PAGE --test --pagers "jane@doe.com" | wc -l) == 3 )); then
   if [[ $(cat ${TMP}/messages/test/.pagers) == "jane@doe.com" ]]; then
      success
   else
      failure
   fi
else
   failure
fi

NAME="Log message to \${WAHOO_MESSAGE_LOG} - no overrides."
if (( $(echo "foo" | route-message.sh --test | grep "WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

NAME="Route a CRITICAL message - no overrides."
if (( $(echo foo | route-message.sh --test --keywords CRITICAL | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 3 )); then
   success
else
   failure
fi

NAME="Route a PAGE - no overrides."
if (( $(echo foo | route-message.sh --test --keywords PAGE | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 3 )); then
   success
else
   failure
fi

NAME="Route a WARNING - no overrides."
if (( $(echo foo | route-message.sh --test --keywords WARNING | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 2 )); then
   success
else
   failure
fi

NAME="Route a EMAIL - no overrides."
if (( $(echo foo | route-message.sh --test --keywords EMAIL | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 2 )); then
   success
else
   failure
fi

NAME="Route a INFO - no overrides."
if (( $(echo foo | route-message.sh --test --keywords INFO | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

NAME="Route a LOG - no overrides."
if (( $(echo foo | route-message.sh --test --keywords LOG | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

NAME="Route a TRASH - no overrides."
if (( $(echo foo | route-message.sh --test --keywords TRASH | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 0 )); then
   success
else
   failure
fi

NAME="Route a --nolog - no overrides."
if (( $(echo foo | route-message.sh --test --nolog | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 0 )); then
   success
else
   failure
fi

KEYWORD_OVERRIDES="CRITICAL=LOG"
NAME="Route a CRITICAL message - LOG override."
if (( $(echo foo | route-message.sh --test --keywords CRITICAL | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

KEYWORD_OVERRIDES="CRITICAL=LOG,WARNING=TRASH,PAGE=EMAIL,INFO=EMAIL"
NAME="Route a PAGE message - EMAIL override."
if (( $(echo foo | route-message.sh --test --keywords PAGE | egrep "PAGERS|EMAILS|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 2 )); then
   success
else
   failure
fi

KEYWORD_OVERRIDES="CRITICAL=LOG,WARNING=TRASH,PAGE=TYPO,INFO=EMAIL"
NAME="Route a PAGE message - maps to bad override TYPO"
echo foo | route-message.sh --test --keywords PAGE 2> $$.tmp 1> /dev/null
if (( $(cat $$.tmp | wc -l) == 1 )); then
   success
else
   failure
fi
rm $$.tmp 2> /dev/null

KEYWORD_OVERRIDES=
NAME="Route message with --audit --nolog"
if (( $(echo foo | route-message.sh --test --audit --nolog | egrep "WRITING TO ${WAHOO_AUDIT_LOG}|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

KEYWORD_OVERRIDES=
NAME="Route message with --audit"
if (( $(echo foo | route-message.sh --test --audit --nolog | egrep "WRITING TO ${WAHOO_AUDIT_LOG}|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

NAME="Route message to alternate log file."
rm /tmp/alt.log 2> /dev/null
if (( $(echo foo | route-message.sh --test --log /tmp/alt.log  | egrep "WRITING TO /tmp/alt.log|WRITING TO ${WAHOO_MESSAGE_LOG}" | wc -l) == 1 )); then
   success
else
   failure
fi

NAME="Route message with incident."
if (( $(echo foo | route-message.sh --test --incident "gem" | wc -l) == 2 )); then
   if [[ $(cat ${TMP}/messages/test/.incident) == "gem" ]]; then
      success
   else
      failure
   fi
else
   failure
fi

NAME="Route message with no input."
if (( $(cat /dev/null | route-message.sh --test | wc -l) == 0 )); then
   if [[ $(ls ${TMP}/messages/test/.* | ec -l) == 0 ]]; then
      success
   else
      failure
   fi
else
   failure
fi

