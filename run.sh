# Always automatically replace /tmp/wahoo if it has been removed for some reason.
if [ ! -f /tmp/wahoo ]; then 
   cp /home/lab/Dropbox/wahoo/tmp/lab-vm1/ksh /tmp/wahoo 
   chmod 700 /tmp/wahoo
fi

/home/lab/Dropbox/wahoo/bin/.wahoo-check-events.sh 

