namespace Taste.Api.Models;

public sealed record ItemDetailsDto(
    int? Year = null,
    string? Author = null,
    string? Location = null,
    string? MapQuery = null,
    string? ImageUrl = null,
    string? ExternalUrl = null
);