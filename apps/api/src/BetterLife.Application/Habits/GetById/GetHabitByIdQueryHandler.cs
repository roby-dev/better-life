using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Application.Habits.Common;
using BetterLife.Domain.Habits;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Habits.GetById;

public sealed class GetHabitByIdQueryHandler : IRequestHandler<GetHabitByIdQuery, HabitDto>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;

    public GetHabitByIdQueryHandler(IAppDbContext db, ICurrentUserAccessor currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<HabitDto> Handle(GetHabitByIdQuery query, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var habit = await _db.Habits
            .SingleOrDefaultAsync(h => h.Id == query.Id && h.UserId == userId, ct);

        if (habit is null)
            throw new NotFoundException(nameof(Habit), query.Id.ToString());

        return habit.Adapt<HabitDto>();
    }
}
