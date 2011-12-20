
# echo "$(time.sh epoch),foo,10" > foo.dat; echo "GroupFoo,MINUTE" > .foo.dat


i=0
OUTPUT=foo$(time.sh epoch).dat
cp /dev/null $TMP/statengine/inbox/${OUTPUT}
T=$(time.sh epoch)
while (( ${i} < 1000 )); do
   ((i=i+1))
   echo "${T},foo${i},$( ((RANDOM%10000)) )" >> $TMP/statengine/inbox/${OUTPUT}
done
echo "GroupFoo,MINUTE" > ${TMP}/statengine/inbox/.${OUTPUT}

tail -10 $TMP/statengine/inbox/${OUTPUT}

