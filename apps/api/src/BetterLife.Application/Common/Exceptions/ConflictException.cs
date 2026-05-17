namespace BetterLife.Application.Common.Exceptions;

public sealed class ConflictException : Exception
{
    public string ErrorType { get; }

    public ConflictException(string errorType, string message) : base(message) => ErrorType = errorType;
}
