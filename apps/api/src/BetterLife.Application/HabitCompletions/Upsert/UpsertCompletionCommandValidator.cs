using BetterLife.Domain.Habits;
using FluentValidation;

namespace BetterLife.Application.HabitCompletions.Upsert;

public sealed class UpsertCompletionCommandValidator : AbstractValidator<UpsertCompletionCommand>
{
    public UpsertCompletionCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty();
        RuleFor(x => x.HabitId).NotEmpty();
        RuleFor(x => x.CompletionDate).NotEmpty();
        RuleFor(x => x.Status).IsInEnum()
            .Must(s => s != CompletionStatus.Deleted)
            .WithMessage("Use DELETE endpoint to soft-delete a completion.");
    }
}
