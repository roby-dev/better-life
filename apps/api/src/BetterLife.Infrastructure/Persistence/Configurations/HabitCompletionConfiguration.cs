using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using BetterLife.Domain.Habits;

namespace BetterLife.Infrastructure.Persistence.Configurations;

public sealed class HabitCompletionConfiguration : IEntityTypeConfiguration<HabitCompletion>
{
    public void Configure(EntityTypeBuilder<HabitCompletion> b)
    {
        b.ToTable("HabitCompletions");
        b.HasKey(c => c.Id);
        b.Property(c => c.Id).ValueGeneratedNever();

        b.Property(c => c.UserId).IsRequired();
        b.Property(c => c.HabitId).IsRequired();
        b.Property(c => c.CompletionDate).HasColumnType("date").IsRequired();
        b.Property(c => c.Status).HasConversion<int>();
        b.Property(c => c.SyncedAt);
        b.Property(c => c.CreatedAt);
        b.Property(c => c.UpdatedAt);

        b.HasIndex(c => c.UserId).HasDatabaseName("IX_HabitCompletions_UserId");
        b.HasIndex(c => new { c.UserId, c.HabitId, c.CompletionDate })
            .IsUnique()
            .HasDatabaseName("UX_HabitCompletions_UserId_HabitId_Date");

        b.HasQueryFilter(c => c.Status != CompletionStatus.Deleted);

        b.HasOne<Habit>().WithMany().HasForeignKey(c => c.HabitId).OnDelete(DeleteBehavior.Cascade);
    }
}
