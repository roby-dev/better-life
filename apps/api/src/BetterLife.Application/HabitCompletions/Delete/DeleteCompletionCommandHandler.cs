using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Domain.Habits;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.HabitCompletions.Delete;

public sealed class DeleteCompletionCommandHandler : IRequestHandler<DeleteCompletionCommand>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IClock _clock;

    public DeleteCompletionCommandHandler(IAppDbContext db, ICurrentUserAccessor currentUser, IClock clock)
    {
        _db = db;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task Handle(DeleteCompletionCommand cmd, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var completion = await _db.HabitCompletions
            .SingleOrDefaultAsync(
                c => c.Id == cmd.Id && c.HabitId == cmd.HabitId && c.UserId == userId, ct);

        if (completion is null)
            throw new NotFoundException(nameof(HabitCompletion), cmd.Id.ToString());

        completion.Status = CompletionStatus.Deleted;
        completion.UpdatedAt = _clock.UtcNow;
        await _db.SaveChangesAsync(ct);
    }
}
