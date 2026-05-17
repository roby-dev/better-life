namespace BetterLife.Infrastructure.Auth;

public sealed class JwtOptions
{
    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = "betterlife-api";
    public string Audience { get; set; } = "betterlife-mobile";
    public int AccessTokenLifetimeDays { get; set; } = 30;
}
