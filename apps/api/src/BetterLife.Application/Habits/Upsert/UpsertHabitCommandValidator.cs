using BetterLife.Domain.Habits;
using FluentValidation;

namespace BetterLife.Application.Habits.Upsert;

public sealed class UpsertHabitCommandValidator : AbstractValidator<UpsertHabitCommand>
{
    public UpsertHabitCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty();
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.FrequencyType).IsInEnum();
        RuleFor(x => x.CategoryId).NotEmpty();
        RuleFor(x => x.WeekDays)
            .NotNull()
            .When(x => x.FrequencyType == FrequencyType.SpecificWeekDays)
            .WithMessage("WeekDays required when FrequencyType is SpecificWeekDays.");
    }
}
