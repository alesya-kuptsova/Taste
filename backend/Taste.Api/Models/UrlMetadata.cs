namespace Taste.Api.Models;

public sealed record UrlMetadata(
    string Url,
    string? Title = null,
    string? Description = null,
    string? ImageUrl = null,
    string? SiteName = null
);