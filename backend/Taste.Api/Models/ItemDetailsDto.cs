namespace Taste.Api.Models;

public sealed record ItemDetailsDto(
    int? Year = null,
    string? Author = null,
    string? Location = null,
    string? MapQuery = null,
    double? Latitude = null,
    double? Longitude = null,
    string? FormattedAddress = null,
    string? ExternalPlaceId = null,
    string? ImageUrl = null,
    string? ExternalUrl = null
);