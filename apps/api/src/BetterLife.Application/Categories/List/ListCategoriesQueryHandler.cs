using BetterLife.Application.Categories.Common;
using BetterLife.Application.Common.Abstractions;
using BetterLife.Domain.Categories;
using Mapster;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BetterLife.Application.Categories.List;

public sealed class ListCategoriesQueryHandler : IRequestHandler<ListCategoriesQuery, IReadOnlyList<CategoryDto>>
{
    private readonly IAppDbContext _db;
    private readonly ICurrentUserAccessor _currentUser;

    public ListCategoriesQueryHandler(IAppDbContext db, ICurrentUserAccessor currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<IReadOnlyList<CategoryDto>> Handle(ListCategoriesQuery query, CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var categories = await _db.Categories
            .Where(c => c.UserId == userId && c.Status == CategoryStatus.Active)
            .OrderBy(c => c.Name)
            .ToListAsync(ct);
        return categories.Adapt<IReadOnlyList<CategoryDto>>();
    }
}
