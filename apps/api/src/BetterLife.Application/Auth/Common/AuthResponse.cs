namespace BetterLife.Application.Auth.Common;

public sealed record AuthResponse(string Token, DateTime ExpiresAtUtc, UserDto User);

public sealed record UserDto(Guid Id, string Name, string Email, string TimeZone);
