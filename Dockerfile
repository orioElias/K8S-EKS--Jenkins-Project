# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS build

# Restore and publish the app
WORKDIR /source
COPY MySimpleWebApp/. .
RUN dotnet restore
RUN dotnet publish -c release -o /app

# Use the runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "MySimpleWebApp.dll"]
