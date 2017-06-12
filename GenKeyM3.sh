#!/bin/bash
#
#2016-05-02  Peter Sjoberg peters-src AT techwiz DOT ca
#	Created
#Purpose: Generate a key from the keysheet for today that can be used to configure meinEnigma


#BASEPATH=${0%/*}
BASEPATH=$(dirname $(readlink -f $0))/Keychart

if [ -z "$2" -a "${#1}" == "5" ];then
    set - ${1:0:3}
fi

if [ "${#1}" == "3" ];then
    if ! grep -sHiw "$1" $BASEPATH/{u571,EWCG}*.txt|awk -F/ '{print $NF}'|grep -i --color "$1";then
	echo "kennegroup $1 not found"
	exit
    fi
    Lines=1
    Line="$(grep -Hiw "$1" ${BASEPATH}/EWCG*.txt|awk -F/ '{print $NF}'|tail -$Lines|head -1)"
    if echo "$Line"|grep -q "^EWCG_M3";then
	WHEN="$(echo "$Line"|echo "$Line"|tr '._' ' '|awk '{printf "%s-%02d",$3,$5}')"
    else
	[ -n "$Line" ] && WHEN="$(echo "$Line"|tr '.' ' '|awk '{print $2"-"$3"-"$6}')"
    fi

    if [ -n "$WHEN" ];then
	#Verify that it's not way in the future
	TDIFF=$(($(date +%s)-$(date +%s -d$WHEN)+86400))
	PW="wrong"
	while [ $TDIFF -lt 0 -a "$WHEN" != "$PW" ];do
	    let Lines++
	    PW="$WHEN"
	    Line="$(grep -Hiw "$1" ${BASEPATH}/EWCG*.txt|awk -F/ '{print $NF}'|tail -$Lines|head -1)"
#	    WHEN="$(grep -Hiw "$1" ${BASEPATH}/EWCG*.txt|awk -F/ '{print $NF}'|tail -$Lines|head -1|tr '.' ' '|awk '{print $2"-"$3"-"$6}')"
	    if echo "$Line"|grep -q "^EWCG_M3";then
		WHEN="$(echo "$Line"|echo "$Line"|tr '._' ' '|awk '{printf "%s-%02d",$3,$5}')"
	    else
		WHEN="$(echo "$Line"|tr '.' ' '|awk '{print $2"-"$3"-"$6}')"
	    fi
	    TDIFF=$(($(date +%s)-$(date +%s -d$WHEN)+86400))
	done
    fi
    [ -z "$WHEN" ] && WHEN="$(grep -Hiw "$1" ${BASEPATH}/u571*.txt|awk -F/ '{print $NF}'|tail -1|tr '.' ' '|awk '{print $2"-"$3"-"$5}')"
    if [ -z "$WHEN" -o "$WHEN" == "$PW" ];then
	echo "No (past) key found for \"$1\""
	exit
    fi
else
    WHEN=${1:-now}
fi

YEAR="$(date -d $WHEN +"%Y")"
MONTH="$(date -d $WHEN +"%m")"
DAY="$(date -d $WHEN +"%d")"
day="$(date -d $WHEN +"%e")"

if [ $YEAR -ge 2017 ];then
    Key="$(grep -s "|  *$day  *|" ${BASEPATH}/"EWCG_M3_$YEAR-$MONTH.txt")"
else
    Key="$(grep -s "|  *$DAY  *|" ${BASEPATH}/"EWCG $YEAR $MONTH.txt")"
fi
[ -z "$Key" ] && Key="$(grep -s "|  *$DAY  *|" ${BASEPATH}/"u571 $YEAR $MONTH.txt")"
if [ -z "$Key" ];then
    echo "No key found for $WHEN ($YEAR $MONTH $DAY)"
    exit 1
fi

if [ "${#1}" != "3" ];then
    echo
    echo "$Key"
fi

echo

if [ $YEAR -ge 2017 ];then
#    echo "  Key=\"$Key\""
    UKW="UKW$(echo "$Key"|cut -d\| -f3|tr -d ' ')"
    Rotor="$(echo "$Key"|cut -d\| -f4|sed "s/ I / 1 /;s/ II / 2 /;s/ III / 3 /;s/ IV / 4 /;s/ V / 5 /;s/ VI / 6 /;s/ VII / 7 /;s/ VIII / 8 /;s/^ *//;s/ *$//"|tr -s ' '|tr ' ' ',')"
    Rings="$(echo "$Key"|cut -d\| -f5|sed "s/^ *//;s/ *$//"|awk '{printf "%c %c %c",$1+64,$2+64,$3+64;}'|tr -s ' '|tr ' ' ',')"
    Plugs="$(echo "$Key"|cut -d\| -f6|sed "s/^ *//;s/ *$//")"
    KennGroup=($(echo "$Key"|cut -d\| -f7|sed "s/^ *//;s/ *$//"))
else
    UKW="UKWB"
    Rotor="$(echo "$Key"|cut -d\| -f3|sed "s/ I / 1 /;s/ II / 2 /;s/ III / 3 /;s/ IV / 4 /;s/ V / 5 /;s/ VI / 6 /;s/ VII / 7 /;s/ VIII / 8 /;s/^ *//;s/ *$//"|tr -s ' '|tr ' ' ',')"
    Rings="$(echo "$Key"|cut -d\| -f4|sed "s/^ *//;s/ *$//"|awk '{printf "%c %c %c",$1+64,$2+64,$3+64;}'|tr -s ' '|tr ' ' ',')"
    Plugs="$(echo "$Key"|cut -d\| -f5|sed "s/^ *//;s/ *$//")"
    KennGroup=($(echo "$Key"|cut -d\| -f6|sed "s/^ *//;s/ *$//"))
fi
KG=${KennGroup[$(($RANDOM%4))]}

FG=$(echo -e "$KG\x$(printf "%0x" $(($RANDOM%26+65)))\x$(printf "%0x" $(($RANDOM%26+65)))")

echo "# $(date +%F -d$WHEN)"
echo "!Group:5"
echo "!Model:M3"
echo "!UKW:$UKW"
echo "!Rotor:$Rotor"
echo "!Ring:$Rings"
echo
echo "!Plugboard:$Plugs"
echo
echo "#KG=>${KennGroup[*]}< $KG - $FG"
echo "!Settings:"

GS1="$(echo -e "\x$(printf "%0x" $(($RANDOM%26+65)))\x$(printf "%0x" $(($RANDOM%26+65)))\x$(printf "%0x" $(($RANDOM%26+65)))")"
GS2="$(echo -e "\x$(printf "%0x" $(($RANDOM%26+65)))\x$(printf "%0x" $(($RANDOM%26+65)))\x$(printf "%0x" $(($RANDOM%26+65)))")"
echo "!START:$GS1"
echo "$GS2"
echo
#echo "!START:$GS1"

echo
echo "################"
echo
echo "#hhmm 1tle 1tlr groups $GS1 $GS2 "
echo "[EWCG$YEAR]"
#echo "$GS1 xxx"
echo "$(TZ=UTC date +%H%M) 1tle 1tlr <nn> $GS1 $GS2"
echo "$FG"

echo
echo "echo \"  \"|tr -dc '[a-zA-Z]'|sed 's/.\{75,75\}/&\n/g';echo"
echo
echo "echo \"  \"|tr -dc '[a-zA-Z]'|sed 's/.\{72,72\}/&\n/g';echo"
echo
