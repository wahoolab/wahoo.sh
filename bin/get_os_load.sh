

OS_LOAD=$(uptime | awk '{ print substr($(NF-2),1,4) }')

debug.sh -3 "$$ OS_LOAD=${OS_LOAD}"

echo ${OS_LOAD}
