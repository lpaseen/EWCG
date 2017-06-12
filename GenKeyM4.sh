#!/bin/bash
#
#
#2016-12-20  Peter Sjoberg peters-src AT techwiz DOT ca
#	Created
#2017-01-02  Peter Sjoberg peters-src AT techwiz DOT ca
#	Added code for 2017
#
#Parameters:
# $0 tomorrow
#	to get key for some other day than today
# $0 tomorrow Grp1 grp2
#	find key using bigramtable for tomorrow
#	BUG: date is not from kennegruppe but from "tomorrow"
# $0 grp1 grp2
#	find key using this months bigram table

#BGTABLE=${0%/*}/BigramTable.txt
BASEPATH=$(dirname $(readlink -f $0))

if [ -n "$1" ] && date -d "$1" &>/dev/null;then
    WHEN="$1"
    shift
else
    WHEN="now"
fi

BGTABLE=$BASEPATH/Keychart/Bigramtable_$(date -d "$WHEN" +%Y-%m)_unwrapped.txt
BGT=$BASEPATH/Keychart/Bigramtable_$(date -d "$WHEN" +%Y-%m)
M4TABLE=$BASEPATH/Keychart/EWCG_keysheet_M4_$(date -d "$WHEN" +%Y-%m).txt

[ ! -e "$BGT.txt" ] && echo "Bigram table $BGT.txt missing - ABORT" && exit 1
[ ! -e "$M4TABLE" ] && echo "Keysheet $M4TABLE missing - ABORT" && exit 1

if [ -n "$DEBUG" ];then
    echo ls -l $BGTABLE
    ls -l $BGTABLE
    echo ls -l $M4TABLE
    ls -l $M4TABLE
fi

if [ ! -r $BGT.txt ];then
    echo "Can't find the bigram table at $BGT.txt"
    exit
fi

if [ ! -r $M4TABLE ];then
    echo "Can't find the M4 keychart table at $M4TABLE"
    exit
fi

if [ -n "$WHEN" ];then
    DAY=$(date -d "$WHEN" +%e|tr -d ' ')
    if [ "$1" != "-r" -a "${#2}" -ne 4 ];then
	KG=$(cat $M4TABLE|awk -F\| '{if ($3=='$DAY'){print $2}}'|head -1)
	set - $KG
    fi
fi

#Check if a script friendly (unwrapped) textfile exist, if not - create it.
BGTABLE=${BGT}_unwrapped.txt
if [ ! -e "$BGTABLE" ];then
    echo "Creating $BGTABLE"
    BGLIST=""
    while read a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26;do
	[ -z "$a26" ] && continue
	for i in {1..26};do
            Col=$(echo $i|awk '{printf "%c",$1+64;}')
            val=$(eval echo \${a$i})
            left=$(echo $val|cut -d= -f1)
            right=$(echo $val|cut -d\> -f2)
            [ ${#left} -eq 1 ] && left="$Col$left"
            BGLIST="$BGLIST
$left=$right"
	done
    done <<< "$(grep -A25 '^[[:space:]]*AA' $BGT.txt)"
    echo "$BGLIST"|sort >$BGTABLE
fi

if [ -z "$1" ];then # assume we want todays key
    DAY=$(date +%e|tr -d ' ')
    KG=$(cat $M4TABLE|awk -F\| '{if ($3=='$DAY'){print $2}}'|head -1)
    set - $KG
fi

YEAR=$(date -d "$WHEN" +%Y)
#Check if we doing a reverse/decrypt

if [ "$1" == "-r" -o "${#2}" -eq 4 ];then
    REV=true
    if [ -n "$3" ];then
	GR="$2$3"
    else
	GR="$1$2"
    fi

#grep -E "FU|VW|KC|BH" BigramTable.txt
    for i in 0 1 2 3;do
	let POS=$i*2
	BG[i]=$(grep "^${GR:$POS:2}" $BGTABLE|cut -d= -f2)
	grep "^${GR:$POS:2}" $BGTABLE|sed 's/=/=>/'
    done
    echo
    KG=${BG[1]:0:1}${BG[2]:0:1}${BG[3]:0:1}
    MK=${BG[0]:1:1}${BG[1]:1:1}${BG[2]:1:1}
    echo "$(echo ${BG[0]:0:1}|tr '[:upper:]' '[:lower:'])${BG[1]:0:1}${BG[2]:0:1}${BG[3]:0:1}"
    echo "${BG[0]:1:1}${BG[1]:1:1}${BG[2]:1:1}$(echo ${BG[3]:1:1}|tr '[:upper:]' '[:lower:'])"
    echo
#    for i in 0 1 2 3;do
#	echo ${BG[i]}
#    done
    echo "kenngroup  = $KG"
    echo "message key= $MK"
else
    KG="$(echo $1|tr '[:lower:]' '[:upper:]')"
    MK="$(echo $2|tr '[:lower:]' '[:upper:]')"
    [ -z "$MK" ] && MK="$(echo $(($RANDOM%26+65)) $(($RANDOM%26+65)) $(($RANDOM%26+65))|awk '{printf "%c%c%c",$1,$2,$3}')"
    echo "kenngoup   = $KG"
    echo "message key= $MK"
    FKG=$KG
    FMK=$MK
    [ ${#FKG} -eq 3 ] && FKG="$(echo $(($RANDOM%26+97))|awk '{printf "%c",$1}')$KG"
    [ ${#FMK} -eq 3 ] && FMK="$MK$(echo $(($RANDOM%26+97))|awk '{printf "%c",$1}')"
    
    echo "final kenngoup   = $FKG"
    echo "final message key= $FMK"
    echo
    for i in {0..3};do
	bg[$i]=$(grep -i "^${FKG:$i:1}${FMK:$i:1}" $BGTABLE|cut -d= -f2)
	if [ "${#bg[$i]}" -eq 2 ];then
	    echo "${FKG:$i:1}${FMK:$i:1}=${bg[i]}"
	else
	    echo ">>>> PROBLEM, bad bigram >>> ${FKG:$i:1}${FMK:$i:1}<<<"
	fi
    done
    echo
    echo ${bg[0]}${bg[1]} ${bg[2]}${bg[3]}
fi

echo KG=$KG
if [ ${#KG} -eq 3 ];then
    INNER=$(grep -A1 $KG $M4TABLE|head -2)
    OUTER=$(grep $KG $M4TABLE|tail -1)

#    OUTER=$(grep -A15 $KG $BASEPATH/OuterSettings.txt)
#    INNER=$(grep -A10 $KG $BASEPATH/InnerSettings.txt)
    echo "#INNER="$INNER
    echo "#OUTER="$OUTER
    echo

#    eval $(echo $INNER|awk '{print "KGI="$1";DAYI="$2";UKW="$3";W[0]="$4";R0="$5";W[1]="$6";R1="$7";W[2]="$8";R2="$9";W[3]="$10";R3="$11"\n"}');
    eval $(echo $INNER|tr -d \||awk '{print "KGI="$1";DAYI="$2";UKW="$3";W[0]="$4";W[1]="$5";W[2]="$6";W[3]="$7";R0="$8";R1="$9";R2="$10";R3="$11"\n"}')

    [ "$UKW" == "B" ] && UKW="UKWBT" || UKW="UKWCT"

    ROTOR=""
    for i in ${!W[*]};do
	case ${W[$i]} in 
	    "Gamma") N[$i]="G";;
	    "Beta")  N[$i]="B";;
	    "I")     N[$i]="1";;
	    "II")    N[$i]="2";;
	    "III")   N[$i]="3";;
	    "IV")    N[$i]="4";;
	    "V")     N[$i]="5";;
	    "VI")    N[$i]="6";;
	    "VII")   N[$i]="7";;
	    "VIII")  N[$i]="8";;
	esac
    done
    
    ROTOR="${N[0]},${N[1]},${N[2]},${N[3]}"
    RING=$R0$R1$R2$R3

    #XVE 10 20/15 3/5 14/7 19/12 9/4 25/26 8/2 1/16 24/21 18/23 P Z F A
#    eval $(echo $OUTER|awk '{print "KGO="$1";DAYO="$2";PB=\""$3,$4,$5,$6,$7,$8,$9,$10,$11,$12"\";START="$13$14$15$16"\n"}')
    eval $(echo $OUTER|awk '{print "KGO="$2";DAYO="$4";PB=\""$6,$7,$8,$9,$10,$11,$12,$13,$14,$15"\";START="$17$18$19$20"\n"}')
#    echo "#KGO=$KGO"
#    echo "#PB=$PB"
    
    #echo "$PB"|xargs -n1|while read gr;do [ -z "$gr" ] && continue;l=$(echo $gr|cut -d/ -f1);r=$(echo $gr|cut -d/ -f2);echo $l $r|awk '{printf "%c%c ",$1+64,$2+64}';done;echo
    PBA=""
    for gr in $PB;do
	l=$(echo $gr|cut -d/ -f1)
	r=$(echo $gr|cut -d/ -f2)
	PBA="$PBA $(echo $l $r|awk '{printf "%c%c",$1+64,$2+64}')"
    done

    if [ "$KGI"=="$KGO" -a "$DAYI"=="$DAYO" ];then    
	echo "#$(date -d "$WHEN" +%Y-%m)"
	echo "#DAY=$DAYO"
	echo "!GROUP:4"
	echo "!MODEL:M4"
	echo "!UKW:$UKW"
	echo "!ROTOR:$ROTOR"
	echo "!RING:$RING"
	echo
	echo "!PLUGB:$PBA"
	echo "!START:$START"
	echo "$MK"
	echo
	if [ "${#2}" -ne 4 ];then
	    echo
	    echo "#to  hhmm/MM serial groups "
	    echo "[EWCG${YEAR}TRITON]"
	    echo -n "BRO "
	    TZ=UTC date +%H%M/%d\ ..
	    echo
	    echo ${bg[0]}${bg[1]} ${bg[2]}${bg[3]}
	    echo "                 "${bg[0]}${bg[1]} ${bg[2]}${bg[3]}
	fi
    else
	echo "Corrupt data found"
    fi
fi

echo
echo "echo \"  \"|tr -dc '[a-zA-Z]'|sed 's/.\{72,72\}/&\n/g';echo"
echo
echo "echo \"  \"|tr -dc '[a-zA-Z]'|sed 's/.\{4,4\}/&\n/g'|xargs -n10"
echo
