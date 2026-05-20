using BetterLife.Domain.Categories;
using BetterLife.Domain.Habits;
using BetterLife.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Common.Abstractions;

public interface IAppDbContext
{
    DbSet<User> Users { get; }
    DbSet<Category> Categories { get; }
    DbSet<Habit> Habits { get; }
    DbSet<HabitCompletion> HabitCompletions { get; }
    Task<int> SaveChangesAsync(CancellationToken ct);
}
