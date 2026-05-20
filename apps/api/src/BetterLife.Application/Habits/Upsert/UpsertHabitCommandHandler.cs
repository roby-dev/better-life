using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Application.Habits.Common;
using BetterLife.Domain.Habits;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Habits.Upsert;

public sealed class UpsertHabitCommandHandler : IRequestHandler<UpsertHabitCommand, HabitDto>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IClock _clock;

    public UpsertHabitCommandHandler(IAppDbContext db, ICurrentUserAccessor currentUser, IClock clock)
    {
        _db = db;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task<HabitDto> Handle(UpsertHabitCommand cmd, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var now = _clock.UtcNow;

        var habit = await _db.Habits.IgnoreQueryFilters()
            .SingleOrDefaultAsync(h => h.Id == cmd.Id, ct);

        if (habit is null)
        {
            habit = new Habit
            {
                Id = cmd.Id,
                UserId = userId,
                Name = cmd.Name,
                FrequencyType = cmd.FrequencyType,
                WeekDays = cmd.WeekDays,
                CategoryId = cmd.CategoryId,
                ReminderTime = cmd.ReminderTime,
                Status = HabitStatus.Active,
                CreatedAt = now,
                UpdatedAt = now
            };
            _db.Habits.Add(habit);
        }
        else if (habit.UserId != userId || habit.Status == HabitStatus.Deleted)
        {
            throw new NotFoundException(nameof(Habit), cmd.Id.ToString());
        }
        else
        {
            habit.Name = cmd.Name;
            habit.FrequencyType = cmd.FrequencyType;
            habit.WeekDays = cmd.WeekDays;
            habit.CategoryId = cmd.CategoryId;
            habit.ReminderTime = cmd.ReminderTime;
            habit.UpdatedAt = now;
        }

        await _db.SaveChangesAsync(ct);
        return habit.Adapt<HabitDto>();
    }
}
