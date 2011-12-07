

EVENT_NAME="${1}"

[[ -z ${EVENT_NAME} && exit 1

${WAHOO}/bin/.wahoo-check-jobs.sh --event ${EVENT_NAME}

if [[ -s ${WAHOO}/domains/${WAHOO_DOMAIN}/events.cfg ]]; then
   ${WAHOO}/bin/.wahoo-check-jobs.sh --file ${WAHOO}/domains/${WAHOO_DOMAIN}/events.cfg --event ${EVENT_NAME}
fi

