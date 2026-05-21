using Asp.Versioning;
using BetterLife.Application.Habits.Common;
using BetterLife.Application.Habits.Delete;
using BetterLife.Application.Habits.GetById;
using BetterLife.Application.Habits.List;
using BetterLife.Application.Habits.Upsert;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BetterLife.Api.Controllers.V1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/habits")]
[Authorize]
public sealed class HabitsController : ControllerBase
{
    private readonly ISender _mediator;
    public HabitsController(ISender mediator) => _mediator = mediator;

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<HabitDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IReadOnlyList<HabitDto>>> ListHabits(CancellationToken ct)
        => Ok(await _mediator.Send(new ListHabitsQuery(), ct));

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(HabitDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<HabitDto>> GetById(Guid id, CancellationToken ct)
        => Ok(await _mediator.Send(new GetHabitByIdQuery(id), ct));

    [HttpPost]
    [ProducesResponseType(typeof(HabitDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<HabitDto>> Upsert([FromBody] UpsertHabitRequest req, CancellationToken ct)
    {
        var cmd = new UpsertHabitCommand(req.Id, req.Name, req.FrequencyType, req.WeekDays, req.CategoryId, req.ReminderTime);
        return Ok(await _mediator.Send(cmd, ct));
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteHabitCommand(id), ct);
        return NoContent();
    }
}
