$repo = "azure-sql-mi-devops"
cd "C:\Users\selfhostedadmin\_Dev\$repo"

$SQL_PROJECT_NAME = "DemoSqlProj"
dotnet build "data/$($SQL_PROJECT_NAME)/$($SQL_PROJECT_NAME).sqlproj" --configuration Release

cd C:\Users\selfhostedadmin\_Dev
rm -r "C:\Users\selfhostedadmin\actions-runner\_work\$repo" 

##

$serverName = ""
$databaseName = ""
$userName = ""
$pass = ""
sqlpackage /Action:Publish /SourceFile:"./$SQL_PROJECT_NAME.dacpac" /TargetConnectionString:"Server=tcp:$serverName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$userName;Password=$pass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"