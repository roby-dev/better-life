using System.Security.Claims;
using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using Microsoft.AspNetCore.Http;

namespace BetterLife.Infrastructure.Common;

public sealed class CurrentUserAccessor : ICurrentUserAccessor
{
    private readonly IHttpContextAccessor _http;
    public CurrentUserAccessor(IHttpContextAccessor http) => _http = http;

    public Guid UserId
    {
        get
        {
            var sub = _http.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new AuthenticationException("missing-user-claim", "User identity not found.");
            return Guid.Parse(sub);
        }
    }
}
