namespace Taste.Api.Models;

public sealed record ItemCandidateDto(
    string Type,
    string Title,
    string? Description,
    string? SourceUrl,
    ItemDetailsDto? Details
);