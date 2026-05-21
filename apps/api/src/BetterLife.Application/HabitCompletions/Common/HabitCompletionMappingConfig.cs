using BetterLife.Domain.Habits;
using BetterLife.Application.HabitCompletions.Common;
using Mapster;

namespace BetterLife.Application.HabitCompletions.Common;

public sealed class HabitCompletionMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
        => config.NewConfig<HabitCompletion, HabitCompletionDto>();
}
