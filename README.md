ARD_Tools
=========

Shell Scripts for Apple Remote Desktop maintenance.

ARD_DB_Cleaner.sh: 
	Clean up plist file which is exported from Remote Desktop.app. Remove hostname entries.

ARD_DB_namelist.sh: 
	List up computer name only. use for checking duplicate computer names.

ARD_DB_make_importfile.sh: 
	Create import plist file. The source file is expected as csv file. The 1st column is name of computer. 2nd is MAC address.
