using BetterLife.Application.Habits.Common;
using MediatR;

namespace BetterLife.Application.Habits.List;

public sealed record ListHabitsQuery : IRequest<IReadOnlyList<HabitDto>>;
