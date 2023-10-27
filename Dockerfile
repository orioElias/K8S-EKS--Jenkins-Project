# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

# Restore and publish the app
COPY MySimpleWebApp/. .
RUN dotnet restore
RUN dotnet publish -c release -o /app

# Use the runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "MySimpleWebApp.dll"]
