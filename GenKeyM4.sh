#!/bin/bash
#
#
#2016-12-20  Peter Sjoberg peters-src AT techwiz DOT ca
#	Created
#2017-01-02  Peter Sjoberg peters-src AT techwiz DOT ca
#	Added code for 2017
#2017-06-12  Peter Sjoberg peters-src AT techwiz DOT ca
#	added help, code cleanup, fixed so date show matches kennegruppe
#
#

BASEPATH=$(dirname $(readlink -f $0))
FLK=false


if [ "$1" == "-h" -o "$1" == "-?" ];then
    echo "Usage:"
    echo " $0 -h"
    echo "      this help"
    echo
    echo " $0 tomorrow"
    echo " $0 $(date +%F -d "2 days ago")"
    echo "	to get key for some other day than today"
    echo
    echo " $0 $(date +%Y-%m -d "next month") grp1 grp2"
    echo "	find key for a msg using bigramtable for $(date +%Y-%m -d "next month")"
    echo
    echo " $0 grp1 grp2"
    echo "	find key for a msg using current months bigram table"
    echo
    echo " $0 -4 grp1 grp2"
    echo "	use 4 letter message key"
    exit;
fi

if [ "$1" == "-4" ];then
    FLK=true
    shift
fi

P1="$1"
echo "$P1"|grep -q "^20[0-9][0-9]-[0-1][0-9]$" && P1="$P1-01"
echo "$P1"|grep -q "^20[0-9][0-9]-[0-9]$" && P1="$P1-01"

if [ -n "$P1" ] && date -d "$P1" &>/dev/null;then
    WHEN="$P1"
    shift
elif [ -n "$1" ] && date -d "$1" &>/dev/null;then
    WHEN="$1"
    shift
else
    WHEN="now -u"
fi

YEAR=$(eval date -d "$WHEN" +%Y)
YM=$(eval date -d "$WHEN" +%Y-%m)
DAY=$(eval date -d "$WHEN" +%e|tr -d ' ')

BGT=$BASEPATH/Keychart/Bigramtable_${YM}
M4TABLE=$BASEPATH/Keychart/EWCG_keysheet_M4_${YM}.txt

[ ! -e "$BGT.txt" ] && echo "Bigram table $BGT.txt missing - ABORT" && exit 1
[ ! -e "$M4TABLE" ] && echo "Keysheet $M4TABLE missing - ABORT" && exit 1

if [ -n "$DEBUG" ];then
    echo "BGT=$BGT"
    [ -e "$BGT" ] && ls -l $BGT || echo "$BGT NOT FOUND!!!"
    echo "M4TABLE=$M4TABLE"
    [ -e "$M4TABLE" ] && ls -l $M4TABLE || echo "$M4TABLE NOT FOUND!!!"
fi

#Check if a script friendly (unwrapped) textfile exist, if not - create it.
BGTABLE=${BGT}_unwrapped.txt
if [ ! -e "$BGTABLE" ];then
    echo "Please wait, creating $BGTABLE"
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

if [ "${#2}" -eq 4 ];then
    # We doing reverse, extract info from bigram tables
    GR="$1$2"

    for i in 0 1 2 3;do
	let POS=$i*2
	BG[i]=$(grep "^${GR:$POS:2}" $BGTABLE|cut -d= -f2)
	echo "${GR:$POS:2}=>${BG[i]}"
    done
    echo
    KG=${BG[1]:0:1}${BG[2]:0:1}${BG[3]:0:1}
    echo "first part : $(echo ${BG[0]:0:1}|tr '[:upper:]' '[:lower:'])${BG[1]:0:1}${BG[2]:0:1}${BG[3]:0:1}"

    if $FLK;then
        MK=${BG[0]:1:1}${BG[1]:1:1}${BG[2]:1:1}${BG[3]:1:1}
        echo "second part: $MK"
    else
        echo "second part: ${BG[0]:1:1}${BG[1]:1:1}${BG[2]:1:1}$(echo ${BG[3]:1:1}|tr '[:upper:]' '[:lower:'])"
        MK=${BG[0]:1:1}${BG[1]:1:1}${BG[2]:1:1}${BG[3]:1:1}
    fi
    echo
    echo "kenngroup  = $KG"
    echo "message key= $MK"

    DAY=$(cat $M4TABLE|awk -F\| '$2 ~ /'$KG'/{print $3}'|head -1|tr -d ' ')
    if [ -z "$DAY" ];then
	echo "kenngroup $KG was not found in $M4TABLE - ABORT"
	exit 3
    fi
    WHEN="$YM-$DAY"
    YEAR=$(eval date -d "$WHEN" +%Y)
    YM=$(eval date -d "$WHEN" +%Y-%m)
else
    KG=$(cat $M4TABLE|awk -F\| '$3=='$DAY' {print $2}'|head -1|tr '[:lower:]' '[:upper:]'|tr -d ' ')
    FKG="$(echo $(($RANDOM%26+97))|awk '{printf "%c",$1}')$KG"
    echo "kenngoup   = >$KG<"
    if $FLK;then
        MK="$(echo $(($RANDOM%26+65)) $(($RANDOM%26+65)) $(($RANDOM%26+65)) $(($RANDOM%26+65))|awk '{printf "%c%c%c%c",$1,$2,$3,$4}')"
        FMK=$MK
        echo "message key= >$MK<"
    else
        MK="$(echo $(($RANDOM%26+65)) $(($RANDOM%26+65)) $(($RANDOM%26+65))|awk '{printf "%c%c%c",$1,$2,$3}')"
        FMK="$MK$(echo $(($RANDOM%26+97))|awk '{printf "%c",$1}')"
        echo "message key= >$MK<"
    fi
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
    echo "First two grops are: ${bg[0]}${bg[1]} ${bg[2]}${bg[3]}"
fi

if [ -n "$DEBUG" ];then
    echo KG=$KG
    echo MK=$MK
    echo DAY=$DAY
    echo WHEN=$WHEN
    echo YM=$YM
fi

if [ ${#KG} -eq 3 ];then
    INNER=$(grep -A1 $KG $M4TABLE|head -2)
    OUTER=$(grep $KG $M4TABLE|tail -1)

#    OUTER=$(grep -A15 $KG $BASEPATH/OuterSettings.txt)
#    INNER=$(grep -A10 $KG $BASEPATH/InnerSettings.txt)
    echo "#INNER="$INNER
    echo "#OUTER="$OUTER
    echo

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
	echo "#$(eval date -d "$WHEN" +%Y-%m)"
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
            if $FLK;then
	        echo "[EWCG${YEAR}TRITON] [FLK]"
            else
	        echo "[EWCG${YEAR}TRITON]"
            fi
	    echo -n "MBR "
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
