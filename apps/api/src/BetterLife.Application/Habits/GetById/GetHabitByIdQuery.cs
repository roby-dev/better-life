using BetterLife.Application.Habits.Common;
using MediatR;

namespace BetterLife.Application.Habits.GetById;

public sealed record GetHabitByIdQuery(Guid Id) : IRequest<HabitDto>;
