FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 81

RUN apt-get update && apt-get install -y \
    libkrb5-3 \
    libgssapi-krb5-2
    
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ClassroomManagerAPI/ClassroomManagerAPI.csproj", "ClassroomManagerAPI/"]
RUN dotnet restore "ClassroomManagerAPI/ClassroomManagerAPI.csproj"
COPY . .
WORKDIR "/src/ClassroomManagerAPI"
RUN dotnet build "ClassroomManagerAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ClassroomManagerAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_ENVIRONMENT=Production
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ClassroomManagerAPI.dll"]