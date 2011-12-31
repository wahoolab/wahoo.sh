

uptime | awk '{ print substr($(NF-2),1,4) }'
