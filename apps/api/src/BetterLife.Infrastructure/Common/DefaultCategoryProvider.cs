using BetterLife.Application.Common.Abstractions;

namespace BetterLife.Infrastructure.Common;

public sealed class DefaultCategoryProvider : IDefaultCategoryProvider
{
    private static readonly IReadOnlyList<DefaultCategorySpec> Defaults = new[]
    {
        new DefaultCategorySpec("Salud",          "#E26D5A", "heart"),
        new DefaultCategorySpec("Estudio",        "#7A9B76", "book"),
        new DefaultCategorySpec("Trabajo",        "#5B7BA5", "briefcase"),
        new DefaultCategorySpec("Finanzas",       "#D8A24A", "wallet"),
        new DefaultCategorySpec("Familia",        "#C25450", "users"),
        new DefaultCategorySpec("Espiritualidad", "#9D7BB5", "sparkle"),
        new DefaultCategorySpec("Productividad",  "#3F8C8C", "bolt"),
        new DefaultCategorySpec("Otro",           "#8A847E", "tag"),
    };

    public IReadOnlyList<DefaultCategorySpec> GetDefaults() => Defaults;
}
