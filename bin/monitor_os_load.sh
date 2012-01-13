#!/tmp/wahoo


debug.sh -2 "$$ $(basename $0)"

# Pipe a simple "key,value" pair to statengine.sh.
(
cat <<EOF
OS Load Avg.,$(get_os_load.sh) 
EOF
) | statengine.sh --group OS 

exit 0
