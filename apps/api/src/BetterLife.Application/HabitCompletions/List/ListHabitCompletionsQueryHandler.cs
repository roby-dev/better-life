using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Application.HabitCompletions.Common;
using BetterLife.Domain.Habits;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.HabitCompletions.List;

public sealed class ListHabitCompletionsQueryHandler
    : IRequestHandler<ListHabitCompletionsQuery, IReadOnlyList<HabitCompletionDto>>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;

    public ListHabitCompletionsQueryHandler(IAppDbContext db, ICurrentUserAccessor currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<IReadOnlyList<HabitCompletionDto>> Handle(
        ListHabitCompletionsQuery query,
        CancellationToken ct)
    {
        var userId = _currentUser.UserId;

        var habit = await _db.Habits
            .FirstOrDefaultAsync(h => h.Id == query.HabitId && h.UserId == userId, ct);

        if (habit is null)
        {
            throw new NotFoundException(nameof(Habit), query.HabitId.ToString());
        }

        var q = _db.HabitCompletions.Where(hc => hc.UserId == userId && hc.HabitId == query.HabitId);

        if (query.From.HasValue)
        {
            q = q.Where(hc => hc.CompletionDate >= query.From.Value);
        }

        if (query.To.HasValue)
        {
            q = q.Where(hc => hc.CompletionDate <= query.To.Value);
        }

        var completions = await q
            .OrderBy(hc => hc.CompletionDate)
            .ToListAsync(ct);

        return completions.Adapt<IReadOnlyList<HabitCompletionDto>>();
    }
}