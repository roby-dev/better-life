using System.Reflection;
using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using BetterLife.Application.Common.Behaviors;

namespace BetterLife.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection s)
    {
        var asm = Assembly.GetExecutingAssembly();
        s.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(asm));
        s.AddValidatorsFromAssembly(asm);
        s.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        return s;
    }
}
