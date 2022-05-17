FROM alpine:3.15

ADD logDeployment.ps1 /logDeployment.ps1

ENTRYPOINT [ "logDeployment.ps1" ]