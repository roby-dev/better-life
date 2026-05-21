using BetterLife.Domain.Habits;
using BetterLife.Application.Habits.Common;
using Mapster;

namespace BetterLife.Application.Habits.Common;

public sealed class HabitMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
        => config.NewConfig<Habit, HabitDto>();
}
