(* =====================================
      Export all computer lists
    ====================================== *)

tell application "Remote Desktop"
	set theListNames to name of every computer list
	
	set EXPORT_DIR to do shell script "echo \"$HOME/Documents/ComputerListBackups/`date +%Y%m%d-%H%M%S`\"  "
	do shell script " if [ ! -d \"" & EXPORT_DIR & "\" ]; then mkdir -p \"" & EXPORT_DIR & "\" ; fi"

	repeat with theName in theListNames
		set UUID_of_LIST to id of computer list theName
		set EXPORT_PLIST to EXPORT_DIR & "/" & theName & ".plist"
		
		do shell script "/usr/libexec/PlistBuddy  -c \"add uuid string \"" & UUID_of_LIST & "\"\" \"" & EXPORT_PLIST & "\" 2> /dev/null"
		do shell script "/usr/libexec/PlistBuddy  -c \"add listName string \\\"" & theName & "\\\"\" \"" & EXPORT_PLIST & "\""
		do shell script "/usr/libexec/PlistBuddy  -c \"add items array \"  \"" & EXPORT_PLIST & "\""
		
		set itemNum to 0
		set theComputers to name of every computer in computer list theName
		repeat with theHostName in theComputers
			set theHWADDR to primary Ethernet address of computer theHostName
			set theNetworkAddress to Internet address of computer theHostName
			
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & " dict\" \"" & EXPORT_PLIST & "\""
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & ":name string \\\"" & theHostName & "\\\"\" \"" & EXPORT_PLIST & "\""
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & ":hardwareAddress string " & theHWADDR & "\" \"" & EXPORT_PLIST & "\""
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & ":networkAddress string " & theNetworkAddress & "\" \"" & EXPORT_PLIST & "\""
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & ":networkPort string 3283\" \"" & EXPORT_PLIST & "\""
			do shell script "/usr/libexec/PlistBuddy  -c \"add items:" & itemNum & ":vncPort string 5900\" \"" & EXPORT_PLIST & "\""
			
			set itemNum to itemNum + 1
		end repeat
	end repeat
end tell
