using BetterLife.Domain.Users;

namespace BetterLife.Application.Common.Abstractions;

public interface IJwtTokenService { JwtTokenResult Issue(User user); }

public sealed record JwtTokenResult(string Token, DateTime ExpiresAtUtc);
