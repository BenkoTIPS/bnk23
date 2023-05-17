FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 433

ENV ASPNETCORE_URLS=http://+:80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["code/imaWeb/imaWeb.csproj", "code/imaWeb/"]
RUN dotnet restore "code/imaWeb/imaWeb.csproj"
COPY . .
WORKDIR "/src/code/imaWeb"
RUN dotnet build "imaWeb.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "imaWeb.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "imaWeb.dll"]
