using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using BetterLife.Domain.Users;

namespace BetterLife.Infrastructure.Persistence.Configurations;

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> b)
    {
        b.ToTable("Users");
        b.HasKey(u => u.Id);
        b.Property(u => u.Id).ValueGeneratedNever();

        b.Property(u => u.Name).IsRequired().HasMaxLength(100);
        b.Property(u => u.Email).IsRequired().HasMaxLength(256);
        b.Property(u => u.PasswordHash).IsRequired().HasMaxLength(200);
        b.Property(u => u.TimeZone).IsRequired().HasMaxLength(128);
        b.Property(u => u.Status).HasConversion<int>();
        b.Property(u => u.CreatedAt);
        b.Property(u => u.UpdatedAt);

        // Unique email filtered to active users only (using SQL Server filtered index)
        b.HasIndex(u => u.Email)
            .IsUnique()
            .HasFilter("[Status] = 0")
            .HasDatabaseName("IX_Users_Email_Active_Unique");

        b.HasQueryFilter(u => u.Status != UserStatus.Deleted);

        b.HasMany(u => u.Categories)
            .WithOne()
            .HasForeignKey(c => c.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
