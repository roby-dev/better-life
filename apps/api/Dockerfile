# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY global.json ./
COPY src/BetterLife.Domain/BetterLife.Domain.csproj src/BetterLife.Domain/
COPY src/BetterLife.Application/BetterLife.Application.csproj src/BetterLife.Application/
COPY src/BetterLife.Infrastructure/BetterLife.Infrastructure.csproj src/BetterLife.Infrastructure/
COPY src/BetterLife.Api/BetterLife.Api.csproj src/BetterLife.Api/
RUN dotnet restore src/BetterLife.Api/BetterLife.Api.csproj
COPY src/ src/
RUN dotnet publish src/BetterLife.Api/BetterLife.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENTRYPOINT ["dotnet", "BetterLife.Api.dll"]
