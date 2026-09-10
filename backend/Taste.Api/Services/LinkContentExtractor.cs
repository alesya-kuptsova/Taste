namespace Taste.Api.Services;

public sealed class LinkContentExtractor : ILinkContentExtractor
{
    private readonly HttpClient _httpClient;

    public LinkContentExtractor(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<string> ExtractAsync(
        Uri url,
        CancellationToken cancellationToken = default
    )
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);

        request.Headers.UserAgent.ParseAdd(
            "Mozilla/5.0 (compatible; Taste/1.0)"
        );

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken
        );

        response.EnsureSuccessStatusCode();

        return await response.Content.ReadAsStringAsync();
    }
}