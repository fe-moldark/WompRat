import os, sys, time
from datetime import datetime
import argparse
import re

# This will be used to pull reports of a specific MAC address over a given time period
# Accepts flags -mac -start -end
# If no -start or -end are specified defaults to all time search


parser = argparse.ArgumentParser(description="Flags for MAC search script.")

parser.add_argument("-mac", required=True, help="Required argument for MAC address")
parser.add_argument("-start", help="Optional start date, formatted as YYYY-MM-DD")
parser.add_argument("-end", help="Optional end date. If no end date is specified but start is, will use current date as end")

args = parser.parse_args()


base_log_dir="/home/skywalker/WompRat/Logs/"

mac=str(args.mac)
print(' + Target MAC:',mac)


if args.end and not args.start:
    print(" If you wish to designate an end date, there must be a start date")
    sys.exit()

# I trusted chatgpt for this pattern check...
def check_date_format(date_string: str) -> bool:
    date_pattern = r"^\d{4}-\d{2}-\d{2}$"

    if re.match(date_pattern, date_string):
        return True
    return False

# Run some initial checks
if args.start:
    if not check_date_format(str(args.start)):
        print(" ! Invalid date format for the start date. Use YYYY-MM-DD")
        sys.exit()
if args.end:
    if not check_date_format(str(args.end)):
        print(" ! Invalid date format for the end date. Use YYYY-MM-DD")
        sys.exit()
    
    if args.start:
        # Check if end date is before the start date
        start_date = datetime.strptime(str(args.start), '%Y-%m-%d')
        end_date = datetime.strptime(str(args.end), '%Y-%m-%d')
    
        # Invalid
        if not end_date >= start_date:
            print(" ! End date is before the start date")
            sys.exit()
            

if not os.path.exists(base_log_dir+'/'+str(args.start)) and args.start: # Start date was chosen but is invalid (i.e. no logs from then)
    print(" Start date does not exist. Reference below list for available options, then try again.")
    print(os.listdir(base_log_dir))
    sys.exit()


today=datetime.today().strftime('%Y-%m-%d')

# Check specific period
if args.start:
    
    start_date=datetime.strptime(str(args.start), '%Y-%m-%d')

    if args.end:
        end_date = datetime.strptime(str(args.end), '%Y-%m-%d')
    else:
        end_date = datetime.strptime(str(today), '%Y-%m-%d')

    valid_folders = []

    for folder_name in os.listdir(base_log_dir):
        # Check if the folder name matches the YYYY-MM-DD format (probably no longer needed)
        try:
            folder_date = datetime.strptime(folder_name, '%Y-%m-%d')
            
            # Check if the folder's date is within the range
            if start_date <= folder_date <= end_date:
                valid_folders.append(folder_name)
        except ValueError:
            # Skip folders that don't match the YYYY-MM-DD format
            continue

# Checking all time Logs    
else:
    valid_folders=os.listdir(base_log_dir)
    start_date='All time'
    end_date='All time'


print('\n + Searching Logs from '+str(start_date)+' through '+str(end_date)+'.')
print(' + Logs from '+str(len(valid_folders))+' total days were found.')


def searchLogFile(locatedMAClist,subDir,base_log_dir=base_log_dir):
    for cronScanTime in  os.listdir(base_log_dir+'/'+subDir):
        try:
            openFile=open(base_log_dir+'/'+subDir+'/'+cronScanTime+'/log.csv','r')
            lines=openFile.read().split('\n')
            openFile.close()

            for line in lines:
                split=line.split(',')
            if str(split[0])==mac:
                locatedMAClist.append([str(base_log_dir+'/'+subDir),cronScanTime])

        except:
            print(" ! Ran into some error opening '"+base_log_dir+'/'+subDir+'/'+cronScanTime+'/log.csv'+"', skipping.")

    return locatedMAClist


locatedMAClist=[]
for valid_folder in valid_folders:
    locatedForDate=[]
    for cronScanTime in os.listdir(base_log_dir+'/'+valid_folder):
        try:
            openFile=open(base_log_dir+'/'+valid_folder+'/'+cronScanTime+'/log.csv','r')
            lines=openFile.read().split('\n')
            openFile.close()

            for line in lines:
                split=line.split(',')
                if str(split[0]).lower()==str(mac):
                    locatedForDate.append(cronScanTime)

        except:
            # Realistically, this only happens when the log file is empty for some reason
            pass

    if len(locatedForDate)>=0:
        locatedMAClist.append([valid_folder,locatedForDate])


print('\n + MAC was detected in the following scan logs:')
for item in locatedMAClist:
    print('\n  ~',item[0],'~\n')
    for logFile in item[1]:
        print('   ',str(logFile))




