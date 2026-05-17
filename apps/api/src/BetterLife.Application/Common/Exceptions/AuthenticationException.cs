namespace BetterLife.Application.Common.Exceptions;

public sealed class AuthenticationException : Exception
{
    public string ErrorType { get; }

    public AuthenticationException(string errorType, string message) : base(message) => ErrorType = errorType;
}
