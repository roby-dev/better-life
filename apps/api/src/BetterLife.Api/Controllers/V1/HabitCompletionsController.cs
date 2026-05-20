using Asp.Versioning;
using BetterLife.Application.HabitCompletions.Common;
using BetterLife.Application.HabitCompletions.Delete;
using BetterLife.Application.HabitCompletions.Upsert;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BetterLife.Api.Controllers.V1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/habits/{habitId:guid}/completions")]
[Authorize]
public sealed class HabitCompletionsController : ControllerBase
{
    private readonly ISender _mediator;
    public HabitCompletionsController(ISender mediator) => _mediator = mediator;

    [HttpPost]
    [ProducesResponseType(typeof(HabitCompletionDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<HabitCompletionDto>> Upsert(
        Guid habitId, [FromBody] UpsertCompletionRequest req, CancellationToken ct)
    {
        var cmd = new UpsertCompletionCommand(req.Id, habitId, req.CompletionDate, req.Status);
        return Ok(await _mediator.Send(cmd, ct));
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Delete(Guid habitId, Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteCompletionCommand(habitId, id), ct);
        return NoContent();
    }
}
