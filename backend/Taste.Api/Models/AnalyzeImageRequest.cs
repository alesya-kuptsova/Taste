using Microsoft.AspNetCore.Http;

namespace Taste.Api.Models;

public sealed class AnalyzeImageRequest
{
    public string? Input { get; set; }

    public IFormFile? Image { get; set; }
}