using System.Text;
using BetterLife.Api.Configuration;
using BetterLife.Api.Middleware;
using BetterLife.Application;
using BetterLife.Infrastructure;
using BetterLife.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog((ctx, cfg) =>
        cfg.ReadFrom.Configuration(ctx.Configuration).Enrich.FromLogContext());

    builder.Services.AddControllers();
    builder.Services.AddApiVersioningConfigured();
    builder.Services.AddSwaggerConfigured();

    var jwtSection = builder.Configuration.GetSection("Jwt");
    string jwtSecret = builder.Configuration["Jwt:Secret"]
        ?? throw new InvalidOperationException(
            "Jwt:Secret is missing. Set the JWT__SECRET environment variable.");

    if (jwtSecret.Length < 32)
        throw new InvalidOperationException(
            "Jwt:Secret must be at least 32 characters. Set a longer JWT__SECRET environment variable.");

    builder.Services
        .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(opt =>
        {
            opt.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSection["Issuer"] ?? "betterlife-api",
                ValidAudience = jwtSection["Audience"] ?? "betterlife-mobile",
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret))
            };
        });

    builder.Services.AddAuthorization();
    builder.Services.AddApplication();
    builder.Services.AddInfrastructure(builder.Configuration);

    var app = builder.Build();

    if (app.Environment.IsDevelopment())
    {
        using var scope = app.Services.CreateScope();
        await scope.ServiceProvider
            .GetRequiredService<AppDbContext>()
            .Database.MigrateAsync();
    }

    app.UseSerilogRequestLogging();
    app.UseMiddleware<ExceptionHandlingMiddleware>();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();

    await app.RunAsync();
}
catch (Exception ex) when (ex is not HostAbortedException)
{
    Log.Fatal(ex, "Application startup failed.");
}
finally
{
    Log.CloseAndFlush();
}
