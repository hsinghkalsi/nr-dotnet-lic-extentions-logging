# nr-dotnet-lic-extentions-logging
Example to show how to enable Logs in context using Serilog as logging provider for Microsoft.Extentions.Logging for more details read https://github.com/serilog/serilog-aspnetcore#inline-initialization


Logging configuration is controlled via appconfig.json in application . In this case the output is console / Container/ Kubernetes logs. The logs are injested using our infra agen kubernetes logging plugin

##### Prerequisites
    1. Kubernetes integration
    2. Kubernetes logging plugin https://github.com/newrelic/kubernetes-logging
    3. Sample aspnetcore application.

#### Code changes required to app

The code changes introduce serilog log provider and corresponding new relic enricher to format and enrich the microsoft extentions logs to be injested by new relic. Here is summary of code chnages required. 
There are multiple ways to enable this integration, we have tired to create one that requires minimal code changes as suggested in https://github.com/serilog/serilog-aspnetcore#inline-initialization

1. Nuget imports
    The .csproj file is updated with references to required nugets 
    ```
    <PackageReference Include="NewRelic.LogEnrichers.Serilog" Version="1.0.0" />
    <PackageReference Include="NewRelic.Agent.Api" Version="8.21.34" />
    <PackageReference Include="Serilog.AspNetCore" Version="3.2.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="3.1.3" />
    <PackageReference Include="Serilog.Settings.Configuration" Version="3.1.0" />
    ```
2.  Program.cs inside the function CreateHostBuilder 
    Add .UseSerilog() as shown below to the ***CreateDefaultBuilder*** function

    <pre><code>
    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            })<b>.UseSerilog((hostingContext, loggerConfiguration) => loggerConfiguration
                .ReadFrom.Configuration(hostingContext.Configuration)
                .Enrich.FromLogContext());</b>
    </code></pre>
3. 



##### Deployment
*Skip to Step 4 is you want to just test deployment and not recreate image with custom settings

1.  ***Local run*** 
    Verify your app is showing the newrelic formatted output.
    >dotnet run --project src/aspnetcore-docker-logging.csproj 

2.  ***Build docker image*** 

    >docker build -t aspnetcore-docker-logging .

3.  ***Run docker image locally*** 
    
    >docker run --rm -it -e ASPNETCORE_ENVIRONMENT=Development -e ASPNETCORE_DETAILEDERRORS=1 -e NEW_RELIC_LICENSE_KEY=<<YOUR NR KEY>>  -p 8000:80 aspnetcore-docker-logging:latest 

4.   ***Kubernetes Run***
    Kuberenetes logging plugin. Follow instructions here  https://github.com/newrelic/kubernetes-logging
     ***Deployment***
     * Run the app as a Kubernetes deployment/service  (assuming you have local kube instance running)
        >kubectl create -f deployment.yml 
     
     * Running the following should give you url to access the app.
        >minikube service list
     * Access few URLs to generate traffic 
     * Check logs in Log UI/Insights 



***References***

https://docs.newrelic.com/docs/logs/enable-logs/enable-logs/kubernetes-plugin-logs#kubernetes-plugin
https://github.com/newrelic/kubernetes-logging 
https://github.com/newrelic/kubernetes-logginghttps://github.com/serilog/serilog-aspnetcore#inline-initialization
