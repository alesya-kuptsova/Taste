using Taste.Api.Models;

namespace Taste.Api.Services;

public interface IUrlContentResolver
{
    Task<UrlMetadata?> ResolveAsync(
        Uri url,
        CancellationToken cancellationToken = default
    );
}