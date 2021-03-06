FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic

## start installing sqlcmd
ARG MSSQLTOOLS_VERSION=17.4.1.1-1
ENV PATH=/opt/mssql-tools/bin:$PATH

RUN apt-get update \
    && apt-get install -y curl apt-transport-https locales gnupg2 \
    && locale-gen "en_US.UTF-8" \
    && export `grep "VERSION_ID" /etc/os-release | sed -e 's/^VERSION_ID=\"/VERSION_ID=/' -e 's/\"$//'` \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/$VERSION_ID/prod.list | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools=$MSSQLTOOLS_VERSION unixodbc-dev \
    && apt-get remove -y curl apt-transport-https \
    && rm -f /etc/apt/sources.list.d/msprod.list \
    && rm -rf /var/lib/apt/lists/*

## should be set after locale was generated, overwise triggers warnings
ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"
## end installing sqlcmd

ADD netcoreapp/ /app/
WORKDIR /app
EXPOSE 80
ENV ASPNETCORE_ENVIRONMENT=Development
#ENV NCIIC__License="N/A"
CMD /bin/bash -c "dotnet ASPNETCoreTest.dll"
