using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Domain.Habits;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Habits.Delete;

public sealed class DeleteHabitCommandHandler : IRequestHandler<DeleteHabitCommand>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IClock _clock;

    public DeleteHabitCommandHandler(IAppDbContext db, ICurrentUserAccessor currentUser, IClock clock)
    {
        _db = db;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task Handle(DeleteHabitCommand cmd, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var habit = await _db.Habits
            .SingleOrDefaultAsync(h => h.Id == cmd.Id && h.UserId == userId, ct);

        if (habit is null)
            throw new NotFoundException(nameof(Habit), cmd.Id.ToString());

        habit.Status = HabitStatus.Deleted;
        habit.UpdatedAt = _clock.UtcNow;
        await _db.SaveChangesAsync(ct);
    }
}
