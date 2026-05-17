namespace BetterLife.Domain.Users;

using BetterLife.Domain.Common;
using BetterLife.Domain.Categories;

public sealed class User : Entity
{
    public string Name { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string PasswordHash { get; set; } = default!;
    public string TimeZone { get; set; } = default!;
    public UserStatus Status { get; set; }
    public ICollection<Category> Categories { get; set; } = new List<Category>();
}
