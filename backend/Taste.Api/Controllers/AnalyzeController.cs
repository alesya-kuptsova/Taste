using Microsoft.AspNetCore.Mvc;
using Taste.Api.Models;

namespace Taste.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AnalyzeController : ControllerBase
{
    [HttpPost]
    public ActionResult<AnalyzeResponse> Analyze(AnalyzeRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Input))
        {
            return BadRequest("Input cannot be empty.");
        }

        ItemCandidateDto candidate;

        if (request.Input.Contains(
                "oldboy",
                StringComparison.OrdinalIgnoreCase))
        {
            candidate = new ItemCandidateDto(
                Type: "movie",
                Title: "Oldboy",
                Year: 2003
            );
        }
        else
        {
            candidate = new ItemCandidateDto(
                Type: "freeform",
                Title: request.Input
            );
        }

        return Ok(
            new AnalyzeResponse(
                Candidates: new[] { candidate }
            )
        );
    }
}