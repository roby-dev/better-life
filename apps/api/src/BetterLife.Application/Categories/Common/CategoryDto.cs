namespace BetterLife.Application.Categories.Common;

public sealed record CategoryDto(
    Guid Id,
    Guid UserId,
    string Name,
    string Color,
    string Icon);
