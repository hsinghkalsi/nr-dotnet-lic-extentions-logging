using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Events;
using NewRelic.LogEnrichers.Serilog;


namespace aspnetcore_docker_logging
{
    public class Program
    {
        public static void Main(string[] args)
        {
            /*Log.Logger = new LoggerConfiguration()
            .MinimumLevel.Debug()
            .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
            .Enrich.FromLogContext()
            .Enrich.WithNewRelicLogsInContext()
            .WriteTo.Console(new NewRelicFormatter())
            .CreateLogger();

            try
            {
                Log.Information("Starting web host");
                */
                CreateHostBuilder(args).Build().Run();
            /*}
            catch (Exception ex)
            {
                Log.Fatal(ex, "Host terminated unexpectedly");
            }
            finally
            {
                Log.CloseAndFlush();
            }*/
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                }).UseSerilog((hostingContext, loggerConfiguration) => loggerConfiguration
                    .ReadFrom.Configuration(hostingContext.Configuration)
                    .Enrich.FromLogContext());   //<--- https://github.com/serilog/serilog-aspnetcore#inline-initialization
                //.UseSerilog(); // <-- Add this line 
    }
}
