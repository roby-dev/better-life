using BetterLife.Domain.Habits;

namespace BetterLife.Application.HabitCompletions.Common;

public sealed record HabitCompletionDto(
    Guid Id,
    Guid UserId,
    Guid HabitId,
    DateOnly CompletionDate,
    CompletionStatus Status,
    DateTime SyncedAt,
    DateTime CreatedAt,
    DateTime UpdatedAt);
