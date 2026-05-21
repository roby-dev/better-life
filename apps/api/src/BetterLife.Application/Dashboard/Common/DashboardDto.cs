namespace BetterLife.Application.Dashboard.Common;

public sealed record DashboardDto(
    int TotalHabits,
    int CompletedToday,
    int CompletedThisWeek,
    int CompletedThisMonth,
    int CompletionRate,
    DateOnly From,
    DateOnly To);