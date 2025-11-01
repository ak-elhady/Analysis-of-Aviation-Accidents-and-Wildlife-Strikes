-- Data Modeling

-- Preparing and splitting the cleaned datasets into DIM and FACT tables for data modeling and normalization.


SELECT *
FROM NSTB;

SELECT *
FROM FAA;

-- Creating dim_date table with season and quarter columns
CREATE TABLE dim_date (
    Date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT,
    quarter INT,
    season VARCHAR(10)
);


-- Inserting distinct dates from both tables (faa & nstb)
INSERT INTO dim_date (full_date)
SELECT DISTINCT INCIDENT_DATE
FROM faa
UNION
SELECT DISTINCT Event_Date
FROM nstb;

-- Populating year, month, day, quarter, and season
UPDATE dim_date
SET 
    year = YEAR(full_date),
    month = MONTH(full_date),
    day = DAY(full_date),
    quarter = QUARTER(full_date),
    season = CASE
        WHEN MONTH(full_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(full_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(full_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(full_date) IN (9, 10, 11) THEN 'Fall'
        ELSE NULL
    END;
    
SELECT * FROM dim_date;

-- Creating dim_manufacturer table with unique manufacturer names and auto ID
CREATE TABLE dim_manufacturer AS
SELECT DISTINCT
   Make AS manufacturer_name
FROM dim_model;

-- Adding an auto-increment primary key
ALTER TABLE dim_manufacturer
ADD COLUMN manufacturer_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

SELECT * FROM dim_manufacturer;

-- Creating dim_airport_faa table with unique Airport IDs and names
CREATE TABLE dim_airport_faa AS
SELECT DISTINCT
   AIRPORT_ID AS airport_id,
    AIRPORT AS airport_name,
    geometry
FROM faa;

select * from dim_airport_faa;

-- Creating dim_operator_faa table with unique OPERATOR IDs and names
CREATE TABLE dim_operator_faa AS
SELECT DISTINCT
   OPID AS opid,
    OPERATOR AS operator
FROM faa;

select * from dim_operator_faa;


-- Creating dim_species_faa table with unique species IDs and names
CREATE TABLE dim_species_faa AS
SELECT DISTINCT
SPECIES_ID ,
    SPECIES ,SIZE
FROM faa;

select * from dim_species_faa;

-- creating table for Aircaft parts and strikes details from faa

 CREATE TABLE strikes_details AS
SELECT INDEX_NR, STR_RAD, DAM_RAD, STR_WINDSHLD,DAM_WINDSHLD,STR_NOSE,DAM_NOSE,STR_ENG1,DAM_ENG1
,ING_ENG1,STR_ENG2,DAM_ENG2,ING_ENG2,STR_ENG3,DAM_ENG3,ING_ENG3,STR_ENG4,DAM_ENG4
,ING_ENG4,STR_PROP,DAM_PROP,STR_WING_ROT,DAM_WING_ROT,STR_FUSE,DAM_FUSE,STR_LG,DAM_LG,
STR_TAIL,DAM_TAIL,STR_LGHTS,DAM_LGHTS,STR_OTHER,DAM_OTHER 
from faa;

select* from strikes_details; 

drop table strikes_details;
-- 🔄 Unpivot 32 columns into rows


CREATE TABLE unpivoted_strikes_details AS
SELECT INDEX_NR, 'STR_RAD' AS Part_Name, STR_RAD AS Value FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_RAD', DAM_RAD FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_WINDSHLD', STR_WINDSHLD FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_WINDSHLD', DAM_WINDSHLD FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_NOSE', STR_NOSE FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_NOSE', DAM_NOSE FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_ENG1', STR_ENG1 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_ENG1', DAM_ENG1 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'ING_ENG1', ING_ENG1 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_ENG2', STR_ENG2 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_ENG2', DAM_ENG2 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'ING_ENG2', ING_ENG2 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_ENG3', STR_ENG3 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_ENG3', DAM_ENG3 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'ING_ENG3', ING_ENG3 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_ENG4', STR_ENG4 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_ENG4', DAM_ENG4 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'ING_ENG4', ING_ENG4 FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_PROP', STR_PROP FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_PROP', DAM_PROP FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_WING_ROT', STR_WING_ROT FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_WING_ROT', DAM_WING_ROT FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_FUSE', STR_FUSE FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_FUSE', DAM_FUSE FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_LG', STR_LG FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_LG', DAM_LG FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_TAIL', STR_TAIL FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_TAIL', DAM_TAIL FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_LGHTS', STR_LGHTS FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_LGHTS', DAM_LGHTS FROM strikes_details
UNION ALL SELECT INDEX_NR, 'STR_OTHER', STR_OTHER FROM strikes_details
UNION ALL SELECT INDEX_NR, 'DAM_OTHER', DAM_OTHER FROM strikes_details;

select* from unpivoted_strikes_details; 

drop table strikes_details;

-- deleting unstriked records
Delete from unpivoted_strikes_details
where Value =0
; 

select * from unpivoted_strikes_details;

-- Creating Aircarft_parts table
CREATE TABLE Aircraft_parts AS
SELECT DISTINCT Part_Name
FROM unpivoted_strikes_details;

ALTER TABLE Aircraft_parts
ADD COLUMN Part_ID INT AUTO_INCREMENT PRIMARY KEY FIRST;

Select * from Aircraft_parts;

-- Joining Part_ID on unpivoted_strikes_details to convert it to Bridge table

SELECT 
    s.*, 
    p.Part_ID
FROM unpivoted_strikes_details s
LEFT JOIN Aircraft_parts p
  ON s.Part_Name = p.Part_Name;
  

ALTER TABLE unpivoted_strikes_details
ADD COLUMN Part_ID INT;


UPDATE unpivoted_strikes_details s
JOIN Aircraft_parts p
  ON s.Part_Name = p.Part_Name
SET s.Part_ID = p.Part_ID;

select * from unpivoted_strikes_details;

ALTER TABLE unpivoted_strikes_details
DROP COLUMN Part_Name,
DROP COLUMN Value;

RENAME TABLE unpivoted_strikes_details TO strike_details_bridge;

select * from strike_details_bridge;

-- Joining Dim tables IDs on Sub dim tables and Fact Tables
-- Frist Create table dim_country
CREATE TABLE dim_country AS
SELECT DISTINCT country
FROM dim_location ;

ALTER TABLE dim_country
ADD COLUMN country_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

SELECT * FROM dim_country;

-- Adding country_id in dim_location

SELECT 
    a.*, 
    b.country_id
FROM dim_location a
LEFT JOIN dim_country b
  ON a.country = b.country;
  
 
ALTER TABLE dim_location ADD COLUMN country_id INT;


UPDATE dim_location a
LEFT JOIN dim_country b
  ON a.country = b.country
SET a.country_id = b.country_id;

SELECT * FROM dim_location;

ALTER TABLE dim_location DROP COLUMN country ;

-- Adding Location_ID into nstb table
SELECT 
    a.*, 
    b.Location_ID
FROM nstb a
LEFT JOIN dim_location b
  ON a.geometry = b.geometry;
  
  ALTER TABLE nstb ADD COLUMN Location_ID INT;
  
 -- indexing for faster join.
CREATE INDEX idx_geometry_nstb ON nstb (geometry(100));
CREATE INDEX idx_geometry_dimloc ON dim_location (geometry(100));

 UPDATE nstb a
LEFT JOIN dim_location b
   ON a.geometry = b.geometry
SET a.Location_ID = b.Location_ID;

DROP INDEX idx_geometry_nstb ON nstb;
DROP INDEX idx_geometry_dimloc ON dim_location;
-- Adding Location_ID to dim_airport_faa

SELECT 
    a.*, 
    b.Location_ID
FROM dim_airport_faa a
LEFT JOIN dim_location b
  ON a.geometry = b.geometry;

 
 ALTER TABLE dim_airport_faa ADD COLUMN Location_ID INT;
 
UPDATE dim_airport_faa a
LEFT JOIN dim_location b
   ON a.geometry = b.geometry
SET a.Location_ID = b.Location_ID;

SELECT * FROM dim_airport_faa;

ALTER TABLE dim_airport_faa DROP COLUMN geometry;

-- Adding manufacturer_id to dim_model
SELECT 
    a.*, 
    b.manufacturer_id
FROM dim_model a
LEFT JOIN dim_manufacturer b
  ON a.Make = b.manufacturer_name;

ALTER TABLE dim_model ADD COLUMN manufacturer_id INT;


UPDATE dim_model a
LEFT JOIN dim_manufacturer b
 ON a.Make = b.manufacturer_name
SET a.manufacturer_id = b.manufacturer_id;

Select * from dim_model;

ALTER TABLE dim_model DROP COLUMN Make;

ALTER TABLE dim_model ADD COLUMN  model_id INT AUTO_INCREMENT PRIMARY KEY FIRST ;

-- Adding model_id to faa and nstb
-- frist creating indexes for fast join

CREATE INDEX idx_model_nstb ON nstb (Model(30));
CREATE INDEX idx_model_dimmod ON dim_model (Model(30));
CREATE INDEX idx_model_faa ON faa (AIRCRAFT(30));

-- Frist faa
SELECT 
    a.*, 
    b.model_id
FROM faa a
LEFT JOIN dim_model b
  ON a.AIRCRAFT = b.Model;

ALTER TABLE faa ADD COLUMN model_id INT;


UPDATE faa a
LEFT JOIN dim_model b
  ON a.AIRCRAFT = b.Model
SET a.model_id = b.model_id;

Select * from faa;

-- NSTB
SELECT 
    a.*, 
    b.model_id
FROM NSTB a
LEFT JOIN dim_model b
  ON a.Model = b.Model;

ALTER TABLE NSTB ADD COLUMN model_id INT;


UPDATE NSTB a
LEFT JOIN dim_model b
  ON a.Model = b.Model
SET a.model_id = b.model_id;

SELECT * FROM NSTB;
-- dropping indexes 
DROP INDEX idx_model_nstb ON nstb;
DROP INDEX idx_model_dimmod ON dim_model ;
DROP INDEX idx_model_faa ON faa ;


-- Creating Eng_pos Table
Create table Eng_pos as
SELECT  distinct ENG_1_POS,ENG_2_POS,ENG_3_POS,ENG_4_POS, AIRCRAFT
FROM FAA;

SELECT * FROM  Eng_pos;

SELECT 
    a.*, 
    b.model_id
FROM Eng_pos a
LEFT JOIN dim_model b
  ON a.AIRCRAFT = b.Model;

ALTER TABLE Eng_pos ADD COLUMN model_id INT;

UPDATE Eng_pos a
LEFT JOIN dim_model b
  ON a.AIRCRAFT = b.Model
SET a.model_id = b.model_id;

SELECT * FROM eng_pos;

ALTER TABLE Eng_pos DROP COLUMN AIRCRAFT;

-- unpivoting eng_pos to remove blanks and nulls
create table eng_pos_bridge as
SELECT model_id, 'ENG_1_POS' AS engine_pos, ENG_1_POS AS pos_id
FROM eng_pos
UNION ALL
SELECT model_id, 'ENG_2_POS', ENG_2_POS
FROM eng_pos
UNION ALL
SELECT model_id, 'ENG_3_POS', ENG_3_POS
FROM eng_pos
UNION ALL
SELECT model_id, 'ENG_4_POS', ENG_4_POS
FROM eng_pos;

select * from eng_pos_bridge;

DELETE FROM eng_pos_bridge
WHERE TRIM(pos_id) = '';
 
 ALTER TABLE eng_pos_bridge DROP COLUMN engine_pos;
 
 -- Reconstructuing eng_pos table
 
 DROP  TABLE eng_pos;

CREATE TABLE eng_pos AS
SELECT DISTINCT pos_id 
FROM eng_pos_bridge 
ORDER BY 1 ASC ;


SELECT 
pos_id,
    CASE pos_id
        WHEN 1 THEN 'Below Wing'
        WHEN 2 THEN 'Above Wing'
        WHEN 3 THEN 'Wing Root'
        WHEN 4 THEN 'On Wing (Nacelle)'
        WHEN 5 THEN 'Aft Fuselage'
        WHEN 6 THEN 'Empennage'
        WHEN 7 THEN 'Nose Intake'
	
    END AS position_name
FROM eng_pos;

ALTER TABLE eng_pos ADD COLUMN position_name VARCHAR(30);

UPDATE eng_pos
SET position_name = CASE pos_id
    WHEN 1 THEN 'Below Wing'
    WHEN 2 THEN 'Above Wing'
    WHEN 3 THEN 'Wing Root'
    WHEN 4 THEN 'On Wing (Nacelle)'
    WHEN 5 THEN 'Aft Fuselage'
    WHEN 6 THEN 'Empennage'
    WHEN 7 THEN 'Nose Intake'
END;

SELECT* FROM eng_pos;


-- Adding Date_id to faa & nstb;
-- faa
SELECT 
    a.*, 
    b.Date_id
FROM faa a
LEFT JOIN dim_date b
  ON a.INCIDENT_DATE = b.full_date;
  

ALTER TABLE faa ADD COLUMN date_id INT;

-- Indexing for fast join 
CREATE INDEX idx_date_dimdate ON dim_date (full_date(30));
CREATE INDEX idx_date_faa ON faa (INCIDENT_DATE(30));
CREATE INDEX idx_date_nstb ON nstb (Event_Date(30));

UPDATE faa  a
LEFT JOIN dim_date b
  ON a.INCIDENT_DATE = b.full_date
SET a.date_id = b.date_id;

-- nstb 

SELECT 
    a.*, 
    b.Date_id
FROM nstb a
LEFT JOIN dim_date b
  ON a.Event_Date = b.full_date;
  

ALTER TABLE nstb ADD COLUMN date_id INT;


UPDATE nstb a
LEFT JOIN dim_date b
  ON a.Event_Date = b.full_date
SET a.date_id = b.date_id;

select*from faa;
select*from nstb;

-- Dropping indexes
DROP INDEX idx_date_dimdate ON dim_date ;
DROP INDEX idx_date_faa ON faa ;
DROP INDEX idx_date_nstb ON nstb ;


-- Dropping dim columns from nstb and faa
ALTER TABLE nstb
DROP COLUMN Model,DROP COLUMN `geometry`,
DROP COLUMN Event_Date;

select * from nstb;


ALTER TABLE faa
DROP COLUMN INCIDENT_DATE,DROP COLUMN `geometry`,
DROP COLUMN INCIDENT_MONTH ,DROP COLUMN INCIDENT_YEAR
,DROP COLUMN AIRPORT, DROP COLUMN OPERATOR,DROP COLUMN AIRCRAFT,
DROP COLUMN TYPE_ENG ,DROP COLUMN NUM_ENGS ,DROP COLUMN ENG_1_POS  ,DROP COLUMN ENG_2_POS ,DROP COLUMN ENG_3_POS ,DROP COLUMN ENG_4_POS,
DROP COLUMN SPECIES,DROP COLUMN NUM_SEEN ,DROP COLUMN NUM_STRUCK ,DROP COLUMN SIZE,
DROP COLUMN STR_RAD,
DROP COLUMN DAM_RAD,
DROP COLUMN STR_WINDSHLD,
DROP COLUMN DAM_WINDSHLD,
DROP COLUMN STR_NOSE,
DROP COLUMN DAM_NOSE,
DROP COLUMN STR_ENG1,
DROP COLUMN DAM_ENG1,
DROP COLUMN ING_ENG1,
DROP COLUMN STR_ENG2,
DROP COLUMN DAM_ENG2,
DROP COLUMN ING_ENG2,
DROP COLUMN STR_ENG3,
DROP COLUMN DAM_ENG3,
DROP COLUMN ING_ENG3,
DROP COLUMN STR_ENG4,
DROP COLUMN DAM_ENG4,
DROP COLUMN ING_ENG4,
DROP COLUMN STR_PROP,
DROP COLUMN DAM_PROP,
DROP COLUMN STR_WING_ROT,
DROP COLUMN DAM_WING_ROT,
DROP COLUMN STR_FUSE,
DROP COLUMN DAM_FUSE,
DROP COLUMN STR_LG,
DROP COLUMN DAM_LG,
DROP COLUMN STR_TAIL,
DROP COLUMN DAM_TAIL,
DROP COLUMN STR_LGHTS,
DROP COLUMN DAM_LGHTS,
DROP COLUMN STR_OTHER,
DROP COLUMN DAM_OTHER;

SELECT * FROM FAA;