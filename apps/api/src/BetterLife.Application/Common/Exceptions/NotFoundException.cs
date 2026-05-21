namespace BetterLife.Application.Common.Exceptions;

public sealed class NotFoundException : Exception
{
    public string ErrorType { get; }

    public NotFoundException(string errorType, string message) : base(message) => ErrorType = errorType;
}
