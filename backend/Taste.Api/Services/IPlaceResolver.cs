using Taste.Api.Models;

namespace Taste.Api.Services;

public interface IPlaceResolver
{
    Task<ResolvedPlace?> ResolveAsync(
        string query,
        CancellationToken cancellationToken = default
    );
}