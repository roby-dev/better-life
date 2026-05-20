using BetterLife.Domain.Habits;

namespace BetterLife.Application.Habits.Common;

public sealed record HabitDto(
    Guid Id,
    Guid UserId,
    Guid CategoryId,
    string Name,
    FrequencyType FrequencyType,
    WeekDays? WeekDays,
    TimeOnly? ReminderTime,
    HabitStatus Status,
    DateTime CreatedAt,
    DateTime UpdatedAt);
