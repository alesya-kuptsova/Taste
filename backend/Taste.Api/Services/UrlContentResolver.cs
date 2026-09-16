using System.Net;
using System.Text.RegularExpressions;
using Taste.Api.Models;

namespace Taste.Api.Services;

public sealed class UrlContentResolver : IUrlContentResolver
{
    private readonly HttpClient _httpClient;

    public UrlContentResolver(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<UrlMetadata?> ResolveAsync(
        Uri url,
        CancellationToken cancellationToken = default)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);

        request.Headers.UserAgent.ParseAdd(
            "Mozilla/5.0 (compatible; Taste/1.0)"
        );

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken
        );

        if (!response.IsSuccessStatusCode)
            return null;

        var html = await response.Content.ReadAsStringAsync(cancellationToken);

        var title =
            GetMetaContent(html, "property", "og:title")
            ?? GetTitle(html);

        var description =
            GetMetaContent(html, "property", "og:description")
            ?? GetMetaContent(html, "name", "description");

        var imageUrl =
            GetMetaContent(html, "property", "og:image");

        var siteName =
            GetMetaContent(html, "property", "og:site_name");

        return new UrlMetadata(
            Url: url.ToString(),
            Title: Decode(title),
            Description: Decode(description),
            ImageUrl: imageUrl,
            SiteName: Decode(siteName)
        );
    }

    private static string? GetTitle(string html)
    {
        var match = Regex.Match(
            html,
            @"<title[^>]*>(.*?)</title>",
            RegexOptions.IgnoreCase | RegexOptions.Singleline
        );

        return match.Success
            ? match.Groups[1].Value.Trim()
            : null;
    }

    private static string? GetMetaContent(
        string html,
        string attributeName,
        string attributeValue)
    {
        var pattern =
            $@"<meta[^>]*{attributeName}\s*=\s*[""']{Regex.Escape(attributeValue)}[""'][^>]*content\s*=\s*[""']([^""']*)[""'][^>]*>";

        var match = Regex.Match(
            html,
            pattern,
            RegexOptions.IgnoreCase
        );

        if (match.Success)
            return match.Groups[1].Value.Trim();

        // Некоторые сайты ставят content перед property/name.
        pattern =
            $@"<meta[^>]*content\s*=\s*[""']([^""']*)[""'][^>]*{attributeName}\s*=\s*[""']{Regex.Escape(attributeValue)}[""'][^>]*>";

        match = Regex.Match(
            html,
            pattern,
            RegexOptions.IgnoreCase
        );

        return match.Success
            ? match.Groups[1].Value.Trim()
            : null;
    }

    private static string? Decode(string? value)
    {
        return value is null
            ? null
            : WebUtility.HtmlDecode(value);
    }
}