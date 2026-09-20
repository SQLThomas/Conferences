-- ©2026 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

USE APIDemo;
GO

-- Preparations
SELECT name, value, value_in_use, description 
FROM sys.configurations 
WHERE name LIKE '%rest%';

EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;

EXEC sp_configure 'external rest endpoint enabled';

GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [guest];

SELECT p.class_desc, p.grantee_principal_id, u.name, p.permission_name, p.state_desc FROM sys.database_permissions p
LEFT JOIN sysusers u ON u.UID = p.grantee_principal_id
WHERE Type = 'EAEE';

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword!2026';
GO


--- 01_VAT ID
-- VAT status codes
DECLARE @Response0 NVARCHAR(MAX);

BEGIN TRY
    EXEC sp_invoke_external_rest_endpoint
        @url = 'https://api.evatr.vies.bzst.de/v1/info/statusmeldungen',
        @headers = '{ "Accept": "application/json" }',
        @method = 'GET',
        @response = @Response0 OUTPUT;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProc;
END CATCH;

SELECT JSON_VALUE(@Response0, '$.response.status.http.code') AS [HttpCode], JSON_VALUE(@Response0, '$.response.status.http.description') AS [Description]

SELECT @Response0 AS [Response as Text];

DROP TABLE IF EXISTS dbo.VATStatusCodes;

CREATE TABLE dbo.VATStatusCodes
(
    [status] VARCHAR(10) NOT NULL,
    kategorie VARCHAR(20),
    httpcode INT,
    feld VARCHAR(50),
    meldung varchar(250),
    CONSTRAINT PK_VATStatusCodes PRIMARY KEY CLUSTERED([status])
);

INSERT INTO dbo.VATStatusCodes
SELECT * FROM OPENJSON(@Response0, '$.result')
WITH ([status] VARCHAR(10), kategorie VARCHAR(20), httpcode INT, feld VARCHAR(50), meldung varchar(250)) as VATStatusCodes;

SELECT * FROM dbo.VATStatusCodes;


-- Check VAT ID
DECLARE @ReturnValue INT, @Response1 NVARCHAR(MAX);

EXEC @ReturnValue = sp_invoke_external_rest_endpoint
    @url = 'https://api.evatr.vies.bzst.de/app/v1/abfragen',  -- abfrage?
    @payload = '{ "anfragendeUstid": "DE129415943", "angefragteUstid": "ESB78603495" }',
    @headers = '{ "Accept": "application/json" }',
    @method = 'POST',
    @response = @Response1 OUTPUT;

SELECT @ReturnValue AS [ReturnValue];
SELECT JSON_VALUE(@Response1, '$.response.status.http.code') AS [HttpCode], JSON_VALUE(@Response1, '$.response.status.http.description') AS [Description]
SELECT * FROM dbo.HttpStatusCodes WHERE HttpCode = CAST(@ReturnValue AS VARCHAR)

SELECT @Response1 AS [Response as Text];

SELECT meldung FROM dbo.VATStatusCodes
WHERE [status] = JSON_VALUE(@Response1, '$.result.status')


-- Mock with Beeceptor
DECLARE @ResponseMock NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://derfredo-fabcon.free.beeceptor.com/app/v1/abfrage',
    @payload = '{ "anfragendeUstid": "DE129415943", "angefragteUstid": "ESB78603495" }',
    @headers = '{ "Accept": "application/json" }',
    @method = 'POST',
    @response = @ResponseMock OUTPUT;

SELECT JSON_VALUE(@ResponseMock, '$.response.status.http.code') AS [HttpCode], JSON_VALUE(@ResponseMock, '$.response.status.http.description') AS [Description]

SELECT @ResponseMock AS [Response as Text];



--- 02_Finance
--Country information
DECLARE @Response2co NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.vatcomply.com/countries?search=Spain',
--    @url = 'https://api.vatcomply.com/countries?region=Europe',
    @method = 'GET',
    @response = @Response2co OUTPUT;

SELECT JSON_QUERY(@Response2co, '$.result') AS [Result as Text];


-- Currencies information/list
DECLARE @Response2cu NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
--    @url = 'https://api.vatcomply.com/currencies?search=EUR',
    @url = 'https://api.vatcomply.com/currencies',
    @method = 'GET',
    @response = @Response2cu OUTPUT;

SELECT JSON_QUERY(@Response2cu, '$.result') AS [Result as Text];

DROP TABLE IF EXISTS Currencies;

SELECT
    JSON_VALUE(value, '$.symbol') Symbol,
    JSON_VALUE(value, '$.name') Name,
    CAST(0.0 AS numeric(12,6)) AS Rate
INTO Currencies
FROM OPENJSON(@Response2cu, '$.result')

SELECT *
FROM Currencies


-- Currency exchange rates
DECLARE @Response2ex NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.vatcomply.com/rates?base=EUR',
    @method = 'GET',
    @response = @Response2ex OUTPUT;

SELECT JSON_QUERY(@Response2ex, '$.result') AS [Result as Text];

SELECT *
FROM OPENJSON(@Response2ex, '$.result.rates') 

UPDATE Curr
   SET Rate = CAST([value] AS numeric(12,6))
FROM Currencies Curr 
JOIN OPENJSON(@Response2ex, '$.result.rates') Rates
  ON Rates.[key] = Curr.Symbol COLLATE Latin1_General_BIN2

SELECT *
FROM Currencies


-- IBAN validation
DECLARE @Response2ib NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.vatcomply.com/iban?iban=GB33BUKB20201555555555',
--    @url = 'https://api.vatcomply.com/iban?iban=GB2LABBY09012857201707',
    @method = 'GET',
    @response = @Response2ib OUTPUT;

IF JSON_VALUE(@Response2ib, '$.response.status.http.code') = 200
    SELECT 'Account valid at ' + JSON_VALUE(@Response2ib, '$.result.bank_name') + ' in ' + JSON_VALUE(@Response2ib, '$.result.country_code') AS [Response as Text]
ELSE
    SELECT JSON_VALUE(@Response2ib, '$.result.detail') AS [Response as Text]


-- VAT ID validation
DECLARE @Response2va AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.vatcomply.com/vat?vat_number=NL007747366B01',
    @method = 'GET',
    @response = @Response2va OUTPUT;

SELECT JSON_QUERY(@Response2va, '$.result') AS [Result as Text];


-- VAT rates
DECLARE @Response2vr AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.vatcomply.com/vat_rates?country_code=DE',
    @method = 'GET',
    @response = @Response2vr OUTPUT;

SELECT JSON_QUERY(@Response2vr, '$.result') AS [Result as Text];



--- 03_Gas prices
-- Gas prices position
DECLARE @Response3pos AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://creativecommons.tankerkoenig.de/json/list.php?lat=51.288920&lng=6.196329&rad=3&sort=dist&type=all',
    @method = 'GET',
    @credential = 'https://creativecommons.tankerkoenig.de',
    @response = @Response3pos OUTPUT;

SELECT JSON_QUERY(@Response3pos, '$.result') AS [Result as Text];


-- Gas prices one station
DECLARE @Response3one AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://creativecommons.tankerkoenig.de/json/prices.php?ids=f580dd50-7f3d-494a-9c03-239804d4115c',
    @method = 'GET',
    @credential = 'https://creativecommons.tankerkoenig.de',
    @response = @Response3one OUTPUT;

SELECT JSON_QUERY(@Response3one, '$.result') AS [Result as Text];


-- Gas station details
DECLARE @Response3det AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://creativecommons.tankerkoenig.de/json/detail.php?id=f580dd50-7f3d-494a-9c03-239804d4115c',
    @method = 'GET',
    @credential = 'https://creativecommons.tankerkoenig.de',
    @response = @Response3det OUTPUT;

SELECT JSON_QUERY(@Response3det, '$.result') AS [Result as Text];



--- 04_Geoinformation
-- Geocode DE
DECLARE @Response4de AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/geocode/search?text=Alois-Schießl-Platz 1, 85435 Erding',
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4de OUTPUT;

SELECT JSON_QUERY(@Response4de, '$.result') AS [Result as Text];

SELECT JSON_VALUE(@Response4de, '$.result.features[0].properties.lat') AS [Lat], JSON_VALUE(@Response4de, '$.result.features[0].properties.lon') AS [Lon];


-- Geocode batch DE
DECLARE @Response4gbde AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/batch/geocode/search',
    @method = 'POST',
    @payload = '["Stadthalle Erding", "Flughafen München", "Erdinger Brauerei, Erding"]',
    @credential = 'https://api.geoapify.com',
    @response = @Response4gbde OUTPUT;

SELECT JSON_QUERY(@Response4gbde, '$.result') AS [Result as Text];

SELECT JSON_VALUE(@Response4gbde, '$.result.id') AS [Batch job id];


-- Geocode collect DE
DECLARE @Response4gcde AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/batch/geocode/search?format=json&id=124492fb560a46a695d04a739a806ce9',
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4gcde OUTPUT;

SELECT JSON_QUERY(@Response4gcde, '$.result') AS [Result as Text];

IF (JSON_PATH_EXISTS(@Response4gcde, '$.result[0].lon') = 1) BEGIN
    SELECT lat, lon FROM OPENJSON(JSON_QUERY(@Response4gcde, '$.result')) WITH(lon VARCHAR(20), lat VARCHAR(20));

    WITH CTE AS (SELECT lat + ',' + lon AS Coord FROM OPENJSON(JSON_QUERY(@Response4gcde, '$.result')) WITH(lon VARCHAR(20), lat VARCHAR(20)))
    SELECT STRING_AGG(Coord, '|') AS CoordList FROM CTE;
END ELSE BEGIN
    SELECT 'Be patient!' AS [Please]
END;


-- Routing DE
DECLARE @Response4rode AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/routing?mode=drive&type=short&waypoints=48.3081554,11.9051135|48.3539625,11.7785925|48.3153275,11.8913876',
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4rode OUTPUT;

SELECT JSON_QUERY(@Response4rode, '$.result') AS [Result as Text];

SELECT JSON_QUERY(@Response4rode, '$.result.properties.waypoints[*]') AS [Some route];


-- Route planner DE
DECLARE @Response4rpde AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/routeplanner',
    @method = 'POST',
    @payload = '{"mode":"drive","agents":[{"start_location":[11.9051135,48.3081554]}],"jobs":[{"location":[11.7785925,48.3539625]},{"location":[11.8913876,48.3153275]}]}',
    @credential = 'https://api.geoapify.com',
    @response = @Response4rpde OUTPUT;

SELECT JSON_QUERY(@Response4rpde, '$.result') AS [Result as Text];

SELECT JSON_QUERY(@Response4rpde, '$.result.features[0].properties.waypoints[*].location') AS [Optimal route];


-- Geocode ES
DECLARE @Response4es AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/geocode/search?text=Plaça de Willy Brandt, 11-14, 08019 Barcelona',
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4es OUTPUT;

SELECT JSON_QUERY(@Response4es, '$.result') AS [Result as Text];

SELECT JSON_VALUE(@Response4es, '$.result.features[0].properties.lat') AS [Lat], JSON_VALUE(@Response4es, '$.result.features[0].properties.lon') AS [Lon];


-- Geocode batch ES
DECLARE @Response4gbes AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/batch/geocode/search',
    @method = 'POST',
    @payload = '["CCIB Barcelona", "Barcelona El Prat Airport", "Plaça Catalunya, Barcelona"]',
    @credential = 'https://api.geoapify.com',
    @response = @Response4gbes OUTPUT;

SELECT JSON_QUERY(@Response4gbes, '$.result') AS [Result as Text];

SELECT JSON_VALUE(@Response4gbes, '$.result.id') AS [Batch job id];


-- Geocode collect ES
DECLARE @Response4gces AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/batch/geocode/search?format=json&id=9e3a6321a71046a8aff72893cdd823e4',  --  enter new id
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4gces OUTPUT;

SELECT JSON_QUERY(@Response4gces, '$.result') AS [Result as Text];

IF (JSON_PATH_EXISTS(@Response4gces, '$.result[0].lon') = 1) BEGIN
    SELECT lat, lon FROM OPENJSON(JSON_QUERY(@Response4gces, '$.result')) WITH(lon VARCHAR(20), lat VARCHAR(20));

    WITH CTE AS (SELECT lat + ',' + lon AS Coord FROM OPENJSON(JSON_QUERY(@Response4gces, '$.result')) WITH(lon VARCHAR(20), lat VARCHAR(20)))
    SELECT STRING_AGG(Coord, '|') AS CoordList FROM CTE;
END ELSE BEGIN
    SELECT 'Be patient!' AS [Please]
END;


-- Routing ES
DECLARE @Response4roes AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/routing?mode=drive&type=short&waypoints=41.4094939,2.2192968|41.2889548,2.0746657|41.386865,2.171493',
    @method = 'GET',
    @credential = 'https://api.geoapify.com',
    @response = @Response4roes OUTPUT;

SELECT JSON_QUERY(@Response4roes, '$.result') AS [Result as Text];

SELECT JSON_QUERY(@Response4roes, '$.result.properties.waypoints[*]') AS [Some route];


-- Route planner ES
DECLARE @Response4rpes AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.geoapify.com/v1/routeplanner',
    @method = 'POST',
    @payload = '{"mode":"drive","agents":[{"start_location":[2.2192968,41.4094939]}],"jobs":[{"location":[2.0746657,41.2889548]},{"location":[2.171493,41.386865]}]}',
    @credential = 'https://api.geoapify.com',
    @response = @Response4rpes OUTPUT;

SELECT JSON_QUERY(@Response4rpes, '$.result') AS [Result as Text];

SELECT JSON_QUERY(@Response4rpes, '$.result.features[0].properties.waypoints[*].location') AS [Optimal route];



--- 98_ISS position
-- Where the ISS at?
DECLARE @Response98i AS NVARCHAR (MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = N'https://api.wheretheiss.at/v1/satellites/25544',
    @method = 'GET',
    @response = @Response98i OUTPUT;

SELECT JSON_QUERY(@Response98i, '$.result') AS [Result as Text];

SELECT 'Right now (Unix timestamp ' + JSON_VALUE(@Response98i, '$.result.timestamp') + '), the ISS is cruising over: Lat ' +
  JSON_VALUE(@Response98i, '$.result.latitude') + ', Lon ' + JSON_VALUE(@Response98i, '$.result.longitude') AS [ISS position];



---  99_Breweries
-- List all breweries
DECLARE @Response99a NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.openbrewerydb.org/v1/breweries',
    @method = 'GET',
    @response = @Response99a OUTPUT;

SELECT JSON_QUERY(@Response99a, '$.result') AS [Result as Text];


-- Breweries by city
DECLARE @Response99c NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.openbrewerydb.org/v1/breweries?by_city=Hamburg',
    @method = 'GET',
    @response = @Response99c OUTPUT;

SELECT JSON_QUERY(@Response99c, '$.result') AS [Result as Text];


-- Breweries around a point
DECLARE @Response99p NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.openbrewerydb.org/v1/breweries?by_dist=51.290366, 6.839567&per_page=10',
    @method = 'GET',
    @response = @Response99p OUTPUT;

SELECT JSON_QUERY(@Response99p, '$.result') AS [Result as Text];


-- One brewery
DECLARE @Response99o NVARCHAR(MAX);

EXEC sp_invoke_external_rest_endpoint
    @url = 'https://api.openbrewerydb.org/v1/breweries/195c8caa-95d8-4fd3-b090-880af6788b8d',
    @method = 'GET',
    @response = @Response99o OUTPUT;

SELECT JSON_QUERY(@Response99o, '$.result') AS [Result as Text];
