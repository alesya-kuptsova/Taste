using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Taste.Api.Models;

namespace Taste.Api.Services;

public sealed class OpenAIContentAnalyzer : IContentAnalyzer
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public OpenAIContentAnalyzer(
        HttpClient httpClient,
        IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    public async Task<IReadOnlyList<ItemCandidateDto>> AnalyzeAsync(
        string input,
        CancellationToken cancellationToken = default)
    {
        var apiKey = _configuration["OpenAI:ApiKey"]
            ?? throw new InvalidOperationException(
                "OpenAI API key is not configured.");

        var model = _configuration["OpenAI:Model"]
            ?? throw new InvalidOperationException(
                "OpenAI model is not configured.");

        using var request = new HttpRequestMessage(
            HttpMethod.Post,
            "https://api.openai.com/v1/responses"
        );

        request.Headers.Authorization =
            new AuthenticationHeaderValue("Bearer", apiKey);

        request.Content = JsonContent.Create(new
        {
            model,

            instructions = @"
                You analyze things a user wants to save to a personal wishlist.

                Identify what the user most likely means.

                Allowed item types:
                movie, book, game, music, place, product, freeform.

                Rules:
                - Use ""freeform"" when the wish is not a clearly identifiable catalog item.
                - Do not invent details you are not reasonably confident about.
                - If the input is ambiguous, return multiple plausible candidates.
                - Return no more than 5 candidates.
            ",

            input,

            text = new
            {
                format = new
                {
                    type = "json_schema",
                    name = "wishlist_candidates",
                    strict = true,

                    schema = new
                    {
                        type = "object",
                        properties = new
                        {
                            candidates = new 
                            { 
                                type = "array", 
                                maxItems = 5,
                                items = new 
                                { 
                                    type = "object",
                                    properties = new 
                                    { 
                                        type = new 
                                        { 
                                            type = "string", 
                                            @enum = new[] 
                                            { 
                                                "movie", 
                                                "book", 
                                                "game", 
                                                "music", 
                                                "place", 
                                                "product", 
                                                "freeform" 
                                            } 
                                        },
                                        
                                        title = new 
                                        { 
                                            type = "string" 
                                        },
                                        
                                        description = new 
                                        { 
                                            type = new[] { "string", "null" } 
                                        },
                                        
                                        sourceUrl = new 
                                        { 
                                            type = new[] { "string", "null" } 
                                        },
                                        
                                        details = new 
                                        { 
                                            type = new[] { "object", "null" },
                                            
                                            properties = new 
                                            { 
                                                year = new 
                                                { 
                                                    type = new[] { "integer", "null" } 
                                                },
                                                
                                                author = new 
                                                { 
                                                    type = new[] { "string", "null" } 
                                                },
                                                
                                                location = new 
                                                { 
                                                    type = new[] { "string", "null" } 
                                                },
                                                
                                                mapQuery = new 
                                                { 
                                                    type = new[] { "string", "null" } 
                                                },
                                                
                                                imageUrl = new 
                                                { 
                                                    type = new[] { "string", "null" } 
                                                },
                                                
                                                externalUrl = new 
                                                { 
                                                    type = new[] { "string", "null" } 
                                                } 
                                            },
                                            
                                            required = new[] 
                                            { 
                                                "year", 
                                                "author", 
                                                "location", 
                                                "mapQuery", 
                                                "imageUrl", 
                                                "externalUrl" 
                                            },
                                            
                                            additionalProperties = false 
                                        } 
                                    },
                                    
                                    required = new[] 
                                    { 
                                        "type", 
                                        "title", 
                                        "description", 
                                        "sourceUrl", 
                                        "details" 
                                    }, 
                                    additionalProperties = false 
                                } 
                            }
                        },

                        required = new[]
                        {
                            "candidates"
                        },

                        additionalProperties = false
                    }
                }
            }
        });

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken
        );

        var responseBody = await response.Content.ReadAsStringAsync(
            cancellationToken
        );

        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException(
                $"OpenAI request failed: {(int)response.StatusCode} {responseBody}"
            );
        }

        using var document = JsonDocument.Parse(responseBody);

        var outputText = ExtractOutputText(document.RootElement);

        var result = JsonSerializer.Deserialize<AnalyzeResponse>(
            outputText,
            new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            }
        );

        return result?.Candidates
            ?? Array.Empty<ItemCandidateDto>();
    }

    private static string ExtractOutputText(JsonElement root)
    {
        foreach (var outputItem in root.GetProperty("output").EnumerateArray())
        {
            if (!outputItem.TryGetProperty("content", out var content))
            {
                continue;
            }

            foreach (var contentItem in content.EnumerateArray())
            {
                if (contentItem.TryGetProperty("type", out var type) &&
                    type.GetString() == "output_text" &&
                    contentItem.TryGetProperty("text", out var text))
                {
                    return text.GetString()
                        ?? throw new InvalidOperationException(
                            "OpenAI returned empty output.");
                }
            }
        }

        throw new InvalidOperationException(
            "OpenAI response did not contain output text.");
    }
}