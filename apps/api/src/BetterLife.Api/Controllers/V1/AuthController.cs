using Asp.Versioning;
using BetterLife.Application.Auth.Common;
using BetterLife.Application.Auth.Login;
using BetterLife.Application.Auth.Register;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BetterLife.Api.Controllers.V1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly ISender _mediator;
    public AuthController(ISender mediator) => _mediator = mediator;

    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterUserRequest req, CancellationToken ct)
    {
        var cmd = new RegisterUserCommand(req.Name, req.Email, req.Password, req.TimeZone);
        var res = await _mediator.Send(cmd, ct);
        return StatusCode(StatusCodes.Status201Created, res);
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest req, CancellationToken ct)
    {
        var res = await _mediator.Send(new LoginCommand(req.Email, req.Password), ct);
        return Ok(res);
    }
}
