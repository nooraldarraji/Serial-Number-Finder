#!/bin/bash
#
# Author: Noor Al Darraji
#
# Instagram : @i.n00r
#
# 05-21-2018
#
# License: MIT
#
# Simple script to search for C-series M5 systems log
#
# ** NOTE : I made this script only for practicing purposes, so please don't mind my mistakes and my awful code lines :).
#
#

USERINPUT=${1}
YELLOW='\033[43;30m'
RED='\033[0;31m'
BLINKRED='\033[5;31m'
NC='\033[0m'
MAGNETA='\033[95m'
GREEN='\e[92m'

M5_LOGS_PATH=/usr/autoprog/cmrc/sequence

clear



(shopt -s nocaseglob
  
  xM5Path () {
    
    cd $M5_LOGS_PATH &>/dev/null
    cd "`ls -trd $USERINPUT* | tail -n 1 `" &>/dev/null
    
  }
  if [ "$1" == "" ] || [ "$1" == " " ]; then
    
    printf "[${MAGNETA}+${NC}] Please enter the System Serial Number ${MAGNETA}~${NC}> "; read USERINPUT
  fi
  
  if [ ${#USERINPUT} -ne 11 ]; then
    
    echo ""
    echo "+------------------------------------------------+"
    echo -e "|${RED} Error #54 - Please enter a vaild serial number${NC} |"
    echo "+------------------------------------------------+"
    echo ""
    exit 54
    
  fi
  cd $M5_LOGS_PATH &>/dev/null
  
  if [ $? -eq 1 ]; then
    PIPEE="|"
    echo ""
    echo "+------------------------------------------------------------------------------+"
    echo -e "|${RED} Error #56 - Wrong Machine/Station make sure you are on the same UUT Location${NC} |"
    echo -e "+------------------------------------------------------------------------------+"
    echo -e "| Current Machine : ${HOSTNAME}			    			       |"
    echo -e "| Current User    : ${USER}						       |"
    echo "+------------------------------------------------------------------------------+"
    echo ""
    exit 56
    
  fi
  
  ls -d $USERINPUT* &>/dev/null
  
  if [ $? -eq 2 ]; then
    
    echo ""
    echo "+------------------------------------------------+"
    echo -e "|${RED} Error #52 - Please enter a vaild serial number${NC} |"
    echo "+------------------------------------------------+"
    echo ""
    exit 52
    
  fi
  
  
  #	FOLDER_OUTPUT=$(ls -d $USERINPUT* | sort | tail -n1 &>/tmp/m5_folder_log_output.txt)
  #	FOLDER_CH=/tmp/m5_folder_log_output.txt
  #	FOLDER_ENTRY=`cat /tmp/m5_folder_log_output.txt`
  
  #	xM5Path () {
  #
  #	        CONFIG_HOME=/usr/autoprog/cmrc/sequence
  #                cd $CONFIG_HOME &>/dev/null
  #                cd "`ls -trd $USERINPUT* | tail -n 1 `" &>/dev/null
  #        }
  
  
  
  
  xCDF () {
    
    
    xConfig () {
      
      xM5Path
      echo ""
      echo "+--------------------------------------------------------------------------------+"
      echo "|  Category	 Serial Number	   Product Identifier 	Part Number   	         |"
      echo "+--------------------------------------------------------------------------------+"
      awk -F, '{ gsub (/POWER SUPPLY/, "POWER-SUPPLY");
		   print $1 "\t" $2 "\t" $3 "\t" $4 "\t"
      }' $USERINPUT_*.configuration \
      | column -t | sed  '1d' | sed 's/^/    /g'
      echo "+--------------------------------------------------------------------------------+"
      
    }
    
    xDiags () {
      
      xM5Path
      echo ""
      echo "+--------------------------------------------------------------------------------------------------------------------+"
      echo "|	 					TEST Software"
      echo "+--------------------------------------------------------------------------------------------------------------------+"
      cat *_sysft_software.cfg | sed -n '/^Bmc_diag/p;/^Linux_iso/p;/^Efi_iso/p;/^ACT2_IMAGE/p' | sed 's/=/\x1b[95m~>\x1b[0m/g' | column -t | sed 's/^/|   /g'
      echo "+--------------------------------------------------------------------------------------------------------------------+"
      
    }
    
    xFirm () {
      xM5Path
      echo ""
      echo "+-----------------------------------------------------------------------------------------------------------------------------------------------+"
      echo "|			 					TEST Firmware   	      		                   	     		|"
      echo "+-----------------------------------------------------------------------------------------------------------------------------------------------+"
      cat *_sysft_software.cfg \
      | sed -n '/^BIOS /p;/^BMC/p;/^BMC_MFG/p;/^BODEGA_FW/p;/^BODEGA_BOOT/p;/^BODEGA_DIAG/p;/^CRUZ_FW/p;/^CRUZ_BOOT/p;/^CLEARLAKE_DIAG/p;/^CLAREMON_DIAG/p;/^SERENO_FW/p;/^SERENO_BOOT/p;/^SUSANVILLE_DIAG/p;/^TORRANCE_DIAG/p' \
      | sed 's/=/\x1b[95m~>\x1b[0m/g' | column -t | sed 's/^/|   /g'
      echo "+-----------------------------------------------------------------------------------------------------------------------------------------------+"
      
    }
    
    printf "[\x1b[95m+\x1b[0m] [\x1b[32mC\x1b[0m]onfiguration	[\x1b[32mF\x1b[0m]irmware	[\x1b[32mS\x1b[0m]oftware  \x1b[95m~\x1b[0m> "; read -n 1 -t 10 CDS
    if [ "$CDS" == "S" ] || [ "$CDS" == "s" ] ; then
      xDiags
      elif [ "$CDS" == "C" ] || [ "$CDS" == "c" ]; then
      xConfig
      elif [ "$CDS" == "F" ] || [ "$CDS" == "f" ]; then
      xFirm
    else
      echo
      
    fi
    
    
  }
  
  xUser() {
    
    BY='\033[30;43m'
    user=$(grep "user" type_$SN*_main.log | uniq | awk 'END {print $4}' | tr -d '[]')
    echo -e "[${MAGNETA}+${NC}] Last user tested the system: [ ${GREEN}${user}${NC} ] "
    
  }
  
  #	if [[ "$SN" == *"FOX"* ]]; then
  #		fi
  
  xMac() {
    
    mac=$(cat type_$USERINPUT*_main.log | grep macadd_dots | tail -n1 | awk '{print $3}')
    echo -e "[${MAGNETA}+${NC}] System MAC Address: [ ${GREEN}${mac}${NC} ] "
  }
  
  xIP() {
    ip=$(grep 'Echos to' view_$SN* | head -n1 | awk '{gsub(/,/, "");print $7}')
    echo -e "[${MAGNETA}+${NC}] Last IPv4 Used: [ ${GREEN}${ip}${NC} ] "
  }
  
  xSNfind() {
    
    #this is the funiest Function i have ever done. LOL
    snfind $USERINPUT 0 > /tmp/m5_script_snfind_log.txt
    cat /tmp/m5_script_snfind_log.txt | awk -v "key=F" '$7 == key {print($0)}' > /tmp/after_awk_tr.txt
    echo -e "+----------------------------------------------------------------------------------------------------------------------------------------------------------------+"
    echo -e "| Date          Time  Runtime  Account    LineID          PIDVID      Status    Area    PartNumber         Station      Cell                Failure              |"
    echo -e "+----------------------------------------------------------------------------------------------------------------------------------------------------------------+"
    cat /tmp/after_awk_tr.txt | awk '{
			gsub(/autoprog8/,"\033[43m" "DBG8""\033[0m");
			gsub(/autoprog7/,"\033[43m" "DBG7""\033[0m");
			gsub(/autoprog6/,"\033[43m" "DBG6""\033[0m");
			gsub(/autoprog5/,"\033[43m" "DBG5""\033[0m");
			gsub(/autoprog4/,"\033[43m" "DBG4""\033[0m");
			gsub(/autoprog3/,"\033[43m" "DBG3""\033[0m");
			gsub(/autoprog2/,"\033[43m" "DBG2""\033[0m");
			gsub(/autoprog1/,"\033[43m" "DBG1""\033[0m");
			gsub(/--/,   "---------");
    print"| " $1"\t"$2"\t" $3 "\t" $4"\t" $5"\t" $6"\t" "\033[01;31m"$7"\t""\033[0m" $8"\t" $11"\t" $15 "\t" $16"\t" "\033[0;31m"" " $17"\033[0m"}'
    echo -e "+----------------------------------------------------------------------------------------------------------------------------------------------------------------+"
    rm /tmp/m5_script_snfind_log.txt /tmp/after_awk_tr.txt &>/dev/null
  }
  
  #-------------------------------------{EFI Functions}------------------------------------------#
  
  
  xPlumas1_EFIX64 () {
    
    DEVICE=`grep -B1 '***ERROR #' view_$USERINPUT*_host.log | sort | uniq | grep 'Port' | head -1 | awk -F'|' '{ print $3 }'`
    LOM_P1="[${BLINKRED}**${NC}] Failure Location: ${BLINKRED}Intel LOM Failed${NC}"
    MLOM_P1="[${BLINKRED}**${NC}] Failure Location: ${BLINKRED}MLOM Slot${NC}"
    R1S1_P1="[${BLINKRED}**${NC}] Failure Location: Riser ${BLINKRED}1${NC} Slot ${BLINKRED}1${NC}"
    R2S1_P1="[${BLINKRED}**${NC}] Failure Location: Riser ${BLINKRED}2${NC} Slot ${BLINKRED}1${NC}"
    NVME_P1="[${BLINKRED}**${NC}] Failure Location: ${BLINKRED}NVMe drive${NC}"
    
    echo -e "[${BLINKRED}**${NC}] Platform: Plumas1"
    echo -e "[${BLINKRED}**${NC}] Device Item: [$DEVICE]"
    #-----------------[NO DEVICE]------------------
    if [[ "$(echo "$DEVICE")" == *"00"* ]]; then
      echo -e $LOM_P1
      elif [[ "$(echo "$DEVICE")" == *"3A"* ]]; then
      echo -e $LOM_P1
      #-----------------[MLOM CARD]------------------
      elif [[ "$(echo "$DEVICE")" == *"17"* ]]; then
      echo -e $MLOM_P1
      elif [[ "$(echo "$DEVICE")" == *"19"* ]]; then
      echo -e $MLOM_P1
      elif [[ "$(echo "$DEVICE")" == *"1C"* ]]; then
      echo -e $MLOM_P1
      #-----------------[RISER1SLOT1]----------------
      elif [[ "$(echo "$DEVICE")" == *"5D"* ]]; then
      echo -e $R1S1_P1
      elif [[ "$(echo "$DEVICE")" == *"5F"* ]]; then
      echo -e $R1S1_P1
      elif [[ "$(echo "$DEVICE")" == *"61"* ]]; then
      echo -e $R1S1_P1
      elif [[ "$(echo "$DEVICE")" == *"64"* ]]; then
      echo -e $R1S1_P1
      elif [[ "$(echo "$DEVICE")" == *"65"* ]]; then
      echo -e $R1S1_P1
      elif [[ "$(echo "$DEVICE")" == *"68"* ]]; then
      echo -e $R1S1_P1
      #-----------------[NVMe Drive]-----------------
      elif [[ "$(echo "$DEVICE")" == *"AE"* ]]; then
      echo -e $NVME_P1
      elif [[ "$(echo "$DEVICE")" == *"AE"* ]]; then
      echo -e $NVME_P1
      #-----------------[RISER2SLOT1]----------------
      elif [[ "$(echo "$DEVICE")" == *"D7"* ]]; then
      echo -e $R2S1_P1
      elif [[ "$(echo "$DEVICE")" == *"D9"* ]]; then
      echo -e $R2S1_P1
      elif [[ "$(echo "$DEVICE")" == *"DC"* ]]; then
      echo -e $R2S1_P1
      elif [[ "$(echo "$DEVICE")" == *"E0"* ]]; then
      echo -e $R2S1_P1
      elif [[ "$(echo "$DEVICE")" == *"E2"* ]]; then
      echo -e $R2S1_P1
      
      
    fi
  }
  
  
  xPlumas2_EFIX64 () {
    
    
    DEVICE=`grep -B1 '***ERROR #' view_$USERINPUT*_host.log | sort | uniq | grep 'Port' | head -1 | awk -F'|' '{ print $3 }'`
    
    LOM_P2="[${BLINKRED}**${NC}] LOM device Failed"
    R1S1_P2="[${BLINKRED}**${NC}] Riser 1 Slot 1"
    MLOM_P2="[${BLINKRED}**${NC}] MLOM Card failed"
    R1S2_P2="[${BLINKRED}**${NC}] Riser 1 Slot 2"
    NVME_P2="[${BLINKRED}**${NC}] NVMe Drive failed"
    R2S4_P2="[${BLINKRED}**${NC}] Riser 2 Slot 4"
    R2S5_P2="[${BLINKRED}**${NC}] Riser 2 Slot 5"
    R1S3_P2="[${BLINKRED}**${NC}] Riser 1 Slot 3"
    R2S6_P2="[${BLINKRED}**${NC}] Riser 2 Slot 6"
    
    echo -e "[${BLINKRED}**${NC}] Platform: Plumas2"
    echo -e "[${BLINKRED}**${NC}] Device Item: [$DEVICE]"
    #echo -e "[${YELLOW}!${NC} Please remember that not all the information here is correct sience the PCI Mapping is not Acurrate, please double check the UUT log or ask T.E for that"
    
    #-----------------[NO DEVICE]------------------
    if [[ "$(echo "$DEVICE")" == *"00"* ]]; then
      echo -e $LOM_P2
      #-----------------[SLOT1 RISER1]---------------
      elif [[ "$(echo "$DEVICE")" == *"16"* ]]; then
      echo -e $R1S1_P2
      elif [[ "$(echo "$DEVICE")" == *"17"* ]]; then
      echo -e $R1S1_P2
      elif [[ "$(echo "$DEVICE")" == *"19"* ]]; then
      echo -e $R1S1_P2
      elif [[ "$(echo "$DEVICE")" == *"18"* ]]; then
      echo -e $R1S1_P2
      #-----------------[MLOM CARD]------------------
      elif [[ "$(echo "$DEVICE")" == *"3A"* ]]; then
      echo -e $MLOM_P2
      elif [[ "$(echo "$DEVICE")" == *"3C"* ]]; then
      echo -e $MLOM_P2
      elif [[ "$(echo "$DEVICE")" == *"3F"* ]]; then
      echo -e $MLOM_P2
      #-----------------[SLOT2 RISER1]---------------
      elif [[ "$(echo "$DEVICE")" == *"5D"* ]]; then
      echo -e $R1S2_P2
      elif [[ "$(echo "$DEVICE")" == *"5F"* ]]; then
      echo -e $R1S2_P2
      elif [[ "$(echo "$DEVICE")" == *"62"* ]]; then
      echo -e $R1S2_P2
      elif [[ "$(echo "$DEVICE")" == *"66"* ]]; then
      echo -e $R1S2_P2
      elif [[ "$(echo "$DEVICE")" == *"68"* ]]; then
      echo -e $R1S2_P2
      #-----------------[NVMe Drive]-----------------
      elif [[ "$(echo "$DEVICE")" == *"85"* ]]; then
      echo -e $NVME_P2
      elif [[ "$(echo "$DEVICE")" == *"85"* ]]; then
      echo -e $NVME_P2
      #-----------------[SLOT4 RISER2]---------------
      elif [[ "$(echo "$DEVICE")" == *"AE"* ]]; then
      echo -e $R2S4_P2
      #-----------------[SLOT5 RISER2]---------------
      elif [[ "$(echo "$DEVICE")" == *"B0"* ]]; then
      echo -e $R2S5_P2
      elif [[ "$(echo "$DEVICE")" == *"B3"* ]]; then
      echo -e $R2S5_P2
      elif [[ "$(echo "$DEVICE")" == *"B9"* ]]; then
      echo -e $R2S5_P2
      #-----------------[SLOT3 RISER1]---------------
      elif [[ "$(echo "$DEVICE")" == *"D7"* ]]; then
      echo -e $R1S3_P2
      #-----------------[SLOT6 RISER2]---------------
      elif [[ "$(echo "$DEVICE")" == *"D9"* ]]; then
      echo -e $R2S6_P2
      elif [[ "$(echo "$DEVICE")" == *"DF"* ]]; then
      echo -e $R2S6_P2
      
      
    fi
  }
  
  #-----------------------------------{EFI Functions End}----------------------------------------#
  
  xMorethan2() {
    
    tail -n 1 /tmp/leftover_comm_for_morethan2_ordered.txt \
    | sed 's/.\{1\}$//;s/$/'"0"''/'' >>/tmp/leftover_captured_log_after_tr.txt
    sort /tmp/leftover_captured_log_after_tr.txt >/tmp/leftover_missing_odds_after_sort.txt
    
    diff --old-group-format=$'\033[1;32m%<\033[0m' \
    --new-group-format=$'' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
    | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
    
    diff --old-group-format=$'' \
    --new-group-format=$'        \033[1;31m%>\033[0m' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
    sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
    | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
    
    echo "+---------------------------------------------------------------------+"
    echo -e "[${BLINKRED}*${NC}] NOTE: There is more than one component missing!"
    echo "+---------------------------------------------------------------------+"
    
    rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
    rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
    rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
    rm /tmp/leftover_missing_odds_after_sort.txt
    rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt &>/dev/null
    xCDF
  }
  
  xMore2gt1 () {
    
    head -n 1 /tmp/leftover_comm_for_morethan2_ordered.txt \
    | sed 's/:.*//;s/$/'":0"''/'' >>/tmp/leftover_captured_log_after_tr.txt
    sort /tmp/leftover_captured_log_after_tr.txt >/tmp/leftover_missing_odds_after_sort.txt
    
    diff --old-group-format=$'\033[1;32m%<\033[0m' \
    --new-group-format=$'' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
    | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
    
    diff --old-group-format=$'' \
    --new-group-format=$'        \033[1;31m%>\033[0m' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
    sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
    | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
    
    echo "+---------------------------------------------------------------------+"
    echo -e "[${BLINKRED}*${NC}] NOTE: There is more than one component missing!"
    echo "+---------------------------------------------------------------------+"
    rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
    rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
    rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
    rm /tmp/leftover_missing_odds_after_sort.txt
    rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt &>/dev/null
    xCDF
  }
  
  xMoreOrdered() {
    
    tail /tmp/leftover_comm_for_morethan2_ordered.txt \
    | sed 's/:.*//;s/$/'":0"''/'' >>/tmp/leftover_captured_log_after_tr.txt
    sort /tmp/leftover_captured_log_after_tr.txt >/tmp/leftover_missing_odds_after_sort.txt
    
    diff --old-group-format=$'\033[1;32m%<\033[0m' \
    --new-group-format=$'' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
    | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
    
    diff --old-group-format=$'' \
    --new-group-format=$'        \033[1;31m%>\033[0m' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
    sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
    | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
    
    echo "+---------------------------------------------------------------------+"
    echo -e "[${BLINKRED}*${NC}] NOTE: There is more than one component missing!"
    echo "+---------------------------------------------------------------------+"
    rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
    rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
    rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
    rm /tmp/leftover_missing_odds_after_sort.txt
    rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt &>/dev/null
    xCDF
  }
  
  x2Captured () {
    
    tail /tmp/leftover_comm_for_morethan2_captured.txt \
    | sed 's/:.*//;s/$/'":0"''/'' >>/tmp/leftover_captured_log_after_tr.txt \
    sort /tmp/leftover_captured_log_after_tr.txt >/tmp/leftover_missing_odds_after_sort.txt
    
    diff --old-group-format=$'\033[1;32m%<\033[0m' \
    --new-group-format=$'' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
    | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
    
    diff --old-group-format=$'' \
    --new-group-format=$'        \033[1;31m%>\033[0m' \
    --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
    sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
    | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
    
    echo "+---------------------------------------------------------------------+"
    echo -e "[${BLINKRED}*${NC}] NOTE: There is more than one component missing!"
    echo "+---------------------------------------------------------------------+"
    rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
    rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
    rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
    rm /tmp/leftover_missing_odds_after_sort.txt
    rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt &>/dev/null
    xCDF
  }
  
  
  xExtra() {
    
    diff --old-group-format=$'' \
    --new-group-format=$'%>' \
    --unchanged-group-format=$'' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_captured_log_after_tr.txt \
    | sed 's/.\{1\}$//;s/$/'"0"''/'' >>/tmp/leftover_ordered_log_after_tr.txt
    
    sort /tmp/leftover_ordered_log_after_tr.txt >/tmp/leftover_extra_odds_after_sort.txt
    
    diff --old-group-format=$'\033[1;32m%<\033[0m' \
    --new-group-format=$'' \
    --unchanged-group-format=$'%=' /tmp/leftover_extra_odds_after_sort.txt /tmp/leftover_captured_log_after_tr.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
    | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
    
    diff --old-group-format=$'' \
    --new-group-format=$'        \033[1;31m%>\033[0m' \
    --unchanged-group-format=$'%=' /tmp/leftover_extra_odds_after_sort.txt /tmp/leftover_captured_log_after_tr.txt \
    | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
    sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
    | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
    
    echo "+---------------------------------------------------------------------+"
    
    rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
    rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
    rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
    rm /tmp/leftover_extra_odds_after_sort.txt
    rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt
    xCDF
  }
  
  
  #echo "Please Select the failure number"
  NOW_DATE=`date +%Y%m%d%I%M`
  SET_DATE=`date +201810060520`
  
  if [[ "$NOW_DATE" -lt "$SET_DATE" ]]; then
    
    #       echo "set date is greater"
    
    echo "+----------------------------------------+"
    echo "| ID |             Failure               |"
    echo "|----+-----------------------------------|"
    echo -e "| 1  |${RED} DIMM:SEL       ${NC}                   |"
    echo -e "| 2  |${RED} CHECK_SEL${NC}                         |"
    echo -e "| 3  |${RED} UTIL_CNFV2_LEFTOVER_CHECK${NC}         |"
    echo -e "| 4  |${RED} BMC Voltsensor${NC}                    |"
    echo -e "| 5  |${RED} BMC Tempsensor${NC}                    |"
    echo -e "| 6  |${RED} BMC GPIO${NC}                          |"
    echo -e "| 7  |${RED} BMC Baseboard ${NC}                    |"
    echo -e "| 8  |${RED} BMC NCSI${NC} \033[96m**NEW**\033[0m                  |"
    echo -e "| 9  |${RED} BMC FAN${NC} \033[96m**NEW**\033[0m                   |"
    echo -e "| 10 |${RED} EFI PCIX64${NC} \033[96m**NEW**\033[0m                |"
    echo "+----------------------------------------+"
    
    
    
  else
    
    echo "+----------------------------------------+"
    echo "| ID |             Failure               |"
    echo "|----+-----------------------------------|"
    echo -e "| 1  |${RED} DIMM:SEL       ${NC}                   |"
    echo -e "| 2  |${RED} CHECK_SEL${NC}                         |"
    echo -e "| 3  |${RED} UTIL_CNFV2_LEFTOVER_CHECK${NC}         |"
    echo -e "| 4  |${RED} BMC Voltsensor${NC}                    |"
    echo -e "| 5  |${RED} BMC Tempsensor${NC}                    |"
    echo -e "| 6  |${RED} BMC GPIO${NC}                          |"
    echo -e "| 7  |${RED} BMC Baseboard ${NC}                    |"
    echo -e "| 8  |${RED} BMC NCSI${NC}                          |"
    echo -e "| 9  |${RED} BMC FAN${NC}                           |"
    echo -e "| 10 |${RED} EFI PCIX64${NC}                        |"
    echo "+----------------------------------------+"
    
    
    #       echo "now date is greater"
  fi
  
  printf "[${MAGNETA}+${NC}] Please enter the failure ID ${MAGNETA}~${NC}> "; read FAILURE
  
  echo -e "Date: `date`	User: ${USER}	 Station: ${HOSTNAME}	System: ${USERINPUT}	Failure ID# ${FAILURE}" >> /home/noora/log.s
  if 	[ "$FAILURE" == "" ] || [ "$FAILURE" == " " ]; then
    echo ""
    echo "+--------------------------------------------+"
    echo -e "|${RED} Error - Please enter a vaild Failure ID#${NC}   |"
    echo "+--------------------------------------------+"
    echo ""
    exit 51
  fi
  
  if	[ "$FAILURE" == "1" ]; then
    
    xM5Path
    echo -e "[${MAGNETA}+${NC}] Now checking unit history."
    xUser
    xIP
    xMac
    xSNfind
    echo -e "[${MAGNETA}+${NC}] Entered logs location."
    echo -e "[${MAGNETA}+${NC}] Dumping logs information."
    echo "+--------------------------------------------------------------------------------------------------------+"
    grep  "ECC" view_$USERINPUT*_bmc.log | grep Memory
    grep  "ECC" view_$USERINPUT*_main.log | grep Memory
    echo "+--------------------------------------------------------------------------------------------------------+"
    echo ""
    xCDF
  fi
  
  if	[ "$FAILURE" == "2" ]; then
    
    xM5Path
    echo -e "[${MAGNETA}+${NC}] Now checking unit history."
    xUser
    xSNfind
    echo -e "[${MAGNETA}+${NC}] Entered logs location."
    echo -e "[${MAGNETA}+${NC}] Dumping logs information."
    
    echo "+--------------------------------------------------------------------------------------------------------+"
    #grep  "error" view_$USERINPUT*_bmc.log | grep -E -v 'error\"|\#2=55'
    #grep -E 'Critical|error|Upper Non|going low|going high' view_$USERINPUT*_bmc.log | grep -E -v 'error"|cal"|#2=55|wc -l' # | awk '{gsub (/ECC/, ${RED} ECC ${NC} print $0 END}'
    grep --color=always -E 'Critical|error|Upper Non|going low|going high| CPU |Port' view_$USERINPUT*_bmc.log | grep -E -v 'error"|Sever|#2=55|@|link|PORT|sky|addr|Switch|wc -l|SOL|Com|dump|Loopback|udi' 2&>/dev/null
    
    grep --color=always -E 'Critical|error|Upper Non|going low|going high| CPU |Port' view_$USERINPUT*_main.log | grep -E -v 'error"|Sever|#2=55|@|link|PORT|sky|addr|Switch|wc -l|dump|SOL|Com|Loopback|udi'
    echo "+--------------------------------------------------------------------------------------------------------+"
    xCDF
  fi
  
  if	[ "$FAILURE" == "10" ]; then #EFI Failure
    
    xM5Path
    echo -e "[${MAGNETA}+${NC}] Now checking unit history."
    xUser
    xSNfind
    echo -e "[${MAGNETA}+${NC}] Entered logs location."
    echo -e "[${MAGNETA}+${NC}] Dumping logs information."
    echo "+---------------------------------+"
    PLATFORM=`grep 'Board S/N' view_$USERINPUT*_host.log | uniq | awk '{print $4}'`
    
    if [[ "$(echo "$PLATFORM")" == *"Plumas1"* ]]; then
      xPlumas1_EFIX64
      elif [[ "$(echo "$PLATFORM")" == *"Plumas2"* ]]; then
      xPlumas2_EFIX64
    fi
    echo "+---------------------------------+"
    xCDF
    
  fi
  
  if	[ "$FAILURE" == "4" ] || [ "$FAILURE" == "5" ] || [ "$FAILURE" == "5" ] || [ "$FAILURE" == "6" ] || [ "$FAILURE" == "7" ] || [ "$FAILURE" == "8" ] || [ "$FAILURE" == "9" ]; then
    
    xM5Path
    echo -e "[${MAGNETA}+${NC}] Now checking unit history."
    xUser
    xIP
    xMac
    xSNfind
    echo -e "[${MAGNETA}+${NC}] Entered logs location."
    echo -e "[${MAGNETA}+${NC}] Dumping logs information."
    
    echo "+--------------------------------------------------------------------------------------------------------+"
    #grep  "error" view_$USERINPUT*_bmc.log | grep -E -v 'error\"|\#2=55'
    grep -E --color=always '\-\-\-failed\-\-\-' view_$USERINPUT*_bmc.log \
    | grep -E -v 'error"|#2=55|wc -l'
    echo "+--------------------------------------------------------------------------------------------------------+"
    xCDF
  fi
  
  if    [ "$FAILURE" == "3" ]; then
    
    xM5Path
    echo -e "[${MAGNETA}+${NC}] Now checking unit history."
    xUser
    xIP
    xMac
    xSNfind
    echo -e "[${MAGNETA}+${NC}] Entered logs location."
    echo -e "[${MAGNETA}+${NC}] Dumping logs information."
    
    echo "+---------------------------------------------------------------------+"
    #grep -E 'Order\[' type_$USERINPUT*_main.log >/tmp/cnfv2_leftover_log_output.txt
    grep -E 'Order\[' type_$USERINPUT*_main.log \
    | uniq | tail -n -2 | grep -E -v 'Leftover' \
    | sed 's/.*\[\([^]]*\)\].*/\1/g' >/tmp/leftover_order_log.txt
    grep -E 'Captured\[' type_$USERINPUT*_main.log \
    | uniq | tail -n -2 | grep -E -v 'Leftover' \
    | sed 's/.*\[\([^]]*\)\].*/\1/g' >/tmp/leftover_captured_log.txt
    
    #chmod 700 /tmp/leftover_order_log.txt && chmod 700 /tmp/leftover_captured_log.txt
    
    echo "|       ORDERED ITEMS             |            CAPTURED ITEMS         |"
    echo "+---------------------------------------------------------------------+"
    CAPTURED=`cat /tmp/leftover_captured_log.txt`
    ORDERED=`cat /tmp/leftover_order_log.txt`
    LEFTOVER_CAPTURED=$(echo $CAPTURED | tr "|" "\n")
    LEFTOVER_ORDERED=$(echo $ORDERED | tr "|" "\n")
    
    for CAPTURED_ITEMS in $LEFTOVER_CAPTURED; do
      echo $CAPTURED_ITEMS
    done | awk '{gsub (/^HX/,"UCS"); print}' | sort  >/tmp/leftover_captured_log_after_tr.txt
    #
    for ORDERED_ITEMS in $LEFTOVER_ORDERED; do
      echo $ORDERED_ITEMS
    done | awk '{gsub (/^HX/,"UCS"); print}' | sort  >/tmp/leftover_ordered_log_after_tr.txt
    
    
    COUNT_ORDERED=`awk 'END {print NR}' /tmp/leftover_ordered_log_after_tr.txt`
    COUNT_CAPTURED=`awk 'END {print NR}' /tmp/leftover_captured_log_after_tr.txt`
    
    if [ "$COUNT_ORDERED" != "$COUNT_CAPTURED" ]; then
      
      grep -E 'Leftover Comparing: Order\[' type_$USERINPUT*_main.log \
      | sed -e 's/.*\[\([^]]*\)\].*/\1/g;/^[[:space:]]*$/d' \
      | tr "|" "\n" >/tmp/leftover_comm_for_morethan2_ordered.txt
      grep -E 'VS Leftover Captured\[' type_$USERINPUT*_main.log \
      | sed 's/.*\[\([^]]*\)\].*/\1/g;/^[[:space:]]*$/d' \
      | tr "|" "\n" >/tmp/leftover_comm_for_morethan2_captured.txt
      
      MORETHAN2_ORDERED=`awk 'END {print NR}' /tmp/leftover_comm_for_morethan2_ordered.txt`
      MORETHAN2_CAPTURED=`awk 'END {print NR}' /tmp/leftover_comm_for_morethan2_captured.txt`
      
      if [ "$MORETHAN2_ORDERED" == "2" ] && [ "$MORETHAN2_CAPTURED" == "1" ]; then
        xMore2gt1
        elif [ "$MORETHAN2_ORDERED" == "3" ] && [ "$MORETHAN2_CAPTURED" == "2" ]; then
        xMorethan2
        elif [ "$MORETHAN2_ORDERED" == "4" ] && [ "$MORETHAN2_CAPTURED" == "3" ]; then
        xMorethan2
        elif [ "$MORETHAN2_ORDERED" == "2" ] && [ "$MORETHAN2_CAPTURED" == "0" ]; then
        xMoreOrdered
        elif [ "$MORETHAN2_ORDERED" == "0" ] && [ "$MORETHAN2_CAPTURED" == "2" ]; then
        x2Captured
        elif [ "$MORETHAN2_ORDERED" == "0" ] && [ "$MORETHAN2_CAPTURED" == "3" ]; then
        x2Captured
        elif [ "$MORETHAN2_ORDERED" == "0" ] && [ "$MORETHAN2_CAPTURED" == "4" ]; then
        x2Captured
        elif [ "$MORETHAN2_ORDERED" -lt  "$MORETHAN2_CAPTURED" ]; then
        xExtra
      else
        #tail -n 1 /tmp/leftover_comm_for_morethan2_ordered.txt | sed 's/.\{1\}$//;s/$/'"0"''/'' >>/tmp/leftover_captured_log_after_tr.txt
        
        
        diff --old-group-format=$'%<' \
        --new-group-format=$'' \
        --unchanged-group-format=$'' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_captured_log_after_tr.txt \
        | sed 's/.\{1\}$//;s/$/'"0"''/'' >>/tmp/leftover_captured_log_after_tr.txt
        
        sort /tmp/leftover_captured_log_after_tr.txt >/tmp/leftover_missing_odds_after_sort.txt
        
        diff --old-group-format=$'\033[1;32m%<\033[0m' \
        --new-group-format=$'' \
        --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
        | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
        | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
        
        
        diff --old-group-format=$'' \
        --new-group-format=$'        \033[1;31m%>\033[0m' \
        --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_missing_odds_after_sort.txt \
        | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
        sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
        | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
        
        echo "+---------------------------------------------------------------------+"
        rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
        rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
        rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
        rm /tmp/leftover_comm_for_morethan2_ordered.txt /tmp/leftover_comm_for_morethan2_captured.txt &>/dev/null
        rm /tmp/leftover_missing_odds_after_sort.txt
        xCDF
        
      fi
    fi
    
    if [ "$COUNT_ORDERED" == "$COUNT_CAPTURED" ]; then
      
      
      diff --old-group-format=$'\033[1;32m%<\033[0m' \
      --new-group-format=$'' \
      --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_captured_log_after_tr.txt \
      | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:cntrl:]]/ s/$/ \x1b[0m/' \
      | sed 's/^/|    /g' >/tmp/leftover_ordered_diff.txt
      
      diff --old-group-format=$'' \
      --new-group-format=$'        \033[1;31m%>\033[0m' \
      --unchanged-group-format=$'%=' /tmp/leftover_ordered_log_after_tr.txt /tmp/leftover_captured_log_after_tr.txt \
      | sed -r 's/\x1b\[([0-9]{1,2}(;[0-0]{1,2})?)?[mGK]//g; /^[[:space:]]/ s/$/ \x1b[0m/' >/tmp/leftover_captured_diff.txt
      #awk '{if ($1 ~ /[[:cntrl:]]/) print $0, "      \033[0m"; else print $0 }' /tmp/leftover_captured_diff.txt >/tmp/leftover_captured_re.txt
      #awk '{if ($1 ~ /[[:cntrl:]]/) print $0, "      \033[0m"; else print $0 }' /tmp/leftover_ordered_diff.txt >/tmp/leftover_ordered_re.txt
      sdiff -w80 /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt \
      | sed 's/<//g;s/>//g;s/ |//g' #to remove the comparisson ch.
      
      echo "+---------------------------------------------------------------------+"
      
      rm /tmp/leftover_order_log.txt /tmp/leftover_captured_log.txt
      rm /tmp/leftover_captured_log_after_tr.txt /tmp/leftover_ordered_log_after_tr.txt
      rm /tmp/leftover_ordered_diff.txt /tmp/leftover_captured_diff.txt
      rm /tmp/leftover_ordered_re.txt /tmp/leftover_captured_re.txt &>/dev/null
      xCDF
    fi
  fi
)


