using Taste.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.AddHttpClient<IContentAnalyzer, OpenAIContentAnalyzer>();
builder.Services.AddHttpClient<ILinkContentExtractor, LinkContentExtractor>();
builder.Services.AddHttpClient<IUrlContentResolver, UrlContentResolver>();
builder.Services.AddHttpClient<IPlaceResolver, NominatimPlaceResolver>(client =>
{
    client.BaseAddress = new Uri("https://nominatim.openstreetmap.org/");
    client.DefaultRequestHeaders.UserAgent.ParseAdd(
        "Taste/1.0 (personal wishlist app)"
    );
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
