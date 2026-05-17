using System.Buffers.Binary;
using System.Security.Cryptography;
using BetterLife.Application.Common.Abstractions;

namespace BetterLife.Infrastructure.Common;

public sealed class GuidV7Generator : IGuidGenerator
{
    public Guid NewV7()
    {
        Span<byte> bytes = stackalloc byte[16];

        var unixMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        // 48-bit big-endian timestamp in bytes 0..5
        Span<byte> tsBuf = stackalloc byte[8];
        BinaryPrimitives.WriteInt64BigEndian(tsBuf, unixMs);
        tsBuf[2..8].CopyTo(bytes[..6]);

        // 80 bits of cryptographic randomness in bytes 6..15
        RandomNumberGenerator.Fill(bytes[6..]);

        // Set version 7 in the high nibble of byte 6: 0111xxxx
        bytes[6] = (byte)((bytes[6] & 0x0F) | 0x70);

        // Set RFC 4122 variant (10xxxxxx) in byte 8
        bytes[8] = (byte)((bytes[8] & 0x3F) | 0x80);

        return new Guid(bytes, bigEndian: true);
    }
}
