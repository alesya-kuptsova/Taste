using System.Globalization;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Taste.Api.Models;

namespace Taste.Api.Services;

public sealed class NominatimPlaceResolver : IPlaceResolver
{
    private readonly HttpClient _httpClient;

    public NominatimPlaceResolver(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<ResolvedPlace?> ResolveAsync(
        string query,
        CancellationToken cancellationToken = default)
    {
        var url =
            $"search?q={Uri.EscapeDataString(query)}&format=jsonv2&limit=1";

        var results = await _httpClient.GetFromJsonAsync<NominatimResult[]>(
            url,
            cancellationToken
        );

        var result = results?.FirstOrDefault();

        if (result is null)
            return null;

        if (!double.TryParse(
                result.Lat,
                NumberStyles.Float,
                CultureInfo.InvariantCulture,
                out var latitude) ||
            !double.TryParse(
                result.Lon,
                NumberStyles.Float,
                CultureInfo.InvariantCulture,
                out var longitude))
        {
            return null;
        }

        return new ResolvedPlace(
            Name: result.Name ?? query,
            FormattedAddress: result.DisplayName,
            Latitude: latitude,
            Longitude: longitude,
            ExternalPlaceId: result.PlaceId?.ToString()
        );
    }

    private sealed class NominatimResult
    {
        [JsonPropertyName("place_id")]
        public long? PlaceId { get; init; }

        [JsonPropertyName("name")]
        public string? Name { get; init; }

        [JsonPropertyName("display_name")]
        public string? DisplayName { get; init; }

        [JsonPropertyName("lat")]
        public string? Lat { get; init; }

        [JsonPropertyName("lon")]
        public string? Lon { get; init; }
    }
}