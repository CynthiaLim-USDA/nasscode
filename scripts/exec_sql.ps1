#
# Usage:
#      exec_sql.ps1 [<servers>|<server_file>] <db> <sql_file>
#      exec_sql.ps1 [<servers>|<server_file>] <db> <cmdline_query>
#
#       .\exec_sql.ps1 servers.txt "" check_maint.sql
#       .\exec_sql.ps1 "AASDCWLU3SQDBB,AASMOSLU3SQDBB" "" check_maint.sql
#      .\exec_sql.ps1 "AASDCWLU3SQDBB,AASMOSLU3SQDBB" "nedsTransBeta" "select substring(@@servername,1,15), count(*) from data_comments" 
#

$script_dir = "D:\proj\test"
$db = "master"

$server_input = $args[0]
if ($args[1]){ $db = $args[1]}
$sqlfile = $args[2]

# Process a server file or a list of servers into $servers array

if (Test-Path $script_dir\$server_input -PathType leaf) {
     $servers = Get-Content $script_dir\$server_input
} else {
     $servers = $server_input.split(",")
}

# Remove training blanks for each line in the output of executing sql statements
# Add "-h -1" to sqlcmd to surpress output heades for sql statements, not for sql file

foreach ($server in $servers) {
    if (Test-Path $script_dir\$sqlfile -PathType leaf) {
       sqlcmd -S $server -d $db -i $sqlfile | Foreach {$_.TrimEnd()}
    } else {
       sqlcmd -S $server -d $db -h -1 -Q "
set nocount on
$sqlfile
go
print ' '
go
" | Foreach {$_.TrimEnd()}
    }
}
