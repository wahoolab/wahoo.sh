
debug.sh -2 "$0"

function usage {
cat <<EOF
usage: cache.sh [options] 

Simple file system based key value store.

   # Store the value of foo="bar".
   cache.sh set foo "bar"

   # Get the value of foo.
   cache.sh get foo

   # Store input from standard in. 
   cat foo.txt | cache.sh set foo
   
EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

CACHE=${TMP}/cache
[[ ! -d ${CACHE} ]] && mkdir ${CACHE}

OPTION="${1}"
KEY="${2}"
VALUE="${3}"

case "${1}" in
   "set")
      if [[ -z ${VALUE} ]]; then
         cp /dev/null ${CACHE}/${KEY}
         while read INPUT; do
            echo "${INPUT}" >> ${CACHE}/${KEY}
         done
      else
         echo "${VALUE}" > ${CACHE}/${KEY} 
      fi
      ;;
   "get")
      cat ${CACHE}/${KEY} 2> /dev/null 
      ;;
   *) 
      error.sh "$0 - Option ${1} not recognized." && exit 1
      ;;
esac

