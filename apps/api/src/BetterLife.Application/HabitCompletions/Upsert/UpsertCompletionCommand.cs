using BetterLife.Application.HabitCompletions.Common;
using BetterLife.Domain.Habits;
using MediatR;

namespace BetterLife.Application.HabitCompletions.Upsert;

public sealed record UpsertCompletionCommand(
    Guid Id,
    Guid HabitId,
    DateOnly CompletionDate,
    CompletionStatus Status)
    : IRequest<HabitCompletionDto>;
