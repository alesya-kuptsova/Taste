namespace Taste.Api.Services;

public interface ILinkContentExtractor
{
    Task<string> ExtractAsync(
        Uri url,
        CancellationToken cancellationToken = default
    );
}