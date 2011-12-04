

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

