using BetterLife.Application.Habits.Common;
using BetterLife.Domain.Habits;
using MediatR;

namespace BetterLife.Application.Habits.Upsert;

public sealed record UpsertHabitCommand(
    Guid Id,
    string Name,
    FrequencyType FrequencyType,
    WeekDays? WeekDays,
    Guid CategoryId,
    TimeOnly? ReminderTime)
    : IRequest<HabitDto>;
