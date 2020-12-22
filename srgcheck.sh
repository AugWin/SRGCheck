#!/bin/bash
# MUDG Script Check/Hardening
# For TMOS v14.x/v15.x
# August Winterstein  august@f5.com
# Last update 12/14/2020

# Instructions
# Copy srgcheck.sh and infile.txt to a directory on the BIG-IP and run

clear

### Vars
infile=infile.txt
output=config.txt
logfile=srglog.txt
fixfile=fixfile.txt
okcount=0
fixcount=0

# Colors
Red=$(tput bold;tput setaf 1)
Grn=$(tput bold;tput setaf 2)
Whi=$(tput bold;tput setaf 7)

### Script

# Init output files
echo "##### srgcheck.sh script run at $(date)" > $output
echo "##### $(date) To restore config settings, run 'tmsh load sys config merge file <filename>'" > $output

echo "##### srgcheck.sh script run at $(date)" >> $logfile

if [ -f "$fixfile" ]; then
   rm $fixfile
fi

# Loop through infile.txt to run checks
while read l; do

   lcom=$(echo "$l" | cut -d# -f1)

   cfgval="${l##*#}"
   cfgoutput=$(eval $l 2>&1)
   echo "$cfgoutput" >> $output

   cfgset=$(echo "$cfgoutput" | awk 'NR==2')
   cfgmatch=$(echo "$cfgoutput" | grep -w "$cfgval")
   echo "Checking $lcom..."

   # Config wrong
   if [[ -z $cfgmatch ]]; then
      fixcount=$((fixcount+1))
      echo "${Red}'$cfgset'${Whi} Should be '$cfgval'"
      echo "FIX: $lcom '$cfgset' Should be '$cfgval'" >> $logfile
      echo "${lcom/list/modify} $cfgval" >> $fixfile

   # Config good
   else
      okcount=$((okcount+1))
      echo "${Grn}'$cfgset'...[OK!]${Whi}"
      echo "$lcom '$cfgset'...[OK!]" >> $logfile
   fi
done < $infile

yn="y"
echo "........................."
echo "${Grn}$okcount${Whi} config items are correct."
echo "${Red}$fixcount${Whi} config items need to be fixed."
if [ "$fixcount" -eq "0" ]; then
   echo "Config correct. Nothing to do!"
   echo "Exiting!"
   echo "Config correct. Nothing to do!" >> $logfile
   echo "Exiting!" >> $logfile
else  
   echo "Do you want to ${Grn}FIX${Whi} ${Red}$fixcount incorrectly${Whi} configured items? (y/n)"
   read -n1 yn
   if [[ "$yn" == "y" ]]; then
      while read f; do
         echo "$f"
         $f
      done < $fixfile
      tmsh save sys config
      bigstart restart httpd
      echo "Fixed $fixcount items!"
      echo "See $fixfile to see what was modified."
      echo "Use $output to restore config."
      echo "Exiting!"
      echo "Fixed $fixcount items!" >> $logfile
      echo "See $fixfile to see what was modified." >> $logfile
      echo "Use $output to restore config." >> $logfile
      echo "Exiting!" >> $logfile

   fi
fi
