

# ToDo: If menu has > N rows then increase column count to X.

echo foo

i=0

MENU_FILE=
MENU_HEADER=

while (( $# > 0)); do
   case $1 in
      --file)   shift; MENU_FILE="${1}" ;;
      --header) shift; MENU_HEADER="${1}" ;;
      *) break ;;
   esac
   shift
done

if [[ -n ${WAHOO} ]]; then
   (( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1
else
   # This may be run during a new install.
   (( $(./bin/has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1
fi

if [[ -n ${MENU_HEADER} ]]; then
   cat <<EOF

${MENU_HEADER} 

EOF
fi

cat ${MENU_FILE} | while read LINE; do
    ((i=i+1))
    printf "%s %s\n" "${i}" "${LINE}" 
done

printf "Select: "

read MENU

if [[ -n ${MENU} ]]; then
   sed -n "${MENU},${MENU}p" ${f}
fi

