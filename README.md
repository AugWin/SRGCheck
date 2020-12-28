# SRGCheck
 
Runs on a BIG-IP to configure to STIGs/SRGs for DoDIN APL.  Currently configures BIG-IP v14.1+

# Instructions
1. Copy infile.txt and srgcheck.sh to a directory on the BIG-IP
2. chmod +x srgcheck.sh
3. Run srgcheck.sh

# What it does
1. Takes a backup of the current BIG-IP configuration items found in infile.txt
2. Checks the BIG-IP config against settings in infile.txt
3. Creates fixfile.txt which contains commands to bring BIG-IP inline with recommended settings.
4. Optionally allows you to correct settings.
5. Logs to srglog.txt

You can run the script repeatedly as an auditing tool to verify configuration without changing anything on the BIG-IP.
