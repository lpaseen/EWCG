Here are some scripts that I use when handling messages on
http://enigmaworldcodegroup.freeforums.net
The scripts can handle both finding a key for a existing text and pick a key
for a new message. They key format given is pasted in to meinEnigmas serial api.

It is two scripts for the two procedures M3 and M4(triton).
Included are also keysheet for the past and future

Disclaimer: It has bugs so don't blindly accept the output, verify that it
looks resonable. This is specially important for odd cases or when you getting
keys for days other than today.

```
Usage:
================================================================
# On it's own it will prep the start of a new message
./GenKeyM3.sh

| 12 | C | IV   VIII VI   |  16 14 21   | AU BO EF GJ HZ IL MQ RX SV TW  | LWX HQX UTT HIX |

# 2017-06-12
!Group:5
!Model:M3
!UKW:UKWC
!Rotor:4,8,6
!Ring:P,N,U

!Plugboard:AU BO EF GJ HZ IL MQ RX SV TW

#KG=>LWX HQX UTT HIX< HIX - HIXKV
!Settings:
!START:QUG
QCS


################

#hhmm 1tle 1tlr groups QUG QCS
[EWCG2017]
1419 1tle 1tlr <nn> QUG QCS
HIXKV

echo "  "|tr -dc '[a-zA-Z]'|sed 's/.\{75,75\}/&\n/g';echo

echo "  "|tr -dc '[a-zA-Z]'|sed 's/.\{72,72\}/&\n/g';echo
  

================================================================
#pass the kennegroup for a message and it will try to find out what day it's
#for and the key for that day

./GenKeyM3.sh EBF
EWCG 2014 02.txt: | 13 | V    I    IV   |  06 26 01  | AR BS EX FW HY IO KM LU NZ PT | PFD EBF EKV VVS |
EWCG 2015 06.txt: | 01 | IV   II   V    |  04 25 18  | AC BL DM EH IS KT OX PW QR YZ | PJG EBF IIM JVE |
EWCG 2016 12.txt: | 24 | IV   I    III  |  02 19 18  | AL CP DK EJ FQ GX IM NY RT SU | EBF ECW LVF SRD |

# 2016-12-24
!Group:5
!Model:M3
!UKW:UKWB
!Rotor:4,1,3
!Ring:B,S,R

!Plugboard:AL CP DK EJ FQ GX IM NY RT SU
================================================================
#or you can request a key for a specific day
./GenKeyM3.sh 1945-06-23

|  23  |  II   V    III  |  11  02  26  |  AJ  CO  DV  EI  GT  KQ  MY  NX  RW  SZ  |  JRM  MXH  GJO  KYN  |

# 1945-06-23
!Group:5
!Model:M3
!UKW:UKWB
!Rotor:2,5,3
!Ring:K,B,Z

!Plugboard:AJ  CO  DV  EI  GT  KQ  MY  NX  RW  SZ

================================================================
#For M4 it's basically the same
./GenKeyM4.sh 2017-06-01
kenngoup   = NMS
message key= DNU
final kenngoup   = mNMS
final message key= DNUn

mD=KS
NN=CT
MU=VU
Sn=ME

KSCT VUME
KG=NMS
#INNER=| NMS | 1 | C | Beta VII V VI | | | | | P G Y W |
#OUTER=| NMS | 1 | 1/15 2/14 3/18 4/13 5/8 6/25 10/21 11/24 16/26 17/22 | E C V G |

#2017-06
#DAY=1
!GROUP:4
!MODEL:M4
!UKW:UKWCT
!ROTOR:B,7,5,6
!RING:PGYW

!PLUGB: AO BN CR DM EH FY JU KX PZ QV
!START:ECVG
DNU


#to  hhmm/MM serial groups
[EWCG2017TRITON]
BRO 1447/12 ..

KSCT VUME
                 KSCT VUME

echo "  "|tr -dc '[a-zA-Z]'|sed 's/.\{72,72\}/&\n/g';echo

echo "  "|tr -dc '[a-zA-Z]'|sed 's/.\{4,4\}/&\n/g'|xargs -n10
================================================================
#Or with the they first two groups for current month
./GenKeyM4.sh KSCT VUME
KS=>MD
CT=>NN
VU=>MU
ME=>SN

mNMS
DNUn

kenngroup  = NMS
message key= DNU
KG=NMS
#INNER=| NMS | 1 | C | Beta VII V VI | | | | | P G Y W |
#OUTER=| NMS | 1 | 1/15 2/14 3/18 4/13 5/8 6/25 10/21 11/24 16/26 17/22 | E C V G |

#2017-06
#DAY=1
!GROUP:4
!MODEL:M4
!UKW:UKWCT
!ROTOR:B,7,5,6
!RING:PGYW

!PLUGB: AO BN CR DM EH FY JU KX PZ QV
!START:ECVG
================================================================
#if for some other month you need to state what month it might be
./GenKeyM4.sh  2017-04 WPGE EDDY

================================================================
# short help is available with -h
./GenKeyM4.sh -h
Usage:
 /home/peters/bin/GenKeyM4.sh -h
      this help

 /home/peters/bin/GenKeyM4.sh tomorrow
 /home/peters/bin/GenKeyM4.sh 2017-06-10
        to get key for some other day than today

 /home/peters/bin/GenKeyM4.sh 2017-07 grp1 grp2
        find key for a msg using bigramtable for 2017-07

 /home/peters/bin/GenKeyM4.sh grp1 grp2
        find key for a msg using current months bigram table

```
