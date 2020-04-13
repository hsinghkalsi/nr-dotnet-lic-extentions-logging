# nr-dotnet-lic-extentions-logging
Example to show how to enable Logs in context using Serilog as logging provider for Microsoft.Extentions.Logging for more details read https://github.com/serilog/serilog-aspnetcore#inline-initialization


Logging configuration is controlled via appconfig.json in application . In this case the output is console / Container/ Kubernetes logs. The logs are injested using our infra agen kubernetes logging plugin

* Prerequisite
    1. Kubernetes integration
    2. Kubernetes logging plugin https://github.com/newrelic/kubernetes-logging

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

    **Deployment**
    * Run the app as a Kubernetes deployment/service  (assuming you have local kube instance running):
    >kubectl create -f deployment.yml 
    * Running the follwoign should give you url to access the app 
     > minikube service list
    ```
        |----------------------|---------------------------|----------------------------|-----|
        |      NAMESPACE       |           NAME            |        TARGET PORT         | URL |
        |----------------------|---------------------------|----------------------------|-----|
        | default              | aspnetcore-logging-svc    | http://192.168.64.38:32160 |
        | default              | kubernetes                | No node port               |
        | kube-system          | kube-dns                  | No node port               |
        | kube-system          | kube-state-metrics        | No node port               |
        | kubernetes-dashboard | dashboard-metrics-scraper | No node port               |
        | kubernetes-dashboard | kubernetes-dashboard      | No node port               |
        |----------------------|---------------------------|----------------------------|-----|
    ```
    * Access few URLs to generate traffic 
    * Check logs in Log UI/Insights 
    
*References 

https://docs.newrelic.com/docs/logs/enable-logs/enable-logs/kubernetes-plugin-logs#kubernetes-plugin
https://github.com/newrelic/kubernetes-logging

