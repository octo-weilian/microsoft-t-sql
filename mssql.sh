#!/bin/bash

#build dockerfile and run docker container named mssql in detached mode
#choose a strong password e.g. Str0ngpassword!

echo "Please enter a MSSQL password: "
read -s PASSWORD

docker container rm -f mssql
docker image rm -f mssql-image:dev 
docker build -t mssql-image:dev --no-cache --build-arg PASSWORD=$PASSWORD . 
docker compose up -d

#wait for the container to start up
sleep 10

#unpack data and log files from backup file
docker exec -it mssql /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P $PASSWORD \
   -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/AdventureWorksLT2022.bak'" \
   | tr -s ' ' | cut -d ' ' -f 1-2

#restore database based on the data and log files
docker exec -it mssql /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U sa -P $PASSWORD \
   -Q "RESTORE DATABASE AdventureWorksLT2022 FROM DISK = '/var/opt/mssql/backup/AdventureWorksLT2022.bak'\
   WITH MOVE 'AdventureWorksLT2022_Data' TO '/var/opt/mssql/data/AdventureWorksLT2022_Data.mdf',\
   MOVE 'AdventureWorksLT2022_Log' TO '/var/opt/mssql/data/AdventureWorksLT2022_Log.ldf'"

RED="\e[31m"
ENDCOLOR="\e[0m"

echo 'MSSQL connection string:'
IP_ADDRESS=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

CONN_STRING="Server=${IP_ADDRESS},1433;Database=AdventureWorksLT2022;User=sa;Password=<password>"
echo -e "${RED}${CONN_STRING}${ENDCOLOR}"
