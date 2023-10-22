# The below script was used to build the SQL project locally on the runner.

# Test connection on runner with SQL:
# value can be found under vnet > private endpoints > (your endpoint) > dns configuration > custom DNS records FQDN
# Test-NetConnection -computer <private DNS>.database.windows.net -port 1433

## CHECKOUT
$root = "" # replace with root path on runner
cd $root
$devPath = "_Dev"
$repo = "azure-sql-mi-devops"
$sqlProjectName = "DemoSqlProj"

cd ./$devPath
$pat = ""
git clone "https://$pat@github.com/ryanpfalz/$repo.git"
cd "$repo"
# git checkout "dev"
ls .

## BUILD
cd "$root\$devPath\$repo"
dotnet build "data\$($sqlProjectName)\$($sqlProjectName).sqlproj" --configuration Release

## RELEASE
$buildPath = "$root\$devPath\$repo\data\$sqlProjectName\bin\Release"
$serverName = ""
$databaseName = ""
$userName = ""
$pass = ""
sqlpackage /Action:Publish /SourceFile:"$buildPath\$sqlProjectName.dacpac" /TargetConnectionString:"Server=tcp:$serverName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$userName;Password=$pass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"