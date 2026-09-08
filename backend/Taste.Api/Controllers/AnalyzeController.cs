using Microsoft.AspNetCore.Mvc;
using Taste.Api.Models;
using Taste.Api.Services;

namespace Taste.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AnalyzeController : ControllerBase
{
    private readonly IContentAnalyzer _contentAnalyzer;

    public AnalyzeController(IContentAnalyzer contentAnalyzer)
    {
        _contentAnalyzer = contentAnalyzer;
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

        var candidates = await _contentAnalyzer.AnalyzeAsync(
            request.Input,
            cancellationToken
        );

        return Ok(
            new AnalyzeResponse(candidates)
        );
    }
}