using BetterLife.Domain.Categories;
using BetterLife.Application.Categories.Common;
using Mapster;

namespace BetterLife.Application.Categories.Common;

public sealed class CategoryMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
        => config.NewConfig<Category, CategoryDto>();
}
