FROM mcr.microsoft.com/powershell

WORKDIR /src

COPY ivmsapi.ps1 /src/
COPY Modules /src/Modules/

RUN apt-get update
RUN apt-get -y install iputils-ping net-tools telnet iproute2 dnsutils vim

EXPOSE 8082

CMD ["pwsh","./ivmsapi.ps1"]