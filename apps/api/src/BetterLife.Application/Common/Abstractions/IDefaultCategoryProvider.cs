namespace BetterLife.Application.Common.Abstractions;

public interface IDefaultCategoryProvider
{
    IReadOnlyList<DefaultCategorySpec> GetDefaults();
}

public sealed record DefaultCategorySpec(string Name, string Color, string Icon);
