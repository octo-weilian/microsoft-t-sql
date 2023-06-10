FROM mcr.microsoft.com/mssql/server:2022-latest

ARG PASSWORD

ENV ACCEPT_EULA=Y

ENV MSSQL_SA_PASSWORD=${PASSWORD}
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433

WORKDIR /var/opt/mssql/backup

USER root
RUN apt-get update && apt-get install -y curl
RUN curl -LO https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2022.bak 
    
