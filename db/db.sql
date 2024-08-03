-- Drop the stored procedure if it exists
IF OBJECT_ID('dbo.UpsertBotLog', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.UpsertBotLog;
END
GO

IF OBJECT_ID('dbo.botLog', 'T') IS NULL
BEGIN
	DROP table dbo.botLog
END

-- Create the table if it does not exist
IF OBJECT_ID('dbo.botLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.botLog (
        id varchar(100) PRIMARY KEY,
        server VARCHAR(15),
        first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
        last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
        first_seen_ip VARCHAR(15),
        last_seen_ip VARCHAR(15),
        serie VARCHAR(100),
        number VARCHAR(100),
        number_of_requests INT DEFAULT 1
    );
END
GO

-- Create or alter the stored procedure
CREATE PROCEDURE dbo.UpsertBotLog
    @server VARCHAR(15),
    @ip VARCHAR(15),
    @id varchar(100),
    @serie VARCHAR(100) = NULL,     -- Optional parameter for serie
    @number VARCHAR(100) = NULL     -- Optional parameter for number
AS
BEGIN
    -- Use MERGE to handle insert or update
    MERGE dbo.botLog AS target
    USING (VALUES (@id, @server, @serie, @number, @ip, @ip)) 
           AS source (id, server, serie, number, first_seen_ip, last_seen_ip)
           ON target.id = source.id
    WHEN MATCHED THEN
        UPDATE SET 
            last_seen = CURRENT_TIMESTAMP,       -- Update last seen timestamp
            last_seen_ip = source.last_seen_ip,  -- Update last seen IP address
            number_of_requests = target.number_of_requests + 1  -- Increment number of requests
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id, server, first_seen, last_seen, first_seen_ip, last_seen_ip, serie, number, number_of_requests)
        VALUES (
            source.id,                         -- Use provided @id
            source.server,                     -- Server name or address
            CURRENT_TIMESTAMP,                 -- First seen timestamp
            CURRENT_TIMESTAMP,                 -- Last seen timestamp
            source.first_seen_ip,              -- First seen IP address
            source.last_seen_ip,               -- Last seen IP address
            source.serie,                      -- Serie (provided during insert)
            source.number,                     -- Number (provided during insert)
            1                                 -- Number of requests set to 1
        );
END
GO

-- -- Create indexes if not exists
-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.botLog') AND name = 'idx_server')
-- BEGIN
--     CREATE INDEX idx_server ON dbo.botLog (server);
-- END
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.botLog') AND name = 'idx_first_seen_ip')
-- BEGIN
--     CREATE INDEX idx_first_seen_ip ON dbo.botLog (first_seen_ip);
-- END
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.botLog') AND name = 'idx_last_seen_ip')
-- BEGIN
--     CREATE INDEX idx_last_seen_ip ON dbo.botLog (last_seen_ip);
-- END
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.botLog') AND name = 'idx_serie')
-- BEGIN
--     CREATE INDEX idx_serie ON dbo.botLog (serie);
-- END
-- GO

-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.botLog') AND name = 'idx_server_serie')
-- BEGIN
--     CREATE INDEX idx_server_serie ON dbo.botLog (server, serie);
-- END
-- GO

IF OBJECT_ID('dbo.DailyServerStatsView', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.DailyServerStatsView;
END
GO

-- Create the view
CREATE VIEW dbo.DailyServerStatsView AS
SELECT
    CAST(first_seen AS DATE) AS Date,
    server,
    COUNT(DISTINCT id) AS UniqueIDCount
FROM
    dbo.botLog
GROUP BY
    CAST(first_seen AS DATE),
    server;
GO

-- Drop the view if it exists
IF OBJECT_ID('dbo.DailyServerSerieStatsView', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.DailyServerSerieStatsView;
END
GO

-- Create the view
CREATE VIEW dbo.DailyServerSerieStatsView AS
SELECT
    CAST(first_seen AS DATE) AS Date,
    server,
    ISNULL(serie, 'not specified') AS Serie,
    COUNT(DISTINCT id) AS UniqueIDCount
FROM
    dbo.botLog
GROUP BY
    CAST(first_seen AS DATE),
    server,
    ISNULL(serie, 'not specified');
GO