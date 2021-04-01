#
# run_ddlgen.ps1
#
# Usage:
#	run_ddlgen.ps1 [<servers>|<server_file>]
#       .\run_ddlgen.ps1 "AASDCWLU3SQDBB,AASMOSLU3SQDBB"
#       .\run_ddlgen.ps1 .\servers.txt
#


#$script_dir = "\\lockup\RecapDBa$\ddlgen\Scripts"

$script_dir = "C:\Users\lim_cy\Desktop\Scripts";

# Process a server file or a list of servers into $servers array

$server_input = $args[0]
if ($args[1]){ $db = $args[1] }

if (Test-Path $server_input -PathType leaf) {
     $servers = Get-Content $server_input
} else {
     $servers = $server_input.split(",")
}

foreach ($server in $servers) {
	$server
	& $script_dir\ddlgen.ps1 $server
}
