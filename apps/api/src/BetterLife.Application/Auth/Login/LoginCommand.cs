using MediatR;
using BetterLife.Application.Auth.Common;

namespace BetterLife.Application.Auth.Login;

public sealed record LoginCommand(string Email, string Password) : IRequest<AuthResponse>;
