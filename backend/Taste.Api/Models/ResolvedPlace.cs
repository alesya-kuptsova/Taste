namespace Taste.Api.Models;

public sealed record ResolvedPlace(
    string Name,
    string? FormattedAddress,
    double Latitude,
    double Longitude,
    string? ExternalPlaceId = null,
    string? ExternalUrl = null
);