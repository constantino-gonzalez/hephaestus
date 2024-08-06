namespace Refiner;

using System;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

public abstract class BaseApi
{
    private readonly string _apiUrl;
    private readonly string _apiKey;

    protected BaseApi(string apiUrl, string apiKey)
    {
        _apiUrl = apiUrl;
        _apiKey = apiKey;
    }

    protected async Task<string> PostAsync(string action, object data)
    {
        using (var client = new HttpClient())
        {
            var postData = new
            {
                api_key = _apiKey,
                action = action,
                data = data
            };

            var json = JsonConvert.SerializeObject(postData);
            var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

            var response = await client.PostAsync(_apiUrl, content);
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsStringAsync();
        }
    }
}

public class ApiClient : BaseApi
{
    public ApiClient(string apiUrl, string apiKey) : base(apiUrl, apiKey)
    {
    }

    public async Task<string> GetBalanceAsync()
    {
        return await PostAsync("get_balance", null);
    }
}
