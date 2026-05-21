using BetterLife.Application.Common.Abstractions;
using BetterLife.Infrastructure.Auth;
using BetterLife.Infrastructure.Common;
using BetterLife.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BetterLife.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration cfg)
    {
        var conn = cfg.GetConnectionString("Default")
            ?? throw new InvalidOperationException("ConnectionStrings:Default missing.");

        services.AddDbContext<AppDbContext>(o => o.UseSqlServer(conn));
        services.AddScoped<IAppDbContext>(sp => sp.GetRequiredService<AppDbContext>());

        services.Configure<JwtOptions>(cfg.GetSection("Jwt"));
        services.PostConfigure<JwtOptions>(opts =>
        {
            if (string.IsNullOrWhiteSpace(opts.Secret) || opts.Secret.Length < 32)
                throw new InvalidOperationException(
                    "Jwt:Secret must be at least 32 characters. Set JWT_SECRET environment variable in Production.");
        });

        services.AddSingleton<IClock, SystemClock>();
        services.AddSingleton<IGuidGenerator, GuidV7Generator>();
        services.AddSingleton<IPasswordHasher, BCryptPasswordHasher>();
        services.AddSingleton<IDefaultCategoryProvider, DefaultCategoryProvider>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();

        return services;
    }
}
