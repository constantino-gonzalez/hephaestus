using System.Text.Json.Serialization;

namespace model;

public class DailyServerSerieStats
{
    public DateTime Date { get; set; }
    public string Server { get; set; }
    public string Serie { get; set; }
    public int UniqueIDCount { get; set; }
    
    public int ElevatedUniqueIDCount { get; set; }
}


public class DailyServerClickLog
{
    public string Id { get; set; }
    public string Server { get; set; }
    public DateTime LastSeen { get; set; }
    public string LastSeenIp { get; set; }
    public DateTime FirstSeen { get; set; }
    public string FirstSeenIp { get; set; }
    public string Serie { get; set; }
    public string Number { get; set; }
    public int NumberOfRequests { get; set; }
    
    public int NumberOfElevatedRequests { get; set; }
}

public class BotLogRequest
{
    [JsonPropertyName("id")]
    public string Id { get; set; }
    
    [JsonPropertyName("serie")]
    public string Serie { get; set; }
    
    [JsonPropertyName("number")]
    public string Number { get; set; }
    
    [JsonPropertyName("elevated_number")]
    public int ElevatedNumber { get; set; }
}