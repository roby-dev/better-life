using BetterLife.Domain.Habits;

namespace BetterLife.Application.HabitCompletions.Upsert;

public sealed record UpsertCompletionRequest(
    Guid Id,
    DateOnly CompletionDate,
    CompletionStatus Status);
