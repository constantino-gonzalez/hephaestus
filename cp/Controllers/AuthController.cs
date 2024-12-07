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
    public IActionResult Login(string username, string password)
    {
        if (RemoteAuthentication.IsValidUser(username, password, Server, out var msg))
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
        ViewData["LoginFailed"] = msg;
        return View("Index");
    }

    // POST: /auth/logout
    [HttpPost]
    [Route("logout")] // Exact route for logout action
    public async Task<IActionResult> Logout()
    {
        // Sign out the user and clear the session
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

        return RedirectToAction("Index", "Auth"); // Redirect to login page
    }
}