using BetterLife.Domain.Habits;

namespace BetterLife.Application.Habits.Upsert;

public sealed record UpsertHabitRequest(
    Guid Id,
    string Name,
    FrequencyType FrequencyType,
    WeekDays? WeekDays,
    Guid CategoryId,
    TimeOnly? ReminderTime);
