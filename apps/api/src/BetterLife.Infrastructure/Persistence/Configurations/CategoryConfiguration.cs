using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using BetterLife.Domain.Categories;

namespace BetterLife.Infrastructure.Persistence.Configurations;

public sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> b)
    {
        b.ToTable("Categories");
        b.HasKey(c => c.Id);
        b.Property(c => c.Id).ValueGeneratedNever();

        b.Property(c => c.UserId).IsRequired();
        b.Property(c => c.Name).IsRequired().HasMaxLength(80);
        b.Property(c => c.Color).IsRequired().HasMaxLength(7);
        b.Property(c => c.Icon).IsRequired().HasMaxLength(64);
        b.Property(c => c.Status).HasConversion<int>();
        b.Property(c => c.CreatedAt);
        b.Property(c => c.UpdatedAt);

        b.HasIndex(c => c.UserId).HasDatabaseName("IX_Categories_UserId");

        b.HasQueryFilter(c => c.Status != CategoryStatus.Deleted);
    }
}
