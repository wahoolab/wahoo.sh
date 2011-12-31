

function functions_help {
cat <<EOF
usage: .wahoo-functions.sh

General functions used within Wahoo.

Functions:

   get_os_load_average

      Return the current 5 minute load average.

   select_input_by_item_number

      See .wahoo-setup for an example of how this function is used to 
      prompt the user with a selection of options from which a 
      selection can be made.

   replace_keywords_using_overrides [list-of-keywords]
      
      Takes a comma separated list of keywords and checks the 
      \${KEYWORD_OVERRIDES} environment parameter for overrides.
      An overrides converts a keyword to another keyword. Function
      echos back each keyword or the converted keyword.

   create_tarball_for_release

      Creates a .tar.gz file from current \${WAHOO_HOME} which can
      be used as media for a release.

      ToDo: Need a function to create a tarball that includes domain
      and host files for deployment to other servers.
   
   create_run_file

      Used during setup to create the run.sh file in \${WAHOO}.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && functions_help

function get_os_load_average {
   uptime | awk '{ print substr($(NF-2),1,4) }'
}   

function select_input_by_item_number {
# ToDo: Support large numbers of items using >1 columns.
index=0
while read INPUT; do
    ((index=index+1))
    item[$index]="${INPUT}"
    printf "%-3s %s\n" "${index}" "${item[$index]}"
done

printf "\n%s" "Select: "
}


function replace_keywords_using_overrides {
# List of keywords seperated by commas.
KEYWORDS="${1}"
echo "${1}" | str.sh split "," | while read k; do
   if [[ -n "${KEYWORD_OVERRIDES}" ]]; then
      CONVERTED=
      echo "${KEYWORD_OVERRIDES}" | str.sh split "," | while read o; do
         echo "${o}" | sed 's/=/ /' | read OLD NEW      
         if [[ ${k} == ${OLD} ]]; then
            # KEYWORD=${NEW} && break
            CONVERTED="CONVERTED"
            echo "${NEW} " && break
         fi
      done
      [[ -z ${CONVERTED} ]] && echo "${k}"
   else
      echo "${k}"
   fi
done
}

function create_tarball_for_release {
[[ ! -d ${WAHOO} ]] && return
YMD=$(time.sh y-m-d)
cd ${WAHOO}/..
rm -rf ${WAHOO}${YMD}.tar.gz
rm -rf ${WAHOO}${YMD} 2> /dev/null
cp -rp ${WAHOO} ${WAHOO}${YMD}
cd ${WAHOO}${YMD}
rm run.sh 2> /dev/null
rm -rf domain tmp log event 2> /dev/null
# Remove oracle-osw
rm -rf ${WAHOO}/plugin/oracle-osw/*
cd ${WAHOO}/.. 
tar -cf ${WAHOO}${YMD}.tar wahoo${YMD}
gzip ${WAHOO}${YMD}.tar
rm -rf ${WAHOO}${YMD}
ls ${WAHOO}${YMD}.tar.gz
}

function create_run_file {

# NOTE: This file must be bash compliant so that it works from cron!

[[ -z ${WAHOO} ]] && return
(
cat <<EOF
# Always automatically replace /tmp/wahoo if it has been removed for some reason.
if [ ! -f /tmp/wahoo ]; then 
   cp ${WAHOO}/tmp/$(hostname)/ksh /tmp/wahoo 
   chmod 700 /tmp/wahoo
fi

# Attempt to load ~/.wahoo configuration file.
[ -f .wahoo ] && \$(. .wahoo 2> /dev/null)
[ -f ~/.wahoo ] && . ~/.wahoo

${WAHOO}/bin/.wahoo-check-events.sh

EOF
) > ${WAHOO}/run.sh

chmod 700 ${WAHOO}/run.sh
}
