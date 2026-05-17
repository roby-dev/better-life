using BetterLife.Application.Common.Abstractions;

namespace BetterLife.Infrastructure.Common;

public sealed class SystemClock : IClock
{
    public DateTime UtcNow => DateTime.UtcNow;
}
