using FluentValidation;

namespace BetterLife.Application.Auth.Register;

public sealed class RegisterUserCommandValidator : AbstractValidator<RegisterUserCommand>
{
    public RegisterUserCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(256);
        RuleFor(x => x.Password).NotEmpty().Length(8, 128);
        RuleFor(x => x.TimeZone).NotEmpty().Must(BeValidIanaTimeZone)
            .WithMessage("Zona horaria inválida.");
    }

    private static bool BeValidIanaTimeZone(string tz)
    {
        try { TimeZoneInfo.FindSystemTimeZoneById(tz); return true; }
        catch { return false; }
    }
}
