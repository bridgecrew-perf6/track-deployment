FROM ubuntu 
ENV builddir=build
RUN mkdir \${builddir}
RUN apt-get update
RUN apt-get install -y wget apt-transport-https software-properties-common
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell
RUN ["pwsh", "-command" ,"$psversiontable"]

ADD logDeployment.ps1 /logDeployment.ps1

ENTRYPOINT [ "logDeployment.ps1" ]