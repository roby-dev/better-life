using MediatR;
using BetterLife.Application.Auth.Common;

namespace BetterLife.Application.Auth.Register;

public sealed record RegisterUserCommand(string Name, string Email, string Password, string TimeZone)
    : IRequest<AuthResponse>;
