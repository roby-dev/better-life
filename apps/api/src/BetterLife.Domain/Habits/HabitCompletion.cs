namespace BetterLife.Domain.Habits;

using BetterLife.Domain.Common;

public sealed class HabitCompletion : Entity
{
    public Guid UserId { get; set; }
    public Guid HabitId { get; set; }
    public DateOnly CompletionDate { get; set; }
    public CompletionStatus Status { get; set; }
    public DateTime SyncedAt { get; set; }
}
