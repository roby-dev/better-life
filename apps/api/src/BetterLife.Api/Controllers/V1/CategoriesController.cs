using Asp.Versioning;
using BetterLife.Application.Categories.Common;
using BetterLife.Application.Categories.List;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BetterLife.Api.Controllers.V1;

[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/categories")]
[Authorize]
public sealed class CategoriesController : ControllerBase
{
    private readonly ISender _mediator;
    public CategoriesController(ISender mediator) => _mediator = mediator;

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<CategoryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IReadOnlyList<CategoryDto>>> ListCategories(CancellationToken ct)
        => Ok(await _mediator.Send(new ListCategoriesQuery(), ct));
}
