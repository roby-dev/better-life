using MediatR;
using Microsoft.EntityFrameworkCore;
using BetterLife.Application.Auth.Common;
using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Domain.Users;

namespace BetterLife.Application.Auth.Login;

public sealed class LoginCommandHandler : IRequestHandler<LoginCommand, AuthResponse>
{
    // Pre-computed BCrypt hash used for timing-safe verify when user doesn't exist,
    // preventing user-enumeration via response-time differences.
    private const string DummyHash = "$2a$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";

    private readonly IAppDbContext _db;
    private readonly IPasswordHasher _hasher;
    private readonly IJwtTokenService _jwt;

    public LoginCommandHandler(IAppDbContext db, IPasswordHasher hasher, IJwtTokenService jwt)
    {
        _db = db; _hasher = hasher; _jwt = jwt;
    }

    public async Task<AuthResponse> Handle(LoginCommand cmd, CancellationToken ct)
    {
        var email = cmd.Email.Trim().ToLowerInvariant();
        var user = await _db.Users
            .SingleOrDefaultAsync(u => u.Email == email && u.Status == UserStatus.Active, ct);

        var passwordMatches = _hasher.Verify(cmd.Password, user?.PasswordHash ?? DummyHash);

        if (user is null || !passwordMatches)
            throw new AuthenticationException("invalid-credentials", "Email o contraseña incorrectos.");

        var token = _jwt.Issue(user);
        return new AuthResponse(token.Token, token.ExpiresAtUtc,
            new UserDto(user.Id, user.Name, user.Email, user.TimeZone));
    }
}
