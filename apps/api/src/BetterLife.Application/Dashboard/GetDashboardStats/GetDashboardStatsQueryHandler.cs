using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Dashboard.Common;
using BetterLife.Domain.Habits;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Dashboard.GetDashboardStats;

public sealed class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardDto>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IClock _clock;

    public GetDashboardStatsQueryHandler(IAppDbContext db, ICurrentUserAccessor currentUser, IClock clock)
    {
        _db = db;
        _currentUser = currentUser;
        _clock = clock;
    }

    public async Task<DashboardDto> Handle(GetDashboardStatsQuery query, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var today = DateOnly.FromDateTime(_clock.UtcNow);
        var weekStart = today.AddDays(-((int)today.DayOfWeek + 6) % 7);
        var weekEnd = weekStart.AddDays(6);
        var monthStart = new DateOnly(today.Year, today.Month, 1);
        var monthEnd = monthStart.AddMonths(1).AddDays(-1);
        var from = query.From ?? monthStart;
        var to = query.To ?? today;

        var totalHabits = await _db.Habits
            .CountAsync(h => h.UserId == userId && h.Status == HabitStatus.Active, ct);

        var completedToday = await _db.HabitCompletions
            .CountAsync(hc => hc.UserId == userId
                && hc.CompletionDate == today
                && hc.Status == CompletionStatus.Completed, ct);

        var completedThisWeek = await _db.HabitCompletions
            .CountAsync(hc => hc.UserId == userId
                && hc.CompletionDate >= weekStart
                && hc.CompletionDate <= weekEnd
                && hc.Status == CompletionStatus.Completed, ct);

        var completedThisMonth = await _db.HabitCompletions
            .CountAsync(hc => hc.UserId == userId
                && hc.CompletionDate >= monthStart
                && hc.CompletionDate <= monthEnd
                && hc.Status == CompletionStatus.Completed, ct);

        var totalInRange = await _db.HabitCompletions
            .CountAsync(hc => hc.UserId == userId
                && hc.CompletionDate >= from
                && hc.CompletionDate <= to, ct);

        var completedInRange = await _db.HabitCompletions
            .CountAsync(hc => hc.UserId == userId
                && hc.CompletionDate >= from
                && hc.CompletionDate <= to
                && hc.Status == CompletionStatus.Completed, ct);

        var rate = totalInRange == 0 ? 0 : (int)Math.Round((double)completedInRange / totalInRange * 100);

        return new DashboardDto(totalHabits, completedToday, completedThisWeek, completedThisMonth, rate, from, to);
    }
}