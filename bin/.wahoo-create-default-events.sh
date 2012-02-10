
# Scheduled Events
# ----------------
crevent.sh --key "1min" --schedule "* * * * *" --silent

FILE=${WAHOO}/event/1min/monitor-os-load.sh
if [[ ! -f ${FILE} ]]; then
   echo "monitor_os_load.sh" > ${FILE}
   chmod 700 ${FILE}
fi

FILE=${WAHOO}/event/1min/check-messages.sh
if [[ ! -f ${FILE} ]]; then
   echo ".wahoo-check-messages.sh" > ${FILE}
   chmod 700 ${FILE}
fi

crevent.sh --key "5min" --schedule "0,5,10,15,20,25,30,35,40,45,55 * * * *"  --silent

FILE=${WAHOO}/event/5min/.wahoo.sh
if [[ ! -f ${FILE} ]]; then
   echo ".wahoo_event_5min.sh" > ${FILE}
   chmod 700 ${FILE}
fi

crevent.sh --key "10min" --schedule "0,10,20,30,40,50 * * * *" --silent
crevent.sh --key "60min" --schedule "0 * * * *" --silent
crevent.sh --key "reboot" --silent

