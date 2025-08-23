#!/bin/bash
# Using the log files, generate a single file of what unknown devices were discovered + scanned on a particular day


# If an argument was entered, use it, otherwise default to today
if [ "$#" -eq 1 ]; then
    getDate="$1"
else
    getDate=$(date +"%Y-%m-%d")
fi

echo "Date: $getDate"

baseFolder="/home/$USER/WompRat/Logs/$getDate/"


# Check if the folder exists
if [ -d "$baseFolder" ]; then
    : # Just continue, folder exists
else
    echo "! Folder $baseFolder does not exist!. Exiting now."
    exit 1
fi

echo -e "\n + Searching '$baseFolder' for log files.\n"

mac_vendors_file="/home/$USER/WompRat/Data/mac-vendors-export.csv"


# Download your own copy from https://maclookup.app/downloads/csv-database
mac_export=$'\n' read -d '' -r -a csv_array < $mac_vendors_file

# Create a list to not repeat the IP in the report... cause that gets old real fast
referencedIPs=()


# $baseFolder is path to the log date
for folder in $(ls $baseFolder); do
    
    doOncePerFolder=true
    
    if [ -z "$(ls $baseFolder$folder/nmapScans)" ]; then
        : # Empty directory, so there were no follow-up scans
    else
        # Print out every file in there + info from the log file
        for file in $(ls $baseFolder$folder/nmapScans); do
            if [[ ! " ${referencedIPs[@]} " =~ " ${file} " ]]; then
                grepIP="${file//_/.}" # Reformat it

                referencedIPs+=("$file")
                if [ $doOncePerFolder == true ]; then
                    echo -e " + Subdirectory: $folder\n"
                    doOncePerFolder=false
                fi

                normalizeIP=$(echo ${grepIP%?????})
                # Get the MAC of the IP from the main log file
                checkMAC=$(cat $baseFolder$folder/log.csv | grep -i "${normalizeIP}," | cut -c 1-17)
                echo " > ${grepIP%?????} : $checkMAC"

                searchForMac="${checkMAC:0:8}"
                vendorInfo="NA"

                while IFS=',' read -r column1 column2
                do
                    # Check if the first column matches the current search value
                    if [[ "${column1,,}" == "${searchForMac,,}" ]]; then
                        vendorInfo="$column2"
                        break
                    fi
                done < $mac_vendors_file
                echo " > Mac vendor info from local db : $vendorInfo"

                cat "$baseFolder$folder/nmapScans/$file"
                echo -e "\n"
            else
                : # echo "!!! Finally got it! Caught duplicate entry: $file. Remove this check later."
            fi
        done
    fi
    echo -e "\n"

done


# Final catalog of unknown devices' IPs
echo " + IP list: " "${referencedIPs[@]}"

