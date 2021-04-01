#
# ddlgen.ps1
#
# Usage:
#	ddlgen.ps1 <server_name> [ <retention> ]
#	ddlgen.ps1 localhost
#	ddlgen.ps1 AASMOSLU3DBT1 30
#
# The default retention is 90 days
#

   $server = $args[0]
   $retention = $args[1]
   if ( ! $retention ) { $retention = 90 }

   $timestamp = $(get-date -f yyyyMMdd_hhmm)
   $dateOlderThan = (Get-Date).AddDays(-$retention)
   $ddlgen_dir = "\\lockup\RecapDBa$\ddlgen\$server"

   "The ddlgen direcotry for "+$server+": "+   $ddlgen_dir
   #" date older than [" + $dateOlderThan + "]"

#
# Run a query to retrieve a list of online user databases in the server
# Will surpress the header (-h) and the row count information
#
   $databases = sqlcmd -S $server -h-1 -Q "
     select name from sys.databases d
        left outer join sys.availability_databases_cluster agdc
          on agdc.database_name = d.name 
       where name not in ('master','msdb','tempdb','model','distribution') 
         and name not like '%Old'
         and state = 0
         and ( sys.fn_hadr_is_primary_replica(name) = 1 or 
               sys.fn_hadr_is_primary_replica(name) is null )
GO
"

#
# Extract ddl for each user database
# Create a ddlgen output file with timestamp, then copy it to the file with no timestamp
#
   foreach ($db in $databases) {
     $cur_db = $db.TrimEnd()
     $file_prefix="$ddlgen_dir\$server"+"_$cur_db"+"_ddl"
     $ddl_file = "$file_prefix"+"_$timestamp.txt"
     $err_file = "$file_prefix"+".err"
     $fixed_file = "$file_prefix"+".txt"

     $cur_db
     $ddl_file
     $err_file
     $fixed_file

     mssql-scripter -S $server -d $db -f $ddl_file > $err_file
     Copy-Item $ddl_file $fixed_file -Force
   }

#
# Delete older files based on retention period
#
   Get-ChildItem $ddlgen_dir\*.txt | Where-Object { $_.LastWriteTime -lt $dateOlderThan }| Remove-Item -Force
