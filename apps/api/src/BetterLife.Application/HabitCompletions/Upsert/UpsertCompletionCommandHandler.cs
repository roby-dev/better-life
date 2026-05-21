using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Application.HabitCompletions.Common;
using BetterLife.Domain.Habits;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.HabitCompletions.Upsert;

public sealed class UpsertCompletionCommandHandler : IRequestHandler<UpsertCompletionCommand, HabitCompletionDto>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IClock _clock;

    public UpsertCompletionCommandHandler(IAppDbContext db, ICurrentUserAccessor currentUser, IClock clock)
    {
        _db = db;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task<HabitCompletionDto> Handle(UpsertCompletionCommand cmd, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var now = _clock.UtcNow;

        // Verify habit ownership first
        var habit = await _db.Habits
            .SingleOrDefaultAsync(h => h.Id == cmd.HabitId && h.UserId == userId, ct);

        if (habit is null)
            throw new NotFoundException(nameof(Habit), cmd.HabitId.ToString());

        // Upsert the completion
        var completion = await _db.HabitCompletions.IgnoreQueryFilters()
            .SingleOrDefaultAsync(c => c.Id == cmd.Id, ct);

        if (completion is null)
        {
            completion = new HabitCompletion
            {
                Id = cmd.Id,
                UserId = userId,
                HabitId = cmd.HabitId,
                CompletionDate = cmd.CompletionDate,
                Status = cmd.Status,
                SyncedAt = now,
                CreatedAt = now,
                UpdatedAt = now
            };
            _db.HabitCompletions.Add(completion);
        }
        else if (completion.UserId != userId || completion.Status == CompletionStatus.Deleted)
        {
            throw new NotFoundException(nameof(HabitCompletion), cmd.Id.ToString());
        }
        else
        {
            completion.CompletionDate = cmd.CompletionDate;
            completion.Status = cmd.Status;
            completion.SyncedAt = now;
            completion.UpdatedAt = now;
        }

        await _db.SaveChangesAsync(ct);
        return completion.Adapt<HabitCompletionDto>();
    }
}
