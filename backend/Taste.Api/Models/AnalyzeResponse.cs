namespace Taste.Api.Models;

public sealed record AnalyzeResponse(
    IReadOnlyList<ItemCandidateDto> Candidates
);