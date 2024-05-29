var serviceName = "bjdazure.otel-demo.hello-service";
var serviceVersion = "1.0.0";
var activitySource = new ActivitySource(serviceName);

var builder = WebApplication.CreateBuilder(args);

using ILoggerFactory factory = LoggerFactory.Create(builder => builder.AddConsole());
ILogger _logger = factory.CreateLogger("Program");
_logger.LogInformation("Starting up");

var appResourceBuilder = ResourceBuilder.CreateDefault()
    .AddService(serviceName: serviceName, serviceVersion: serviceVersion);

var meter = new Meter(serviceName);
var counter = meter.CreateCounter<long>("app.request-counter");

var configurationBuilder = new ConfigurationBuilder();
configurationBuilder.AddEnvironmentVariables(prefix: "DEMO_");
var config = configurationBuilder.Build();

_logger.LogInformation("Found configuration: {config}", config["OTEL_COLLECTOR_ENDPOINT"]);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();

_logger.LogInformation("Adding OpenTelemetry");

var otel = builder.Services.AddOpenTelemetry();

// otel.UseAzureMonitor( o =>  
//     o.ConnectionString = config["APPLICATIONINSIGHTS_CONNECTION_STRING"]
// );

otel.WithTracing(tracerProviderBuilder => tracerProviderBuilder
    .AddSource(activitySource.Name)
    .SetResourceBuilder(appResourceBuilder)
    .AddHttpClientInstrumentation()
    .AddAspNetCoreInstrumentation()
    .AddConsoleExporter()
    .AddOtlpExporter(opt =>
    {
        opt.Protocol = OtlpExportProtocol.Grpc;
        opt.Endpoint = new Uri(config["OTEL_COLLECTOR_ENDPOINT"]);
    })
);

otel.WithMetrics(metricProviderBuilder => metricProviderBuilder
    .SetResourceBuilder(appResourceBuilder)
    .AddAspNetCoreInstrumentation()
    .AddHttpClientInstrumentation()
    .AddMeter(meter.Name)
    .AddMeter("Microsoft.AspNetCore.Hosting")
    .AddMeter("Microsoft.AspNetCore.Server.Kestrel")    
    .AddConsoleExporter()
    .AddOtlpExporter(opt =>
    {
        opt.Protocol = OtlpExportProtocol.Grpc;
        opt.Endpoint = new Uri( config["OTEL_COLLECTOR_ENDPOINT"] );
    })
);

var app = builder.Build();

app.MapGet("/nested", SendNested);
app.MapGet("/hello", () =>
{
    _logger.LogInformation("Request Received");
    using var activity = activitySource.StartActivity("SayHello");
    activity?.SetTag("bar", "Hello, World!");
    counter.Add(1);

    return "Hello, World!";
});

_logger.LogInformation("App Run");
app.Run();


async Task SendNested(int nestlevel, ILogger<Program> logger, HttpContext context, IHttpClientFactory clientFactory)
{
   using var activity = activitySource.StartActivity("SayHelloNested");

    if (nestlevel <= 5)
    {
        logger.LogInformation("Sending Hello, level {nestlevel}", nestlevel);

        counter.Add(1);
        activity?.SetTag("nest-level", nestlevel);

        await context.Response.WriteAsync($"Hello from level: {nestlevel}\r\n");

        if (nestlevel > 0)
        {
            var request = context.Request;
            var url = new Uri($"{request.Scheme}://{request.Host}{request.Path}?nestlevel={nestlevel - 1}");
            var nestedResult = await clientFactory.CreateClient().GetStringAsync(url);
            await context.Response.WriteAsync(nestedResult);
        }
    }
    else
    {
        logger.LogError("Nest level requested {nestlevel} is too high", nestlevel);
        await context.Response.WriteAsync("Nest level too high, max is 5");
    }
}