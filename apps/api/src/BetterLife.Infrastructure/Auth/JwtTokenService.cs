using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using BetterLife.Application.Common.Abstractions;
using BetterLife.Domain.Users;

namespace BetterLife.Infrastructure.Auth;

public sealed class JwtTokenService : IJwtTokenService
{
    private readonly JwtOptions _opts;
    private readonly IClock _clock;

    public JwtTokenService(IOptions<JwtOptions> opts, IClock clock)
    {
        _opts = opts.Value;
        _clock = clock;
    }

    public JwtTokenResult Issue(User user)
    {
        var now = _clock.UtcNow;
        var expires = now.AddDays(_opts.AccessTokenLifetimeDays);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Iat,
                new DateTimeOffset(now).ToUnixTimeSeconds().ToString(),
                ClaimValueTypes.Integer64)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_opts.Secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _opts.Issuer,
            audience: _opts.Audience,
            claims: claims,
            notBefore: now,
            expires: expires,
            signingCredentials: creds);

        var encoded = new JwtSecurityTokenHandler().WriteToken(token);
        return new JwtTokenResult(encoded, expires);
    }
}
