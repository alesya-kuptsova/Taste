namespace Taste.Api.Models;

public sealed record ItemCandidateDto(
    string Type,
    string Title,
    int? Year = null
);