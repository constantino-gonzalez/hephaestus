using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using model;

namespace cp.Controllers;

[Route("api/[controller]")]
[ApiController]
public class BotLogController : ControllerBase
{
    private readonly string _connectionString;
    private const string SecretKey = "YourSecretKeyHere"; // Secret key for hashing

    public BotLogController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("Default");
    }

    [HttpPost("upsert")]
    [Consumes("application/json")]
    [Produces("application/json")]
    public async Task<IActionResult> UpsertBotLog(
        [FromHeader(Name = "X-Signature")] string xSignature,
        [FromBody] BotLogRequest request)
    {
        // Serialize the request object to JSON
        var jsonOptions = new JsonSerializerOptions
        {
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false // Ensure compact JSON
        };

        string jsonBody = JsonSerializer.Serialize(request, jsonOptions);

        if (!ValidateHash(jsonBody, xSignature, SecretKey))
        {
            return Unauthorized("Invalid signature.");
        }

        string ipAddress = "unknown";
        try
        {
            ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        }
        catch (Exception e)
        {
            ipAddress = "unknown";
        }


        if (string.IsNullOrWhiteSpace(ipAddress))
        {
            return BadRequest("IP address not found.");
        }

        if (string.IsNullOrWhiteSpace(request.Server))
        {
            return BadRequest("Server address not found.");
        }

        try
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("dbo.UpsertBotLog", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@server", request.Server ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@ip", ipAddress);
                    command.Parameters.AddWithValue("@id", request.Id);
                    command.Parameters.AddWithValue("@serie", request.Serie ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@number", request.Number ?? (object)DBNull.Value);

                    await command.ExecuteNonQueryAsync();
                }
            }

            return Ok("{}");
        }
        catch (Exception ex)
        {
            // Log the exception (ex) here
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    private bool ValidateHash(string data, string hash, string key)
    {
        using (var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key)))
        {
            var computedHash = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(data)));
            // Debugging: Print the computed hash
            Console.WriteLine($"Computed hash on server: {computedHash}");
            return computedHash.Equals(hash);
        }
    }
}