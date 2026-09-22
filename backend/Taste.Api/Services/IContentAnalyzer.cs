using Taste.Api.Models;

namespace Taste.Api.Services;

public interface IContentAnalyzer
{
    Task<IReadOnlyList<ItemCandidateDto>> AnalyzeAsync(
        string input,
        CancellationToken cancellationToken = default
    );
    
    Task<IReadOnlyList<ItemCandidateDto>> AnalyzeImageAsync(
        string? input,
        byte[]? imageBytes,
        string? imageContentType,
        CancellationToken cancellationToken = default
    );
}