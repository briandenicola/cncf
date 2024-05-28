var serviceName = "bjdazure.otel-demo.hello-service";
var serviceVersion = "1.0.0";
var activitySource = new ActivitySource(serviceName);

var builder = WebApplication.CreateBuilder(args);

using ILoggerFactory factory = LoggerFactory.Create(builder => builder.AddConsole());
ILogger _logger = factory.CreateLogger("Program");
_logger.LogInformation("Starting up");

var appResourceBuilder = ResourceBuilder.CreateDefault()
    .AddService(serviceName: serviceName, serviceVersion: serviceVersion);

var configurationBuilder = new ConfigurationBuilder();
configurationBuilder.AddEnvironmentVariables(prefix: "DEMO_");
var config = configurationBuilder.Build();

_logger.LogInformation("Found configuration: {config}", config["OTEL_COLLECTOR_ENDPOINT"]);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

_logger.LogInformation("Adding OpenTelemetry");

var otel = builder.Services.AddOpenTelemetry();

otel.UseAzureMonitor( o => {  
    o.ConnectionString = builder.Configuration["APP_INSIGHTS_CONNECTION_STRING"];
    o.SamplingRatio = 0.1F; 
});

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

var meter = new Meter(serviceName);
var counter = meter.CreateCounter<long>("app.request-counter");
otel.WithMetrics(metricProviderBuilder => metricProviderBuilder
    .SetResourceBuilder(appResourceBuilder)
    .AddAspNetCoreInstrumentation()
    .AddHttpClientInstrumentation()
    .AddMeter(meter.Name)
    .AddConsoleExporter()
    .AddOtlpExporter(opt =>
    {
        opt.Protocol = OtlpExportProtocol.Grpc;
        opt.Endpoint = new Uri( config["OTEL_COLLECTOR_ENDPOINT"] );
    })
);

var app = builder.Build();

app.MapGet("/hello", () =>
{
    using var activity = activitySource.StartActivity("SayHello");
    activity?.SetTag("bar", "Hello, World!");
    counter.Add(1);

    return "Hello, World!";
});

_logger.LogInformation("App Run");
app.Run();
