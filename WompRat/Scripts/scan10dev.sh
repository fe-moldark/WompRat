#!/bin/bash



USER=skywalker # Just create a new user account with this name please and make life easier...


# Configure and create where the log files will be saved to
getDate=$(date +"%Y-%m-%d")
getTime=$(date +"%H-%M-%S")
baseFolder="/home/$USER/WompRat/Logs/$getDate/$getTime"
umask 0022
subFolder="$baseFolder/nmapScans"
logFile="log.csv"
arpFile="arpTable.log"
mkdir -p "/home/$USER/WompRat/Logs/$getDate"
mkdir $baseFolder
mkdir $subFolder
touch "$baseFolder/$logFile"
touch "$baseFolder/stdouterr.log"


# To troubleshoot, uncomment below so you can see the output live
exec > "$baseFolder/stdouterr.log" 2>&1


while getopts ":n:m:f:t:d:" opt; do
  case $opt in
  n) network=$OPTARG ;;
  m) mask=$OPTARG ;;
  f) remote_router=$OPTARG ;;
  t) router_type=$OPTARG ;;
  d) dns_server=$OPTARG ;; 
  *) echo "Usage: $0 -n network -m mask  -f remote_router -t router_type -d dns_server" >&2; exit 1 ;;
  esac
done


# Depending on how this is being scanned, formats it for nmap to use
if [[ $network == *"-"* ]]; then
    #echo ".RangeProvided"
    subnet="$network"
else
    #echo ".AssumingMask"
    subnet="$network/$mask"
fi


# Type 1 = Fortigate, Type 2 = PfSense
if [[ "$router_type" == "0" ]]; then # Ignore case
    #echo " + Firewall type: None designated"
    :
elif [[ "$router_type" == "1" ]]; then
    #echo " + Firewall type: Fortigate"
    :
elif [[ "$router_type" == "2" ]]; then
    #echo " + Firewall type: PfSense"
    :
else
    echo " + Router type invalid - $router_type. Exiting now. "
    exit 1
fi


# Load in MAC-based alerts
alerts_location="/home/$USER/WompRat/Data/alerts.csv"
declare -A alerts_dict
skipHeader=0
while IFS=',' read -r mac_a email_a message_a; do # Skips the header and reads in each line according to the given 3-column csv format
    ((skipHeader++))
    if [ "$skipHeader" -eq 1 ]; then
        continue
    fi

    alerts_dict["$mac_a"]="$email_a,$message_a"
done < "$alerts_location"



# -----------------------------ARP tables section-----------------------------
declare -A ip_mac_dict
touch "$baseFolder/$arpFile"

# Hard-coded credentials, yay! - if these differ based on profile, define them below
user="your_service_account_username"
pass="your_password_here"


if [[ "$router_type" == "0" ]]; then # Keeps dict empty
    statusArp="Router type: None designated, no arp cache pulled."
    #echo "Since the router option was disabled, the provided IP range will be scanned using direct pings only to detect if hosts are online."

elif [[ "$router_type" == "1" ]]; then # Fortigate profile

    touch "$baseFolder/$arpFile"

    # Run the SSH command and capture the output
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user@$remote_router" "get system arp" > "$baseFolder/$arpFile"

    # Using the arp table we just pulled, create a dictioanry of the IPs + MACs
    while read -r line; do
        if [[ "$line" =~ ^Address || ! "$line" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then # Only looking for lines that have IPs
            continue
        fi

        ip_d=$(echo "$line" | awk '{print $1}')
        mac_d=$(echo "$line" | awk '{print $3}')

	if [[ -v ip_mac_dict["$ip_d"] ]]; then # Skip, already present
	    :
        else
            ip_mac_dict["$ip_d"]="$mac_d"
        fi

    done < "$baseFolder/$arpFile"


elif [[ "$router_type" == "2" ]]; then # pfsense profile - I defined the user/pass in that exp file below

    /usr/bin/expect -f "/home/$USER/WompRat/Scripts/pfsense_login.exp" "$remote_router" > "$baseFolder/$arpFile"


    while read -r line; do
	if [[ "$line" =~ ") at " ]]; then # Indiciates an entry

            ip_d=$(echo "$line" | awk '{print $2}' | tr -d '()')
            mac_d=$(echo "$line" | awk '{print $4}')

	    if [[ -v ip_mac_dict["$ip_d"] ]]; then # Skip, already present
		:
            else
                ip_mac_dict["$ip_d"]="$mac_d"
            fi

        fi

    done < "$baseFolder/$arpFile"



else

    echo " ! Invalid Router type submitted for the arp cache!"
    exit 1 # This'll just mess things up. Fix it first.

fi

# ----------------------------------------------------------------------------



# -----------------------------DNS server section-----------------------------

dns_queries="$baseFolder/dns_data.log"
dns_data_reformatted="$baseFolder/dns_data_reformatted.log"
touch $dns_queries
declare -A dns_ip_dict

if [[ "$dns_server" == "0" ]]; then
    : # Pass for now, this feature was dsabled
else

    # Again, hard coded credentials, yay! Reference the 'integrating your dns page' on how to set up this account
    samba-tool dns query $dns_server yourdomain.local @ A -U "yourdomain\username%very_secure_password" > $dns_queries

    echo "Name=" >> $dns_queries # Needed for one time formatting issue, leave here
    count_just_once=0

    while read -r line; do
    
        if [[ "$(echo "$line" | awk '{print $1}')" =~ "Name=" ]]; then
	    count_just_once=$((count_just_once + 1))

	    if [[ $count_just_once -gt 2 ]]; then
	        dns_ip_dict["$current_ip"]="${current_ns:5:-1}"
	    fi

	    if [[ $count_just_once -gt 1 ]]; then
	        current_ns="$(echo "$line" | awk '{print $1}')"
	        current_ip='NA'
	    fi

        else
	    # think I need another if check to see if count_just_once is greater than 1 or 2
	    if [[ "$count_just_once" -eq 1 ]]; then
	        # Still on the first lines we want to skip
	        :
	    else
	        if [[ "$current_ip" == "NA" ]]; then
                    current_ip="$(echo "$line" | awk '{print $2}')"
	        else
                    : # pass for now
	        fi
	    fi
    
        fi

    done < "$dns_queries"


    # That file is the cleaned up version of the dns data we will be using later in the script
    for key in "${!dns_ip_dict[@]}"; do
        echo "$key,${dns_ip_dict[$key]}" >> "$dns_data_reformatted"
    done

fi

# ----------------------------------------------------------------------------



# -------------------------Whitelisted MACs section---------------------------

whitelisted_macs_file="/home/$USER/WompRat/Data/whitelisted_macs.csv"
whitelisted_macs_vendors_file="/home/$USER/WompRat/Data/whitelisted_macs_vendors.csv"


# White-listed MACs and MAC vendors
knownMacs=$(awk -F',' '{print $1}' $whitelisted_macs_file)
knownMacsVendors=$(awk -F',' '{print $1}' $whitelisted_macs_vendors_file)

declare -A knownMacsDict
declare -A knownMacsVendorsDict

while IFS=',' read -r macID descriptor _; do
    knownMacsDict["$macID"]="$descriptor"
done < $whitelisted_macs_file

while IFS=',' read -r macID descriptor _; do
    knownMacsVendorsDict["$macID"]="$descriptor"
done < $whitelisted_macs_vendors_file

# ----------------------------------------------------------------------------




sleep 0.5
echo -e "\nWelcome to the Kent NetGuard script."
sleep 0.5
echo " + Logs from this scan will be saved to: $baseFolder"
sleep 0.5
echo " + Loaded whitelisted MAC file, $(echo $knownMacs | wc -w) total entries."
sleep 0.5
echo " + Loaded whitelisted MAC vendors file, $(echo $knownMacsVendors | wc -w) total entries."
sleep 0.5
echo " + Loaded in a total of ${#alerts_dict[@]} MAC alerts."
sleep 0.5

if [[ "$router_type" == 0 ]]; then
    echo " + You chose not to provide a router to pull an arp table from."
    echo " + Direct ping/arp requests will be used, no router for an arp table was designated." >> "$baseFolder/$arpFile"
else
    echo " + An arp table request from $remote_router resulted in ${#ip_mac_dict[@]} arp entries."
fi

sleep 0.5

if [[ "$dns_server" == "0" ]]; then
    echo " + No DNS server was designated."
else
    echo " +  A DNS server at $dns_server was queried, resulting in ${#dns_ip_dict[@]} entries."
fi



# Generate IP list using the network and/or mask provided in the arguments
listIPs=$(nmap -sL -n $subnet | awk '{print $NF}' | sed '1d;$d') # Get list only of possible IPs in scope, and omit the first+last entries (just text)

logData=()
investigateIPs=()



echo -e "\n>> Online hosts in scope:"
for IP in $listIPs; do

    # This is only needed when it's the default gateway address, I believe
    _ip=$(echo "$IP" | tr -d '()') # This should no longer be needed after disabling the hostname resolution

    

    if [[ "$router_type" == "0" ]]; then # Rely on direct ping scans only
	if ping -c 6 $_ip | grep -q "ttl"; then
	    proceed=true

	    # Since no arp table from router, need to use whatever it discovered during the confirmed ping
	    # Reminder, this'll only work on a LOCAL network
	    mac_d=$(echo "$(arp -a $_ip)" | awk '{print $4}')
	    
	    if [[ -v ip_mac_dict["$_ip"] ]]; then # Skip, already present
                # echo "$ip_d already present"
		:
            else
                ip_mac_dict["$_ip"]="$mac_d"
            fi

            # Log it for troubleshooting and reference for now
	    echo "$(arp -a $_ip)" >> "$baseFolder/$arpFile"

	else
	    proceed=false
	fi

    else
        if [[ -v ip_mac_dict["$_ip"] ]]; then # Rely on ping scans & arp table from routers
	    proceed=true
	else
	    proceed=false
	fi
    fi


    # Determined to be an online host
    if [[ "$proceed" == "true" ]]; then
        echo " + $_ip"
   
        # The justOneLine is the "line" of data it collects that will be appended to the log.csv file
	justOneLine=''

	# Check if IP is associated with any dns records since we trust domain-joined devices (assuming correctly configured server)



        # -------------------------DNS Check----------------------------
	# Moved away from actual nslookup queries, but keeping this format for now
        if [[ "$dns_server" == "0" ]]; then # DNS server option is disabled
	    nslookupResult="No DNS server designated"

	else # Server was designated, so checking records
	    if [[ -v dns_ip_dict[$_ip] ]]; then # Means IP found a match in the dns entry using the logon method and the created dictionary
	        nslookupResult="Valid dns entry found in $dns_server." # MUST keep string 'alt method 2' in here
	    else
		nslookupResult="server can't find $_ip"
	    fi
	fi
	# -------------------------------------------------------------


        
        # -------------------------Known MAC Check----------------------
	if [[ -n "${ip_mac_dict["$_ip"]}" ]]; then # IP exists in the dictionary, pull its MAC
	    macLookupResult="${ip_mac_dict["$_ip"]}"
	else
	    macLookupResult="MAC not found in arp table"
	fi


	# Check for MAC alerts here briefly, send an email alert if identified
	if [[ -v alerts_dict[$macLookupResult] ]]; then
	    IFS=',' read -r sendRecipient sendReason <<< "${alerts_dict[$macLookupResult]}"
	    bodyContent=" + You have an alert set up for: $macLookupResult, with the reason being: $sendReason. Latest IP for this device was: $_ip."
            /usr/bin/python3 /home/$USER/WompRat/Scripts/send_email_v3.py --recipient "$sendRecipient" --subject "MAC Alert - $macLookupResult" --body "$bodyContent"

            justOneLine+="$macLookupResult,MAC Alert was sent!,"
	else
            justOneLine+="$macLookupResult,,"
        fi
	# -------------------------------------------------------------
        
	
        # File is eventually exported to a csv, hence the odd commas - helps with formatting later, just trust me
        justOneLine+="$_ip,,"



        # ------------------------Decide which IPs to investigate------
        if echo "$nslookupResult" | grep -q "server can't find" || [[ "$dns_server" == "0" ]] then
            # No valid dns entry for it or no trusted dns server provided
	    if [[ -v knownMacsDict[$macLookupResult] ]]; then
		justOneLine+="${knownMacsDict[$macLookupResult]},No DNS entries (or no server designated) but a MAC address was found in the white listed file."

            elif [[ -v knownMacsVendorsDict[${macLookupResult:0:8}] ]]; then
                justOneLine+="${knownMacsVendorsDict[${macLookupResult:0:8}]},No DNS entries (or no server designated) but a MAC address Vendor was found in the white listed vendors file."

	    else
		justOneLine+=",! No DNS entries (or no server designated) and MAC address was not found in the white listed files."
                
                investigateIPs+=("$_ip")
            fi

	else
	    justOneLine+=",Record in $dns_server found so not scanning."

        fi
	# -------------------------------------------------------------
    
	echo "$justOneLine" >> "$baseFolder/$logFile"
    
    else
        : # One of those exceptions where nmap thought it was online, but it was wrong. Could also be dropping icmp traffic
    fi

done


echo -e "\n\n>> Further scanning required for:"


# ------------------------Begin nmap scans of list-------------

# Now for scanning each host we flagged as unknown to us
for IP in ${investigateIPs[@]}; do
    
    echo " + $IP"
    writeIP="${IP//./_}" # Just reformatting for filename

    # Scanning so few ports should be quick - not all will be open and just conducting a service version scan for those few
    /usr/bin/nmap -oN "$subFolder/$writeIP.nmap" --host-timeout=180 -p 21,22,23,80,443,25,110,53,139,445,3306,3389,514,3128,1080,5000,4444,8888,6660-6669,1980,3001,7000 -v -Pn -sV $IP > /dev/null 2>&1
    echo "   - done, logged to $subFolder/$writeIP.nmap"

done
# -------------------------------------------------------------

echo -e "\n + Reminder, logs saved to: $baseFolder"
sleep 1

exit 0
