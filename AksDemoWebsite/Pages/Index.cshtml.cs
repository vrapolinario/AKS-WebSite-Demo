using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace AksDemoWebsite.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    public int SessionCount { get; private set; }

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public void OnGet()
    {
        var sessionCountStr = Environment.GetEnvironmentVariable("SESSION_COUNT");
        SessionCount = int.TryParse(sessionCountStr, out var count) ? count : 0;
    }
}
