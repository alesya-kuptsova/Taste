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
        
        var inputForAnalysis = await PrepareInputAsync(
            request.Input,
            cancellationToken
        );
        
        var candidates = await _contentAnalyzer.AnalyzeAsync(
            inputForAnalysis,
            cancellationToken
        );

        
        var sourceUrl = GetSourceUrl(request.Input);

        candidates = candidates
            .Select(candidate => candidate with
            {
                SourceUrl = sourceUrl
            })
            .ToList();
        
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
    
    
    private async Task<string> PrepareInputAsync(
        string? input,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return "";
        }

        var trimmedInput = input.Trim();

        if (!Uri.TryCreate(
                trimmedInput,
                UriKind.Absolute,
                out var url) ||
            (url.Scheme != Uri.UriSchemeHttp &&
             url.Scheme != Uri.UriSchemeHttps))
        {
            return trimmedInput;
        }

        var metadata = await _urlContentResolver.ResolveAsync(
            url,
            cancellationToken
        );

        if (metadata is null)
        {
            return trimmedInput;
        }

        return
            $"The user saved this URL:\n{metadata.Url}\n\n" +
            $"Page title:\n{metadata.Title ?? "Unknown"}\n\n" +
            $"Page description:\n{metadata.Description ?? "Unknown"}\n\n" +
            $"Site:\n{metadata.SiteName ?? "Unknown"}\n\n" +
            $"Page image:\n{metadata.ImageUrl ?? "Unknown"}";
    }
    
    
    private static string? GetSourceUrl(string? input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return null;
        }

        var trimmedInput = input.Trim();

        if (!Uri.TryCreate(
                trimmedInput,
                UriKind.Absolute,
                out var url))
        {
            return null;
        }

        if (url.Scheme != Uri.UriSchemeHttp &&
            url.Scheme != Uri.UriSchemeHttps)
        {
            return null;
        }

        return url.AbsoluteUri;
    }
    
    [HttpPost("image")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<AnalyzeResponse>> AnalyzeImage(
        [FromForm] AnalyzeImageRequest request,
        CancellationToken cancellationToken)
    {
        var sourceUrl = GetSourceUrl(request.Input);
        byte[]? imageBytes = null;
        string? imageContentType = null;
        
        if (string.IsNullOrWhiteSpace(request.Input) &&
            request.Image is null)
        {
            return BadRequest(
                "Provide text, a URL, or an image."
            );
        }

        if (request.Image is not null)
        {
            if (request.Image.Length == 0)
            {
                return BadRequest("Image cannot be empty.");
            }

            const long maxImageSize = 10 * 1024 * 1024;

            if (request.Image.Length > maxImageSize)
            {
                return BadRequest(
                    "Image must be smaller than 10 MB."
                );
            }

            var allowedTypes = new[]
            {
                "image/jpeg",
                "image/png",
                "image/webp"
            };

            if (!allowedTypes.Contains(
                    request.Image.ContentType,
                    StringComparer.OrdinalIgnoreCase))
            {
                return BadRequest(
                    "Only JPEG, PNG and WebP images are supported."
                );
            }
        }

        if (request.Image is not null)
        {
            using var memoryStream = new MemoryStream();

            await request.Image.CopyToAsync(
                memoryStream,
                cancellationToken
            );

            imageBytes = memoryStream.ToArray();
            imageContentType = request.Image.ContentType;
        }


        var inputForAnalysis = await PrepareInputAsync(
            request.Input,
            cancellationToken
        );

        var candidates = await _contentAnalyzer.AnalyzeImageAsync(
            inputForAnalysis,
            imageBytes,
            imageContentType,
            cancellationToken
        );

        candidates = candidates
            .Select(candidate => candidate with
            {
                SourceUrl = sourceUrl
            })
            .ToList();

        var enrichedCandidates = await EnrichPlacesAsync(
            candidates,
            cancellationToken
        );

        return Ok(
            new AnalyzeResponse(enrichedCandidates)
        );
    }

    private async Task<IReadOnlyList<ItemCandidateDto>> EnrichPlacesAsync(
        IReadOnlyList<ItemCandidateDto> candidates,
        CancellationToken cancellationToken)
    {
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

        return enrichedCandidates;
    }
}