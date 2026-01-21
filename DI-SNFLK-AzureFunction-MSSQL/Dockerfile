# Use the image tag that ends with appservice to enable ssh & remote debugging
FROM mcr.microsoft.com/azure-functions/python:4-python3.11-appservice

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY . /home/site/wwwroot

# KRB CONFIG
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN apt-get update \
&& ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
krb5-user \
cron

COPY /kerberos /kerberos
RUN chmod +x /kerberos/start.sh /kerberos/login.sh

ENTRYPOINT ["/kerberos/start.sh"]