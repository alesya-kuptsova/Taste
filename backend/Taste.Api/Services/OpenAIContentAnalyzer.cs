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
            tools = new[]
            {
                new { type = "web_search" }
            },

            tool_choice = "auto",

            instructions = @"
You analyze things a user wants to save to a personal wishlist.

    Your goal is to identify the actual object the user wants to save,
    not necessarily the webpage, advertisement, or video they shared.

    Allowed item types:
    movie, book, game, music, place, product, freeform.

    Rules:

    1. Identify the user's intent.

    A URL may point to a video, advertisement, product page,
    social media post, or another source of information.

    Analyze its available title, description, and other provided
    metadata to identify what the user actually wants to save.

    Do not automatically treat the source itself as the wishlist item.

    2. Identify catalog items.

    If the content mentions a specific movie, book, game,
    music track, place, or product, identify that item.

    If the item is not explicitly named, use the available
    description and context to identify plausible candidates.

    For example:
    - A movie clip may describe a scene without naming the movie.
    - An advertisement may show a product without mentioning its brand.
    - A travel video may describe a place without giving its name.

    3. Movie identification.

    If the input describes a movie scene or plot,
    attempt to identify the movie from the available information.

    Do not use the title of a video clip as the movie title
    unless it is actually the title of the movie.

    If several movies plausibly match the description,
    return multiple candidates.

    Do not invent a movie title, release year, or other details.

    4. Products.

    If the content describes a product, identify the product
    rather than the advertisement or webpage.

    A product does not need to have a specific brand,
    model, or store to be a valid wishlist item.

    For example, a user may want a particular type of lamp,
    keyboard, or piece of furniture without knowing its brand.

    5. Places.

    If the content describes a restaurant, landmark,
    city, or another place, identify the place when possible.

    Do not invent a specific location if the available
    information is insufficient.

    6. Uncertainty.

    Return only candidates supported by the available information.

    If the input is ambiguous, return multiple plausible candidates.

    Use freeform when the desired item cannot be reliably identified
    or does not fit another category.

    Do not invent details you are not reasonably confident about.

    Return no more than 5 candidates.

    7. Web search.

    - When the input contains an explicit, identifiable item,
      use the available information to identify it.

    - When an item is not explicitly named, use web search
      to identify plausible matches from the description.

    - For movie clips, search for the original movie,
      not the title of the uploaded video.

    - For products, places, books, games, and music,
      search for the actual object the user wants to save.

    - Compare search results with the provided description.
      Do not assume that the first search result is correct.

    - If several candidates plausibly match,
      return multiple candidates for user confirmation.

    - If no reliable match is found, use freeform.",

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