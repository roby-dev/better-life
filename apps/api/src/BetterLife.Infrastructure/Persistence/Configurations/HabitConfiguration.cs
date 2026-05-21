using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using BetterLife.Domain.Habits;
using BetterLife.Domain.Categories;
using BetterLife.Domain.Users;

namespace BetterLife.Infrastructure.Persistence.Configurations;

public sealed class HabitConfiguration : IEntityTypeConfiguration<Habit>
{
    public void Configure(EntityTypeBuilder<Habit> b)
    {
        b.ToTable("Habits");
        b.HasKey(h => h.Id);
        b.Property(h => h.Id).ValueGeneratedNever();

        b.Property(h => h.UserId).IsRequired();
        b.Property(h => h.CategoryId).IsRequired();
        b.Property(h => h.Name).IsRequired().HasMaxLength(200);
        b.Property(h => h.FrequencyType).HasConversion<int>();
        b.Property(h => h.WeekDays).HasConversion<int>().IsRequired(false);
        b.Property(h => h.ReminderTime).HasColumnType("time").IsRequired(false);
        b.Property(h => h.Status).HasConversion<int>();
        b.Property(h => h.CreatedAt);
        b.Property(h => h.UpdatedAt);

        b.HasIndex(h => h.UserId).HasDatabaseName("IX_Habits_UserId");

        b.HasQueryFilter(h => h.Status != HabitStatus.Deleted);

        b.HasOne<User>().WithMany().HasForeignKey(h => h.UserId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne<Category>().WithMany().HasForeignKey(h => h.CategoryId).OnDelete(DeleteBehavior.Restrict);
    }
}
