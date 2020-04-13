FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine AS build
WORKDIR /src
COPY ./src/aspnetcore-docker-logging.csproj ./
RUN dotnet restore ./aspnetcore-docker-logging.csproj
COPY ./src .
RUN dotnet build aspnetcore-docker-logging.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish aspnetcore-docker-logging.csproj -c Release -o /app

FROM base AS final

# good practice to provide medatadata for the image
# see a good schema to follow at http://label-schema.org/
LABEL com.hsingh.name="aspnetcore-docker-logging" \
    com.hsingh.description="ASPNET Core example web application that writes logs into the container's STDOUT/STDERR." \
    com.hsingh.docker.build.cmd="docker build -t aspnetcore-docker-logging -f Dockerfile ." \
    com.hsingh.docker.cmd="docker run --rm -it -p 8000:80 aspnetcore-docker-logging:latest" \
    com.hsingh.docker.params="ASPNETCORE_ENVIRONMENT=Development sets development environment for .NET Core that enables debugging capabilities. ASPNETCORE_DETAILEDERRORS=1 allows to the app to output detailed error messages. DOTNET_RUNNING_IN_CONTAINER=true configures .NET engine for container environment." \
    com.hsingh.docker.debug="docker run --rm -it -e ASPNETCORE_ENVIRONMENT=Development -e ASPNETCORE_DETAILEDERRORS=1 -p 8000:80 aspnetcore-docker-logging:latest"

WORKDIR /app
COPY --from=publish /app .
# Install the agent
RUN apt-get update && apt-get install -y wget ca-certificates gnupg \
&& echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
&& wget https://download.newrelic.com/548C16BF.gpg \
&& apt-key add 548C16BF.gpg \
&& apt-get update \
&& apt-get install -y newrelic-netcore20-agent

# Enable the agent
ENV CORECLR_ENABLE_PROFILING=1 \
CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
CORECLR_NEWRELIC_HOME=/usr/local/newrelic-netcore20-agent \
CORECLR_PROFILER_PATH=/usr/local/newrelic-netcore20-agent/libNewRelicProfiler.so \
NEW_RELIC_APP_NAME=aspnetcore-docker-logging \
NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true 


ENTRYPOINT ["dotnet", "aspnetcore-docker-logging.dll"]