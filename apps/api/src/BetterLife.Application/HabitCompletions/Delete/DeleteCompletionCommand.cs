using MediatR;

namespace BetterLife.Application.HabitCompletions.Delete;

public sealed record DeleteCompletionCommand(Guid HabitId, Guid Id) : IRequest;
