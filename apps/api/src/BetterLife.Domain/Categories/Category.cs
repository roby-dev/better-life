namespace BetterLife.Domain.Categories;

using BetterLife.Domain.Common;

public sealed class Category : Entity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = default!;
    public string Color { get; set; } = default!;
    public string Icon { get; set; } = default!;
    public CategoryStatus Status { get; set; }
}
