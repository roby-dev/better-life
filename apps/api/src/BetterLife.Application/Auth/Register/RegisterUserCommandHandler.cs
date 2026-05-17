using MediatR;
using Microsoft.EntityFrameworkCore;
using BetterLife.Application.Auth.Common;
using BetterLife.Application.Common.Abstractions;
using BetterLife.Application.Common.Exceptions;
using BetterLife.Domain.Categories;
using BetterLife.Domain.Users;

namespace BetterLife.Application.Auth.Register;

public sealed class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, AuthResponse>
{
    private readonly IAppDbContext _db;
    private readonly IPasswordHasher _hasher;
    private readonly IJwtTokenService _jwt;
    private readonly IClock _clock;
    private readonly IDefaultCategoryProvider _defaults;
    private readonly IGuidGenerator _guid;

    public RegisterUserCommandHandler(IAppDbContext db, IPasswordHasher hasher, IJwtTokenService jwt,
        IClock clock, IDefaultCategoryProvider defaults, IGuidGenerator guid)
    {
        _db = db; _hasher = hasher; _jwt = jwt; _clock = clock; _defaults = defaults; _guid = guid;
    }

    public async Task<AuthResponse> Handle(RegisterUserCommand cmd, CancellationToken ct)
    {
        var email = cmd.Email.Trim().ToLowerInvariant();

        var exists = await _db.Users.AnyAsync(u => u.Email == email && u.Status == UserStatus.Active, ct);
        if (exists)
            throw new ConflictException("email-already-registered", "Ese email ya está registrado.");

        var now = _clock.UtcNow;
        var user = new User
        {
            Id = _guid.NewV7(),
            Name = cmd.Name.Trim(),
            Email = email,
            PasswordHash = _hasher.Hash(cmd.Password),
            TimeZone = cmd.TimeZone,
            Status = UserStatus.Active,
            CreatedAt = now,
            UpdatedAt = now
        };

        var categories = _defaults.GetDefaults().Select(d => new Category
        {
            Id = _guid.NewV7(),
            UserId = user.Id,
            Name = d.Name,
            Color = d.Color,
            Icon = d.Icon,
            Status = CategoryStatus.Active,
            CreatedAt = now,
            UpdatedAt = now
        }).ToList();

        _db.Users.Add(user);
        _db.Categories.AddRange(categories);

        try
        {
            await _db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException ex) when (IsUniqueEmailViolation(ex))
        {
            throw new ConflictException("email-already-registered", "Ese email ya está registrado.");
        }

        var token = _jwt.Issue(user);
        return new AuthResponse(token.Token, token.ExpiresAtUtc,
            new UserDto(user.Id, user.Name, user.Email, user.TimeZone));
    }

    private static bool IsUniqueEmailViolation(DbUpdateException ex)
    {
        var msg = ex.InnerException?.Message ?? string.Empty;
        return msg.Contains("IX_Users_Email", StringComparison.OrdinalIgnoreCase)
            || msg.Contains("duplicate key", StringComparison.OrdinalIgnoreCase);
    }
}
