echo && echo "> Pulling latest mssql image..."
docker pull mcr.microsoft.com/mssql/server:2017-latest

echo && echo "> Resetting data folder..."
mkdir -p data

echo && echo "> Remove old mssql container..."
docker rm -f izonesql

echo && echo "> Create new mssql container..."
docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=<YourStrong!Passw0rd>' --name 'izonesql' -p 1401:1433 -v `pwd`:/var/opt/mssql/backup -v `pwd`"/data":/var/opt/mssql -d mcr.microsoft.com/mssql/server:2017-latest

echo && echo "Waiting a moment to let mssql get ready..."
sleep 10

echo && echo "> Restoring izone database..."
BACKUP_STATEMENT='RESTORE DATABASE izone FROM DISK = "/var/opt/mssql/backup/izone.bak"'
BACKUP_STATEMENT+="WITH NORECOVERY"
BACKUP_STATEMENT+=",MOVE 'izone_dat' TO '/var/opt/mssql/data/izone.mdf'"
BACKUP_STATEMENT+=",MOVE 'izone_log' TO '/var/opt/mssql/data/izone.ldf'"
docker exec -it izonesql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong!Passw0rd>' -Q "$BACKUP_STATEMENT"

echo && echo "> Done!"
echo && echo "> The files inside data/ are probably owned by root btw. Enjoy =^_^="
