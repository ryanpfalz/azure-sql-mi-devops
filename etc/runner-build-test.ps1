# The below script can be used to build the SQL project locally on the runner for debugging.

## CHECKOUT
$root = "" # replace with root path on runner
cd $root
$devPath = "_Dev"
$repo = "azure-sql-mi-devops"
$sqlProjectName = "DemoSqlProj"

cd ./$devPath
$pat = "" # GitHub Personal Access Token
git clone "https://$pat@github.com/ryanpfalz/$repo.git"
cd "$repo"
# git checkout "dev"
ls .

## BUILD
cd "$root\$devPath\$repo"
dotnet build "data\$($sqlProjectName)\$($sqlProjectName).sqlproj" --configuration Release

## RELEASE
$buildPath = "$root\$devPath\$repo\data\$sqlProjectName\bin\Release"
$databaseName = ""
$userName = ""
$pass = ""

# FQDN of SQL MI can be found in the Azure portal under SQL managed instance > Overview > Host
$fqdn = ""

# Test connection on runner with SQL:
Test-NetConnection -computer $fqdn -port 1433

sqlpackage /Action:Publish /SourceFile:"$buildPath\$sqlProjectName.dacpac" /TargetUser:$userName /TargetPassword:$pass /TargetServerName:$fqdn /TargetDatabaseName:$databaseName
