
# Scheduled
crevent.sh --key "5min"  --schedule "0,5,10,15,20,25,30,35,40,45,55 * * * *" 
crevent.sh --key "10min" --schedule "0,10,20,30,40,50 * * * *"
crevent.sh --key "60min" --schedule "0 * * * *"

crevent.sh --key "5min"  --command "monitor_localhost_for_reboot.sh" --silent

# Starts and stops Oracle OS Watcher using config parameters.
crevent.sh --key "10min" --command "oracle-ows.sh --check" --silent

# Triggered
crevent.sh --key "reboot"  
