namespace BetterLife.Domain.Habits;

using BetterLife.Domain.Common;

public sealed class Habit : Entity
{
    public Guid UserId { get; set; }
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = default!;
    public FrequencyType FrequencyType { get; set; }
    public WeekDays? WeekDays { get; set; }
    public TimeOnly? ReminderTime { get; set; }
    public HabitStatus Status { get; set; }
}
