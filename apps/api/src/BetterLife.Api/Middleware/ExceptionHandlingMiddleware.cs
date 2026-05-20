using System.Text.Json;
using BetterLife.Application.Common.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using AppValidationException = BetterLife.Application.Common.Exceptions.ValidationException;

namespace BetterLife.Api.Middleware;

public sealed class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionHandlingMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext ctx)
    {
        try
        {
            await _next(ctx);
        }
        catch (AppValidationException ex)
        {
            ctx.Response.StatusCode = StatusCodes.Status400BadRequest;
            ctx.Response.ContentType = "application/problem+json";

            var details = new ValidationProblemDetails(
                ex.Errors.ToDictionary(kvp => kvp.Key, kvp => kvp.Value))
            {
                Status = StatusCodes.Status400BadRequest,
                Title = "Validation failed.",
                Type = "https://tools.ietf.org/html/rfc9110#section-15.5.1"
            };

            await ctx.Response.WriteAsync(JsonSerializer.Serialize(details));
        }
        catch (ConflictException ex)
        {
            ctx.Response.StatusCode = StatusCodes.Status409Conflict;
            ctx.Response.ContentType = "application/problem+json";

            var details = new ProblemDetails
            {
                Status = StatusCodes.Status409Conflict,
                Title = ex.Message,
                Type = $"https://betterlife.app/errors/{ex.ErrorType}"
            };

            await ctx.Response.WriteAsync(JsonSerializer.Serialize(details));
        }
        catch (AuthenticationException ex)
        {
            ctx.Response.StatusCode = StatusCodes.Status401Unauthorized;
            ctx.Response.ContentType = "application/problem+json";

            var details = new ProblemDetails
            {
                Status = StatusCodes.Status401Unauthorized,
                Title = ex.Message,
                Type = $"https://betterlife.app/errors/{ex.ErrorType}"
            };

            await ctx.Response.WriteAsync(JsonSerializer.Serialize(details));
        }
        catch (NotFoundException ex)
        {
            ctx.Response.StatusCode = StatusCodes.Status404NotFound;
            ctx.Response.ContentType = "application/problem+json";

            var details = new ProblemDetails
            {
                Status = StatusCodes.Status404NotFound,
                Title = ex.Message,
                Type = $"https://betterlife.app/errors/{ex.ErrorType}"
            };

            await ctx.Response.WriteAsync(JsonSerializer.Serialize(details));
        }
        catch (Exception ex)
        {
            Log.Error(ex, "Unhandled exception processing request {Method} {Path}",
                ctx.Request.Method, ctx.Request.Path);

            ctx.Response.StatusCode = StatusCodes.Status500InternalServerError;
            ctx.Response.ContentType = "application/problem+json";

            var details = new ProblemDetails
            {
                Status = StatusCodes.Status500InternalServerError,
                Title = "Internal Server Error.",
                Type = "https://tools.ietf.org/html/rfc9110#section-15.6.1"
            };

            await ctx.Response.WriteAsync(JsonSerializer.Serialize(details));
        }
    }
}
