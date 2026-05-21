using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Habits.Common;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Habits.List;

public sealed class ListHabitsQueryHandler : IRequestHandler<ListHabitsQuery, IReadOnlyList<HabitDto>>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;

    public ListHabitsQueryHandler(IAppDbContext db, ICurrentUserAccessor currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<IReadOnlyList<HabitDto>> Handle(ListHabitsQuery query, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var habits = await _db.Habits
            .Where(h => h.UserId == userId)
            .ToListAsync(ct);
        return habits.Adapt<IReadOnlyList<HabitDto>>();
    }
}
