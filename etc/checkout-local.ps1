$devPath = "_Dev"
$repo = "azure-sql-mi-devops"

mkdir $devPath
cd ./$devPath
$pat = ""
git clone "https://$pat@github.com/ryanpfalz/$repo.git"
cd "$repo"
git checkout "dev"
ls .