using System.DirectoryServices.AccountManagement;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;

namespace cp.Controllers;

 public class AuthController : Controller
    {
        // GET: /auth
        [AllowAnonymous]
        [HttpGet]
        [Route("auth")] // Exact route for login page
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
        [Route("auth/logout")]  // Exact route for logout action
        public async Task<IActionResult> Logout()
        {
            // Sign out the user and clear the session
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            return RedirectToAction("Index", "Auth"); // Redirect to login page
        }

        // Helper method to check user credentials
        private static bool IsValidUser(string username, string password)
        {
            try
            {
                // Create a PrincipalContext for the local machine
                using (var context = new PrincipalContext(ContextType.Machine))
                {
                    // Validate the credentials (username and password)
                    return context.ValidateCredentials(username, password);
                }
            }
            catch (Exception ex)
            {
                // Log or handle the exception as needed
                Console.WriteLine($"Error during user validation: {ex.Message}");
                return false;
            }
        }
    }