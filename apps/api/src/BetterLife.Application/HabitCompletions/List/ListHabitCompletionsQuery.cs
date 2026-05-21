using BetterLife.Application.HabitCompletions.Common;
using MediatR;

namespace BetterLife.Application.HabitCompletions.List;

public sealed record ListHabitCompletionsQuery(
    Guid HabitId,
    DateOnly? From,
    DateOnly? To) : IRequest<IReadOnlyList<HabitCompletionDto>>;