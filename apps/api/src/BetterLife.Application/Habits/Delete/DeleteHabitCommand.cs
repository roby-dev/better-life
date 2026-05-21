using MediatR;

namespace BetterLife.Application.Habits.Delete;

public sealed record DeleteHabitCommand(Guid Id) : IRequest;
