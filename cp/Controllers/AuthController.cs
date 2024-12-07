using System.Runtime.InteropServices;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.Extensions.Caching.Memory;
using model;

namespace cp.Controllers;

[Route("[controller]")]
public class AuthController : BaseController
{
    // GET: /auth
    public AuthController(ServerService serverService, IConfiguration configuration, IMemoryCache memoryCache) : base(
        serverService, configuration, memoryCache)
    {
    }

    [AllowAnonymous]
    [HttpGet]
    // Exact route for login page
    public IActionResult Index()
    {
        return View();
    }

    // POST: /auth/login
    [AllowAnonymous]
    [HttpPost]
    [Route("auth")] // Exact route for login action
    public IActionResult Login(string username, string password)
    {
        if (IsValidUser(username, password))
        {
            // Create a claims identity based on the username (and roles, if needed)
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, username),
                // Add roles and other claims if needed
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            // Sign in the user with the cookie
            HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, claimsPrincipal);

            HttpContext.User = claimsPrincipal;
            // Redirect to the home page or another page after successful login
            return RedirectToAction("Index", "Cp");
        }

        // If invalid login, return to the login page with an error message
        ViewData["LoginFailed"] = "Invalid username or password.";
        return View("Index");
    }

    // POST: /auth/logout
    [HttpPost]
    [Route("auth/logout")] // Exact route for logout action
    public async Task<IActionResult> Logout()
    {
        // Sign out the user and clear the session
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

        return RedirectToAction("Index", "Auth"); // Redirect to login page
    }

    // Import the LogonUser function from the advapi32.dll
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern bool LogonUser(
        string lpszUsername,
        string lpszDomain,
        string lpszPassword,
        int dwLogonType,
        int dwLogonProvider,
        out IntPtr phToken);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    private static extern bool CloseHandle(IntPtr handle);

    private const int LOGON32_LOGON_INTERACTIVE = 2;
    private const int LOGON32_PROVIDER_DEFAULT = 0;

    /// <summary>
    /// Checks if the provided Windows username and password are valid on this machine.
    /// </summary>
    /// <param name="username">The username to validate.</param>
    /// <param name="password">The password to validate.</param>
    /// <returns>True if the credentials are valid, otherwise false.</returns>
    private static bool IsValidUser(string username, string password)
    {
        IntPtr userToken = IntPtr.Zero;

        try
        {
            // Attempt to log on with the provided credentials
            bool isSuccess = LogonUser(
                username,
                ".", // Use "." for the local machine
                password,
                LOGON32_LOGON_INTERACTIVE,
                LOGON32_PROVIDER_DEFAULT,
                out userToken);

            return isSuccess;
        }
        catch (Exception)
        {
            return false;
        }
        finally
        {
            // Close the token handle if it was successfully created
            if (userToken != IntPtr.Zero)
            {
                CloseHandle(userToken);
            }
        }
    }
}