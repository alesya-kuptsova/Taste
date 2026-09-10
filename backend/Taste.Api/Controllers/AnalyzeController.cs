using Microsoft.AspNetCore.Mvc;
using Taste.Api.Models;
using Taste.Api.Services;

namespace Taste.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AnalyzeController : ControllerBase
{
    private readonly IContentAnalyzer _contentAnalyzer;
    private readonly ILinkContentExtractor _linkContentExtractor;

    public AnalyzeController(
        IContentAnalyzer contentAnalyzer,
        ILinkContentExtractor linkContentExtractor)
    {
        _contentAnalyzer = contentAnalyzer;
        _linkContentExtractor = linkContentExtractor;
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
            inputForAnalysis = await _linkContentExtractor.ExtractAsync(
                url,
                cancellationToken
            );
        }

        var candidates = await _contentAnalyzer.AnalyzeAsync(
            inputForAnalysis,
            cancellationToken
        );

        return Ok(
            new AnalyzeResponse(candidates)
        );
    }
}