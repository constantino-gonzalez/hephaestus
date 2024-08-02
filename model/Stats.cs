using System.Text.Json.Serialization;

namespace model;

public class DailyServerSerieStats
{
    public DateTime Date { get; set; }
    public string Server { get; set; }
    public string Serie { get; set; }
    public int UniqueIDCount { get; set; }
}

public class BotLogRequest
{
    [JsonPropertyName("id")]
    public string Id { get; set; }
    
    [JsonPropertyName("serie")]
    public string Serie { get; set; }
    
    [JsonPropertyName("number")]
    public string Number { get; set; }
}