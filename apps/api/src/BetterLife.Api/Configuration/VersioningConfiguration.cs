using Asp.Versioning;
using Microsoft.Extensions.DependencyInjection;

namespace BetterLife.Api.Configuration;

public static class VersioningConfiguration
{
    public static IServiceCollection AddApiVersioningConfigured(this IServiceCollection services)
    {
        services
            .AddApiVersioning(o =>
            {
                o.DefaultApiVersion = new ApiVersion(1, 0);
                o.AssumeDefaultVersionWhenUnspecified = true;
                o.ReportApiVersions = true;
            })
            .AddApiExplorer(o =>
            {
                o.GroupNameFormat = "'v'VVV";
                o.SubstituteApiVersionInUrl = true;
            });
        return services;
    }
}
