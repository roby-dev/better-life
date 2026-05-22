using BetterLife.Application.Categories.Common;
using MediatR;

namespace BetterLife.Application.Categories.List;

public sealed record ListCategoriesQuery : IRequest<IReadOnlyList<CategoryDto>>;
