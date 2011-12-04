# Always automatically replace /tmp/wahoo if it has been removed for some reason.
if [ ! -f /tmp/wahoo ]; then 
   cp /home/lab/Dropbox/wahoo/tmp/lab-vm1/ksh /tmp/wahoo 
   chmod 700 /tmp/wahoo
fi

# Attempt to load ~/.wahoo configuration file.
[ -f .wahoo ] && $(. .wahoo 2> /dev/null)
[ -f ~/.wahoo ] && . ~/.wahoo

/home/lab/Dropbox/wahoo/bin/.wahoo-check-jobs.sh 1>> /home/lab/Dropbox/wahoo/log/stdout 2>> /home/lab/Dropbox/wahoo/log/stderr
