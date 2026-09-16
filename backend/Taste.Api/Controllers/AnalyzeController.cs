using Microsoft.AspNetCore.Mvc;
using Taste.Api.Models;
using Taste.Api.Services;

namespace Taste.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AnalyzeController : ControllerBase
{
    private readonly IContentAnalyzer _contentAnalyzer;
    private readonly IUrlContentResolver _urlContentResolver;
    private readonly IPlaceResolver _placeResolver;

    public AnalyzeController(
        IContentAnalyzer contentAnalyzer,
        IUrlContentResolver urlContentResolver,
        IPlaceResolver placeResolver)
    {
        _contentAnalyzer = contentAnalyzer;
        _urlContentResolver = urlContentResolver;
        _placeResolver = placeResolver;
    }

    [HttpPost]
    public async Task<ActionResult<AnalyzeResponse>> Analyze(
        AnalyzeRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Input))
        {
            return BadRequest("Input cannot be empty.");
        }

        var inputForAnalysis = request.Input;

        if (Uri.TryCreate(request.Input, UriKind.Absolute, out var url))
        {
            var metadata = await _urlContentResolver.ResolveAsync(
                url,
                cancellationToken
            );

            if (metadata is not null)
            {
                inputForAnalysis =
                    $"The user saved this URL:\n{metadata.Url}\n\n" +
                    $"Page title:\n{metadata.Title ?? "Unknown"}\n\n" +
                    $"Page description:\n{metadata.Description ?? "Unknown"}\n\n" +
                    $"Site:\n{metadata.SiteName ?? "Unknown"}\n\n" +
                    $"Page image:\n{metadata.ImageUrl ?? "Unknown"}";
            }
        }
        

        var candidates = await _contentAnalyzer.AnalyzeAsync(
            inputForAnalysis,
            cancellationToken
        );

        var enrichedCandidates = new List<ItemCandidateDto>();

        foreach (var candidate in candidates)
        {
            if (candidate.Type == "place" &&
                candidate.Details?.MapQuery is { Length: > 0 } mapQuery)
            {
                var resolvedPlace = await _placeResolver.ResolveAsync(
                    mapQuery,
                    cancellationToken
                );

                if (resolvedPlace is not null)
                {
                    var updatedDetails = candidate.Details with
                    {
                        Latitude = resolvedPlace.Latitude,
                        Longitude = resolvedPlace.Longitude,
                        FormattedAddress = resolvedPlace.FormattedAddress,
                        ExternalPlaceId = resolvedPlace.ExternalPlaceId,
                        ExternalUrl = resolvedPlace.ExternalUrl
                    };

                    enrichedCandidates.Add(
                        candidate with
                        {
                            Details = updatedDetails
                        }
                    );

                    continue;
                }
            }

            enrichedCandidates.Add(candidate);
        }
        
        return Ok(
            new AnalyzeResponse(enrichedCandidates)
        );
    }
}