-- SpatialDemo.sql
-- Demo of geospatial data types in SQL Server
-- ©2019 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

USE Spatial1;

-- Prepare our playground table
/*
DROP TABLE IF EXISTS Playground;
CREATE TABLE [dbo].[Playground](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[descriptor] [nvarchar](50) NULL,
	[geom] [geometry] NULL,
	[geog] [geography] NULL,
	PRIMARY KEY CLUSTERED ([id] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO
*/

-- Insert some simple geoms
/*
INSERT INTO Playground(descriptor, geom) VALUES 
	('point', geometry::STPointFromText('POINT (30 10)', 0)),
	('linestring', geometry::STLineFromText('LINESTRING (80 10, 60 30, 90 40)', 0)),
	('polygon1', geometry::STPolyFromText('POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))', 0)),
	('polygon2', geometry::STPolyFromText('POLYGON ((80 10, 90 40, 70 40, 60 20, 80 10))', 0)),
	('mpoint', geometry::STMPointFromText('MULTIPOINT (10 40, 40 30, 20 20, 40 10)', 0)),
	('mlinestring', geometry::STMLineFromText('MULTILINESTRING ((10 10, 20 20, 10 40), (40 40, 30 30, 40 20, 30 10))', 0)),
	('mpolygon1', geometry::STMPolyFromText('MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)), ((15 5, 40 10, 10 20, 5 10, 15 5)))', 0)),
	('mpolygon2', geometry::STMPolyFromText('MULTIPOLYGON (((90 40, 70 45, 95 30, 90 40)),
		((70 35, 60 30, 60 10, 80 5, 95 20, 70 35),(80 20, 70 15, 70 25, 80 20)))', 0))
INSERT INTO Playground(descriptor, geog) VALUES 
	('clockline', geography::STLineFromText('LINESTRING (10 10, 40 10, 40 20, 10 20, 10 10)', 4326)),
	('clockleft', geography::STPolyFromText(  'POLYGON ((10 10, 40 10, 40 20, 10 20, 10 10))', 4326)),
	('clockright', geography::STPolyFromText( 'POLYGON ((10 10, 10 20, 40 20, 40 10, 10 10))', 4326))
*/


-- Inspect our data
SELECT id, descriptor, geom, geom.STAsBinary() AS AsWKB, geom.STAsText() AS AsWKT FROM Playground WHERE id <= 8

SELECT id, descriptor, geog, geog.STAsBinary() AS AsWKB, geog.STAsText() AS AsWKT FROM Playground WHERE id > 8


SELECT id, descriptor, geom FROM Playground WHERE descriptor IN ('point', 'mpoint')

SELECT id, descriptor, geom.BufferWithCurves(0.3) AS geom FROM Playground WHERE descriptor IN ('point', 'mpoint')

SELECT id, descriptor, geom.BufferWithCurves(0.1) AS geom FROM Playground WHERE descriptor IN ('linestring', 'mlinestring')

SELECT id, descriptor, geom FROM Playground WHERE descriptor IN ('polygon1', 'polygon2')

SELECT id, descriptor, geom FROM Playground WHERE descriptor IN ('mpolygon1', 'mpolygon2')

-- Line vs polygon left-foot vs right-foot
SELECT id, descriptor, geog, geog.STAsText() AS AsWKT FROM Playground WHERE descriptor = 'clockline'

SELECT id, descriptor, geog, geog.STAsText() AS AsWKT FROM Playground WHERE descriptor = 'clockleft'

SELECT id, descriptor, geog, geog.STAsText() AS AsWKT FROM Playground WHERE descriptor = 'clockright'


-- Properties
SELECT id, descriptor, geom.STDimension() AS Dim, geom.STGeometryType() AS GeomType, geom.STIsSimple() AS IsSimple,
	geom.STIsClosed() AS IsClosed, geom.STIsRing() AS IsRing FROM Playground WHERE id <= 8
SELECT id, descriptor, geog.STDimension() AS Dim, geog.STGeometryType() AS GeomType,
	geog.STIsClosed() AS IsClosed, geog.NumRings() AS NumRings FROM Playground WHERE id > 8

SELECT id, descriptor, geom.STNumPoints() AS NumPoints, geom.STIsEmpty() AS IsEmpty, geom.STNumGeometries() AS NumGeoms,
	geom.STPointOnSurface().STAsText() AS APoint FROM Playground WHERE id <= 8
SELECT id, descriptor, geog.STNumPoints() AS NumPoints, geog.STIsEmpty() AS IsEmpty, geog.STNumGeometries() AS NumGeoms
	FROM Playground WHERE id > 8


-- Functions
SELECT id, descriptor, geom FROM Playground WHERE descriptor = 'polygon2'
UNION ALL
SELECT id, 'centroid' AS descriptor, geom.STCentroid().STBuffer(0.3) AS geom FROM Playground WHERE descriptor = 'polygon2'

SELECT id, descriptor, geom FROM Playground WHERE descriptor = 'mlinestring'
UNION ALL
SELECT id, 'boundary' AS descriptor, geom.STBoundary().STBuffer(0.3) AS geom FROM Playground WHERE descriptor = 'mlinestring'

SELECT id, descriptor, geom FROM Playground WHERE descriptor = 'mpolygon1'
UNION ALL
SELECT id, 'envelope' AS descriptor, geom.STEnvelope() AS geom FROM Playground WHERE descriptor = 'mpolygon1'

SELECT id, descriptor, geom FROM Playground WHERE descriptor = 'mpolygon1'
UNION ALL
SELECT id, 'convexhull' AS descriptor, geom.STConvexHull() AS geom FROM Playground WHERE descriptor = 'mpolygon1'


-- Up to some geographic shapes
SELECT id, GEN, geom FROM _sta

SELECT id, GEN, geom FROM _bld

SELECT id, GEN, geom FROM _bld WHERE GEN = 'Brandenburg'

SELECT id, GEN, geom FROM _rbz
UNION ALL
SELECT id, GEN, geom FROM _sta where id = 2

SELECT id, GEN, geom FROM _krs

SELECT id, GEN, geom FROM _krs where GEN = 'Rhein-Sieg-Kreis'
UNION ALL
SELECT id, GEN, geom FROM _bld where GEN = 'Nordrhein-Westfalen'
UNION ALL
SELECT id, GEN, geom FROM _sta where id = 2


-- Applications
DECLARE @bw geography
SELECT @bw = geom FROM _bld WHERE GEN = 'Baden-Württemberg'
SELECT id, 'Neu-Bayern' AS GEN, geom.STUnion(@bw) AS geom FROM _bld WHERE GEN = 'Bayern'
UNION ALL
SELECT id, GEN, geom FROM _sta where id = 2


-- PASS Germany regional chapters
SELECT GEN, geom FROM _sta where id = 2
UNION ALL
SELECT RG, geom.BufferWithCurves(5000) AS geom FROM pass_de

SELECT GEN, geom FROM _sta where id = 2
UNION ALL
SELECT RG, geom.BufferWithCurves(60000) AS geom FROM pass_de

DECLARE @pass_geom geography
SELECT @pass_geom = geography::UnionAggregate(geom.BufferWithCurves(60000)) FROM pass_de
SELECT geom.STDifference(@pass_geom) AS geom FROM _sta where id = 2


-- Shortes distance
DECLARE @l geography, @m geography, @n geography
SELECT @m = geom FROM pass_de WHERE RG = 'Bayern'
SELECT @n = geom FROM pass_de WHERE RG = 'Franken'
SELECT @l = @m.ShortestLineTo(@n)
SELECT @m.STDistance(@n) / 1000 AS "Dist (km)"

SELECT GEN, geom FROM _bld WHERE GEN = 'Bayern'
UNION ALL
SELECT 'line', @l

UNION ALL
SELECT GEN, geom FROM _krs WHERE geom.STIntersects(@l) = 1


-- Show neighbouring districts
DECLARE @e geography
SELECT @e = geom FROM _krs WHERE GEN = 'Mülheim an der Ruhr'
SELECT id, GEN, geom FROM _bld WHERE GEN = 'Nordrhein-Westfalen'
UNION ALL
SELECT id, GEN, geom FROM _krs
WHERE (geom.STIntersects(@e) = 1)
