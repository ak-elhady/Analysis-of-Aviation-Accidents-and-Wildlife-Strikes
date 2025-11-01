CREATE DATABASE final_project;

-- Importing data
SELECT *
FROM FAA;

SELECT * 
FROM NSTB; 

LOAD DATA LOCAL INFILE 'C:/Users/Akram/Desktop/NTSB_with_causes .csv'
INTO TABLE NSTB
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Akram/Desktop/Public.csv'
INTO TABLE FAA
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

-- Data cleaning and preprocessing  for FAA  dataset

-- Checking Imported Data file
SELECT count(*)  
AS Total_records FROM FAA ;

SELECT * FROM FAA
LIMIT 100;

-- Checking Duplicates.
SELECT INDEX_NR, COUNT(*) AS duplicate_count
FROM FAA
GROUP BY INDEX_NR
HAVING COUNT(*) > 1;
-- No duplicated records were found.

-- Removing records which aren't related to airplanes
DELETE FROM FAA
WHERE AC_CLASS IS NULL
   OR TRIM(AC_CLASS) = ''
   OR UPPER(TRIM(AC_CLASS)) <> 'A';
   
  -- Dropping unnecessary columns
ALTER TABLE FAA
DROP COLUMN RUNWAY,
DROP COLUMN FAAREGION,
DROP COLUMN LOCATION,
DROP COLUMN REG,
DROP COLUMN FLT,
DROP COLUMN AMA,
DROP COLUMN AMO,
DROP COLUMN EMA,
DROP COLUMN EMO,
DROP COLUMN AC_CLASS,
DROP COLUMN AC_MASS,
DROP COLUMN SKY,
DROP COLUMN PRECIPITATION,
DROP COLUMN AOS,
DROP COLUMN COST_REPAIRS,
DROP COLUMN COST_OTHER,
DROP COLUMN COST_REPAIRS_INFL_ADJ,
DROP COLUMN COST_OTHER_INFL_ADJ,
DROP COLUMN OTHER_SPECIFY,
DROP COLUMN EFFECT,
DROP COLUMN EFFECT_OTHER,
DROP COLUMN BIRD_BAND_NUMBER,
DROP COLUMN REMARKS,
DROP COLUMN OUT_OF_RANGE_SPECIES,
DROP COLUMN REMAINS_COLLECTED,
DROP COLUMN REMAINS_SENT,
DROP COLUMN WARNED,
DROP COLUMN ENROUTE_STATE,
DROP COLUMN NR_INJURIES,
DROP COLUMN NR_FATALITIES,
DROP COLUMN COMMENTS,
DROP COLUMN REPORTED_NAME,
DROP COLUMN REPORTED_TITLE,
DROP COLUMN `SOURCE`,
DROP COLUMN PERSON,
DROP COLUMN LUPDATE,
DROP COLUMN TRANSFER,
DROP COLUMN INGESTED_OTHER,
DROP COLUMN  INDICATED_DAMAGE;

SELECT *
 FROM FAA
;
-- Checking for null and blanks for each table

SELECT INDEX_NR ,TIME
FROM FAA
WHERE TIME IS NOT NULL AND TIME <>'' ;

-- Changing the column name to the next one and then either updating the values or deleting them

 -- Filling the data based on the values of another column

SELECT 
    TIME,
    TIME_OF_DAY,
    CASE
        WHEN TIME_OF_DAY IS NOT NULL AND TIME_OF_DAY <> '' THEN TIME_OF_DAY
        WHEN TIME(TIME) >= '05:00' AND TIME(TIME) < '08:00' THEN 'Dawn'
        WHEN TIME(TIME) >= '08:00' AND TIME(TIME) < '18:00' THEN 'Day'
        WHEN TIME(TIME) >= '18:00' AND TIME(TIME) < '20:00' THEN 'Dusk'
        WHEN TIME(TIME) >= '20:00' OR TIME(TIME) < '05:00' THEN 'Night'
        ELSE 'Unkown'
    END AS FINAL_TIME_OF_DAY
FROM FAA
WHERE TIME IS NOT NULL AND TIME <> '' AND (TIME_OF_DAY IS  NULL OR TIME_OF_DAY = '');




UPDATE FAA
SET TIME_OF_DAY = CASE
    WHEN TIME_OF_DAY IS NOT NULL AND TIME_OF_DAY <> '' THEN TIME_OF_DAY
    WHEN TIME IS NULL OR TRIM(TIME) = '' THEN NULL
    WHEN TIME(TIME) >= '05:00:00' AND TIME(TIME) < '08:00:00' THEN 'Dawn'
    WHEN TIME(TIME) >= '08:00:00' AND TIME(TIME) < '18:00:00' THEN 'Day'
    WHEN TIME(TIME) >= '18:00:00' AND TIME(TIME) < '20:00:00' THEN 'Dusk'
    WHEN TIME(TIME) >= '20:00:00' OR TIME(TIME) < '05:00:00' THEN 'Night'
    ELSE 'Unknown'
END
WHERE (TIME_OF_DAY IS NULL OR TIME_OF_DAY = '')
  AND (TIME IS NOT NULL AND TRIM(TIME) <> '');

SELECT distinct TIME_OF_DAY
FROM FAA;

UPDATE FAA
SET TIME_OF_DAY = 'Unknown'
WHERE TIME_OF_DAY IS NULL 
   OR TRIM(TIME_OF_DAY) = ''; 
 
/*
Using SELECT and DELETE alternately to remove NULLs in AIRPORT_ID,
AIRPORT, AIRPORT_LATITUDE, AIRPORT_LONGITUDE, STATE, OPID, and OPERATOR.
These records cannot be filled and represent at small proportion of the total records.
*/


DELETE
FROM FAA
WHERE OPERATOR IS NULL OR TRIM(OPERATOR) ='';

SELECT *
FROM FAA 
WHERE TYPE_ENG IS NULL OR TRIM(TYPE_ENG)='' 
;

SELECT  DISTINCT 
TYPE_ENG , TRIM(TYPE_ENG)
FROM FAA 
;

SELECT 
    INDEX_NR,
    TYPE_ENG AS old_TYPE_ENG,
    CASE
        WHEN TRIM(TYPE_ENG) = 'A' THEN 'Reciprocating'
        WHEN TRIM(TYPE_ENG) = 'B' THEN 'Turbojet'
        WHEN TRIM(TYPE_ENG) = 'C' THEN 'Turboprop'
        WHEN TRIM(TYPE_ENG) = 'D' THEN 'Turbofan'
        ELSE 'Unknown'
    END AS new_TYPE_ENG
FROM FAA
LIMIT 100;


UPDATE FAA
SET TYPE_ENG = CASE
    WHEN TRIM(TYPE_ENG)='A' THEN 'Reciprocating'
    WHEN TRIM(TYPE_ENG)='B' THEN 'Turbojet'
    WHEN TRIM(TYPE_ENG)='C' THEN 'Turboprop'
    WHEN TRIM(TYPE_ENG)='D' THEN 'Turbofan'
    ELSE 'Unknown'
END;
-- The update query went wrong, so we had to import the data as a backup and join the old column values

CREATE TABLE FAA2 LIKE public;
/* To create the table structure after importing few columns using import wizard then 
dropping public table and using import code in the import section */


DELETE
FROM   FAA
WHERE NUM_ENGS IS NULL OR TRIM(NUM_ENGS) ='';


SELECT 
    a.INDEX_NR,  
    a.TYPE_ENG AS old_value,
    b.TYPE_ENG AS correct_value
FROM FAA a
INNER JOIN FAA2 b 
    ON a.INDEX_NR = b.INDEX_NR ;
    

update FAA a
INNER JOIN FAA2 b 
    ON a.INDEX_NR = b.INDEX_NR 
SET a.TYPE_ENG = b.TYPE_ENG;

ALTER TABLE FAA2
ADD PRIMARY KEY (INDEX_NR);




SHOW VARIABLES WHERE Variable_name IN (
  'innodb_buffer_pool_size',
  'innodb_log_file_size',
  'innodb_flush_log_at_trx_commit',
  'net_read_timeout',
  'innodb_lock_wait_timeout',
  'tmp_table_size',
  'max_allowed_packet'
);

-- completeing data cleaning
SELECT *
FROM FAA
WHERE PHASE_OF_FLIGHT IS NULL OR TRIM(PHASE_OF_FLIGHT) ='';


UPDATE FAA
SET PHASE_OF_FLIGHT = 'Unknown'
WHERE PHASE_OF_FLIGHT IS NULL OR TRIM(PHASE_OF_FLIGHT) = '';

SELECT DISTINCT PHASE_OF_FLIGHT,
       COUNT(PHASE_OF_FLIGHT) AS phase_count,
       ROUND(AVG(HEIGHT),0) AS avg_height,
       ROUND(AVG(SPEED),0) AS avg_speed
FROM FAA
WHERE (HEIGHT IS NOT NULL AND TRIM(HEIGHT) <> '')
   OR (SPEED IS NOT NULL AND TRIM(SPEED) <> '')
GROUP BY PHASE_OF_FLIGHT;


-- Creating a CTE to view the fill of nulls and blanks in HEIGHT AND SPEED

WITH PhaseAvg AS (
    SELECT PHASE_OF_FLIGHT,
           ROUND(AVG(HEIGHT), 0) AS avg_height,
           ROUND(AVG(SPEED), 0) AS avg_speed
    FROM FAA
    WHERE (HEIGHT IS NOT NULL AND TRIM(HEIGHT) <> '')
       OR (SPEED IS NOT NULL AND TRIM(SPEED) <> '')
    GROUP BY PHASE_OF_FLIGHT
)
SELECT f.PHASE_OF_FLIGHT,
       f.HEIGHT AS original_height,
       f.SPEED AS original_speed,
       CASE 
           WHEN f.HEIGHT IS NULL OR TRIM(f.HEIGHT) = '' THEN pa.avg_height 
           ELSE f.HEIGHT 
       END AS new_height,
       CASE 
           WHEN f.SPEED IS NULL OR TRIM(f.SPEED) = '' THEN pa.avg_speed 
           ELSE f.SPEED 
       END AS new_speed
FROM FAA f
JOIN PhaseAvg pa
  ON f.PHASE_OF_FLIGHT = pa.PHASE_OF_FLIGHT;

-- Updating NULLS and Blanks Using Subquery 

UPDATE FAA f
JOIN (
    SELECT PHASE_OF_FLIGHT,
           ROUND(AVG(HEIGHT), 0) AS avg_height,
           ROUND(AVG(SPEED), 0) AS avg_speed
    FROM FAA
    WHERE (HEIGHT IS NOT NULL AND TRIM(HEIGHT) <> '')
       OR (SPEED IS NOT NULL AND TRIM(SPEED) <> '')
    GROUP BY PHASE_OF_FLIGHT
) pa
ON f.PHASE_OF_FLIGHT = pa.PHASE_OF_FLIGHT
SET f.HEIGHT = CASE 
                  WHEN f.HEIGHT IS NULL OR TRIM(f.HEIGHT) = '' THEN pa.avg_height
                  ELSE f.HEIGHT
               END,
    f.SPEED  = CASE 
                  WHEN f.SPEED IS NULL OR TRIM(f.SPEED) = '' THEN pa.avg_speed
                  ELSE f.SPEED
               END;


SELECT *
FROM FAA 
WHERE (HEIGHT IS  NULL or TRIM(HEIGHT) = '')
       OR (SPEED IS  NULL or TRIM(SPEED) = '');

SELECT *
FROM FAA 
WHERE DAMAGE_LEVEL IS  NULL or TRIM(INDICATED_DAMAGE) = '';

SELECT DISTINCT DAMAGE_LEVEL
FROM FAA 
;
SELECT DISTINCT
    DAMAGE_LEVEL AS original_value,
    CASE
        WHEN DAMAGE_LEVEL IS NULL OR TRIM(DAMAGE_LEVEL) = '' THEN 'Unknown'
        WHEN DAMAGE_LEVEL = 'N' THEN 'None'
        WHEN DAMAGE_LEVEL = 'M' THEN 'Minor'
        WHEN DAMAGE_LEVEL = 'M?' THEN 'Undetermined level'
        WHEN DAMAGE_LEVEL = 'S' THEN 'Substantial'
        ELSE  'Destroyed'
    END AS display_value
FROM FAA;


UPDATE FAA
SET DAMAGE_LEVEL = CASE
    WHEN DAMAGE_LEVEL IS NULL OR TRIM(DAMAGE_LEVEL) = '' THEN 'Unknown'
    WHEN DAMAGE_LEVEL = 'N' THEN 'None'
    WHEN DAMAGE_LEVEL = 'M' THEN 'Minor'
    WHEN DAMAGE_LEVEL = 'M?' THEN 'Undetermined level'
    WHEN DAMAGE_LEVEL = 'S' THEN 'Substantial'
    ELSE 'Destroyed'
END;

UPDATE FAA
SET DAMAGE_LEVEL = 'Unknown'
WHERE DAMAGE_LEVEL= 'Undetermined level'
;

SELECT DISTINCT 
NUM_STRUCK
FROM FAA;

SELECT *
FROM FAA
WHERE SIZE IS NULL OR TRIM(SIZE)='';

UPDATE FAA
SET SIZE = 'Unknown'
WHERE SIZE IS NULL OR TRIM(SIZE) = '';

UPDATE FAA
SET NUM_SEEN = 'Unknown'
WHERE NUM_SEEN IS NULL OR TRIM(NUM_SEEN) = '';

UPDATE FAA
SET NUM_STRUCK = NUM_SEEN
WHERE NUM_STRUCK IS NULL OR TRIM(NUM_STRUCK) = '';


-- ENG_1_POS,ENG_2_POS,ENG_3_POS, ENG_4_POS HAVE NULLS and blanks will be solved in modeling.


 -- Data Cleaning and Preprocessing for NTSB
-- creating a backup table 
CREATE TABLE NSTB2 LIKE NSTB;
INSERT INTO NSTB2
SELECT * FROM NSTB;


SELECT * FROM NSTB;

-- Checking duplicates

SELECT Event_Id, COUNT(*) AS duplicate_count
FROM NSTB
GROUP BY Event_Id
HAVING COUNT(*) > 1;

-- No duplicated records were found.
-- Dropping unnecessary columns
SELECT * 
FROM NSTB;

ALTER TABLE NSTB
DROP COLUMN Aircraft_Category,
DROP COLUMN Amateur_Built,
DROP COLUMN Far_Description,
DROP COLUMN `Schedule`,
DROP COLUMN Purpose_Of_Flight,
DROP COLUMN Analysis,
DROP COLUMN Address,
DROP COLUMN Place,
DROP COLUMN Number_Of_Seats;

ALTER TABLE nstb2
MODIFY Event_Id varchar(20),
ADD primary key (Event_Id);
-- FIXING DROPPING WRONG COLUMN
ALTER TABLE nstb
ADD COLUMN Place TEXT ;

SELECT 
    a.Event_Id,  
    a.Place AS old_value,
    b.Place AS correct_value
FROM NSTB a
INNER JOIN NSTB2 b 
    ON a.Event_Id = b.Event_Id ;
    

update NSTB a
INNER JOIN NSTB2 b 
    ON a.Event_Id = b.Event_Id 
SET a.Place = b.Place;

-- Completeing datapreprosessing

SELECT DISTINCT Aircraft_Damage
FROM NSTB;


SELECT DISTINCT Aircraft_Damage AS original_value,
       CASE
           WHEN Aircraft_Damage IS NULL OR TRIM(Aircraft_Damage) = '' THEN 'Unknown'
           WHEN Aircraft_Damage IN ('Loss', 'Wreckage') THEN 'Destroyed'
           WHEN Aircraft_Damage IN ( 'Injury', 'Decay') THEN 'Minor'
           WHEN Aircraft_Damage  IN ('Harm','damage') THEN 'Substantial'
                      ELSE Aircraft_Damage

        
       END AS normalized_value
FROM NSTB;


UPDATE NSTB
SET Aircraft_Damage = CASE
    WHEN Aircraft_Damage IS NULL OR TRIM(Aircraft_Damage) = '' THEN 'Unknown'
    WHEN Aircraft_Damage IN ('Loss', 'Wreckage') THEN 'Destroyed'
    WHEN Aircraft_Damage IN ('Injury', 'Decay') THEN 'Minor'
    WHEN Aircraft_Damage IN ('Harm', 'damage') THEN 'Substantial'
    ELSE Aircraft_Damage
END;

SELECT DISTINCT Make, COUNT(*)
FROM NSTB
GROUP BY Make
ORDER BY 2 DESC ; 
-- Standardizing make column
SELECT DISTINCT Make,
       UPPER(TRIM(SUBSTRING_INDEX(REGEXP_REPLACE(Make, '[^A-Za-z ]', ''), ' ', 1))) AS first_word_letters_only
FROM NSTB
;


UPDATE NSTB
SET Make=UPPER(TRIM(SUBSTRING_INDEX(REGEXP_REPLACE(Make,'[^A-Za-z ]',''),' ',1)));

UPDATE NSTB
SET Make=CASE
	WHEN Make ='AIR' THEN 'AIRBUS'
    ELSE Make
END ;
-- Standardizing Model column
SELECT DISTINCT Model, UPPER(REGEXP_REPLACE(Model, '[^A-Za-z0-9]', '')) AS NEW_Model FROM NSTB;

UPDATE NSTB
SET Model = UPPER(REGEXP_REPLACE(Model, '[^A-Za-z0-9]', ''));

SELECT 
    Make,
    Model,
    CASE 
        WHEN Model REGEXP '^[0-9]' THEN CONCAT(LEFT(Make, 1), Model)
        ELSE Model
    END AS New_Model
FROM NSTB;

UPDATE NSTB
SET Model = CASE 
    WHEN Model REGEXP '^[0-9]' THEN CONCAT(LEFT(Make, 1), Model)
    ELSE Model
END;

SELECT DISTINCT Model ,COUNT(*) AS NUM
FROM nstb
GROUP BY Model 
ORDER BY 2 DESC;

-- Standardizing Model column IN Nstb WITH  AIRCRAFT in FAA
SELECT DISTINCT AIRCRAFT
FROM FAA;
 
SELECT DISTINCT AIRCRAFT, 
UPPER(REGEXP_REPLACE(AIRCRAFT, '[^A-Za-z0-9]', '')) AS NEW_AIRCRAFT 
FROM FAA; 

UPDATE FAA
SET AIRCRAFT = UPPER(REGEXP_REPLACE(AIRCRAFT, '[^A-Za-z0-9]', ''));

SELECT DISTINCT AIRCRAFT ,COUNT(*) AS NUM
FROM FAA
GROUP BY AIRCRAFT
ORDER BY 2 DESC;
-- NUM OF ENGINGES AND ENGINGE TYPE ARE DIFFRENT FOR THE SAME MODEL IN NSTB 
DELETE
FROM NSTB
WHERE Number_Of_Engines>4 OR Number_Of_Engines=0; 
--
SELECT DISTINCT Engine_Type
FROM NSTB;

SELECT DISTINCT TYPE_ENG
FROM FAA;

SELECT *
FROM NSTB 
WHERE Engine_Type IN ('electric','4 cycle','2 cycle');

SELECT DISTINCT Model,Engine_Type
FROM NSTB;
/*
AFTER REMOVING SYMBOLS AND NORMALIZING CASE, THERE ARE MORE THAN 4000 UNIQUE MODELS IN NSTB.
THERE IS NO DIRECT FUZZY MERGING IN MYSQL, SO THE DATA WAS EXPORTED TO PYTHON
TO PERFORM RAPID FUZZY MERGE FOR DATA NORMALIZATION.
*/




create table dimmodelfaa(
Model text);


INSERT INTO dimmodelfaa
SELECT DISTINCT AIRCRAFT 
FROM FAA;

SELECT * FROM dimmodelfaa;

SELECT Event_Id,Model
FROM NSTB;
-- 	IMPORTING NORMALIZED DATA 
-- FIRST IMPORTING TABLE STUCTURE BY WIZRD THEN TRUNCATING VALUES TO LOAD DATA
TRUNCATE TABLE matched_models_with_event_id;

LOAD DATA LOCAL INFILE 'C:/Users/Akram/Desktop/matched_models_with_event_id.csv'
INTO TABLE matched_models_with_event_id
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * 
FROM matched_models_with_event_id;
-- MERGING NEW_MODEL CLEANED NORMALIZED RECORDS .
SELECT 
    n.Event_Id,
    n.Model AS Original_Model,
    m.Closest_FAA_Model,
    m.Similarity
FROM 
    nstb n
JOIN 
    matched_models_with_event_id m
ON 
    n.Event_Id = m.Event_Id
LIMIT 100;


UPDATE nstb n
JOIN matched_models_with_event_id m
  ON n.Event_Id = m.Event_Id
SET n.Model = m.Closest_FAA_Model;

SELECT DISTINCT AIRCRAFT,TYPE_ENG 
FROM FAA;-- 498 ROW

SELECT DISTINCT AIRCRAFT
FROM FAA; -- 497 ROW

-- THERE IS AN AIRCRAFT MODEL HAVE 2 TYPE_ENG IN FAA
SELECT AIRCRAFT, COUNT(DISTINCT TYPE_ENG) AS type_count
FROM FAA
GROUP BY AIRCRAFT
HAVING type_count > 1;  

SELECT DISTINCT AIRCRAFT,TYPE_ENG 
FROM FAA
WHERE AIRCRAFT='DIAMONDDA40STAR';

-- Searching the web the TYPE_ENG is Reciprocating not Turboprop
-- modifing

UPDATE FAA
SET TYPE_ENG = 'Reciprocating'
WHERE AIRCRAFT = 'DIAMONDDA40STAR';

SELECT DISTINCT TYPE_ENG
FROM FAA
WHERE AIRCRAFT = 'DIAMONDDA40STAR';


-- NOW WE HAVE NORMALIZED TYPE_ENG AND MODEL COLUMNS,
-- WHICH WE WILL USE FOR BOTH FAA AND NSTB TABLES

-- DEALING WITH WRONG DATE FORMAT IN NSTB
 SELECT DISTINCT Event_Date
 FROM NSTB;
 
 SELECT 
    Event_Date AS original_date,
    STR_TO_DATE(Event_Date, '%m/%d/%Y') AS converted_date
FROM NSTB
LIMIT 100;


UPDATE NSTB
SET Event_Date = STR_TO_DATE(Event_Date, '%m/%d/%Y')
WHERE Event_Date IS NOT NULL;
 -- Normalizing location in both faa and nstb

SELECT DISTINCT geometry , Longitude
 FROM NSTB;
 
 SELECT 
    CONCAT('POINT (', AIRPORT_LONGITUDE, ' ', AIRPORT_LATITUDE, ')') AS geomtry
FROM FAA
LIMIT 100;


ALTER TABLE FAA ADD COLUMN geometry VARCHAR(100);


UPDATE FAA
SET geometry = CONCAT('POINT (', AIRPORT_LONGITUDE, ' ', AIRPORT_LATITUDE, ')');

SELECT 
     AIRPORT_LONGITUDE, AIRPORT_LATITUDE,  geometry
FROM FAA
LIMIT 100;

CREATE TABLE all_unique_geometry AS
SELECT * FROM (
    SELECT DISTINCT AIRPORT_LONGITUDE AS longitude,
           AIRPORT_LATITUDE AS latitude,
           geometry
    FROM FAA

    UNION

    SELECT DISTINCT Longitude AS longitude,
           Latitude AS latitude,
           geometry
    FROM NSTB
) AS combined;

select * from all_unique_geometry;
/*
We exported the table `all_unique_geometry` to Python to get the correct corresponding country and city/state 
for each location, and use this information in both NSTB and FAA tables.
*/


-- Some Points that have no related location wrong data entry
-- selecting and deleting records with no related location (few small records):
SELECT * 
FROM FAA
WHERE geometry IN ("POINT (16°41'40?E 49°09'05?N )" ,"POINT (-150.94475 70.3442778,-15)","POINT (42.6907171,-88 42.6907171,-88)");-- 3 rows

DELETE
FROM FAA
WHERE geometry IN ("POINT (16°41'40?E 49°09'05?N )" ,"POINT (-150.94475 70.3442778,-15)","POINT (42.6907171,-88 42.6907171,-88)");

delete
FROM faa
WHERE geometry IN
('POINT (120.271 14.7944)','POINT (-63.0550995 18.2047997)','POINT (101.709917 2.745578)'
,'POINT (113.914603 22.308919)','POINT (-63.1089 18.040953)','POINT (-68.959803 12.188853)'
,'POINT (-70.015221 12.501389)','POINT (103.994433 1.350189)','POINT (-64.5333 18.4333)'
,'POINT (-146.3663583 67.0086750,-14)','POINT (-120.9375 -0.703107)','POINT (12.479808092529892 41.89874965)'
,'POINT (-63.0467131 18.0814066)','POINT (-57.856525 -51.6930616)','POINT (166.6683349 -77.8483347)'
,'POINT (104.0383696 1.1030815)','POINT (16.1810799 50.3110494)','POINT (103.8194992 1.357107)'
,'POINT (103.98847034565972 1.35755735)','POINT (-79.79313999026272 19.71988615)','POINT (-63.0575966 18.100531)'
,'POINT (103.9304615508624 1.30890695)','POINT (103.9746973 1.3539247)','POINT (-63.11185168371077 18.04087385)'
,'POINT (105.64723 -10.4837768)','POINT (25.5186148 54.6705282','POINT (-64.41546930691665 18.465439)'
,'POINT (-63.0549948 18.0423736)','POINT (14.990310290688765 50.747604)','POINT (-64.5661642 18.4024395)'
,'POINT (113.91840450773888 22.3125477)','POINT (-64.63883251023499 18.42105685)','POINT (-61.29117303493048 -51.83696705)'); -- 217 rows


SELECT *
FROM nstb
WHERE geometry IN
('POINT (120.271 14.7944)','POINT (-63.0550995 18.2047997)','POINT (101.709917 2.745578)'
,'POINT (113.914603 22.308919)','POINT (-63.1089 18.040953)','POINT (-68.959803 12.188853)'
,'POINT (-70.015221 12.501389)','POINT (103.994433 1.350189)','POINT (-64.5333 18.4333)'
,'POINT (-146.3663583 67.0086750,-14)','POINT (-120.9375 -0.703107)','POINT (12.479808092529892 41.89874965)'
,'POINT (-63.0467131 18.0814066)','POINT (-57.856525 -51.6930616)','POINT (166.6683349 -77.8483347)'
,'POINT (104.0383696 1.1030815)','POINT (16.1810799 50.3110494)','POINT (103.8194992 1.357107)'
,'POINT (103.98847034565972 1.35755735)','POINT (-79.79313999026272 19.71988615)','POINT (-63.0575966 18.100531)'
,'POINT (103.9304615508624 1.30890695)','POINT (103.9746973 1.3539247)','POINT (-63.11185168371077 18.04087385)'
,'POINT (105.64723 -10.4837768)','POINT (25.5186148 54.6705282','POINT (-64.41546930691665 18.465439)'
,'POINT (-63.0549948 18.0423736)','POINT (14.990310290688765 50.747604)','POINT (-64.5661642 18.4024395)'
,'POINT (113.91840450773888 22.3125477)','POINT (-64.63883251023499 18.42105685)','POINT (-61.29117303493048 -51.83696705)');-- 81 rows

delete
FROM nstb
WHERE geometry IN
('POINT (120.271 14.7944)','POINT (-63.0550995 18.2047997)','POINT (101.709917 2.745578)'
,'POINT (113.914603 22.308919)','POINT (-63.1089 18.040953)','POINT (-68.959803 12.188853)'
,'POINT (-70.015221 12.501389)','POINT (103.994433 1.350189)','POINT (-64.5333 18.4333)'
,'POINT (-146.3663583 67.0086750,-14)','POINT (-120.9375 -0.703107)','POINT (12.479808092529892 41.89874965)'
,'POINT (-63.0467131 18.0814066)','POINT (-57.856525 -51.6930616)','POINT (166.6683349 -77.8483347)'
,'POINT (104.0383696 1.1030815)','POINT (16.1810799 50.3110494)','POINT (103.8194992 1.357107)'
,'POINT (103.98847034565972 1.35755735)','POINT (-79.79313999026272 19.71988615)','POINT (-63.0575966 18.100531)'
,'POINT (103.9304615508624 1.30890695)','POINT (103.9746973 1.3539247)','POINT (-63.11185168371077 18.04087385)'
,'POINT (105.64723 -10.4837768)','POINT (25.5186148 54.6705282','POINT (-64.41546930691665 18.465439)'
,'POINT (-63.0549948 18.0423736)','POINT (14.990310290688765 50.747604)','POINT (-64.5661642 18.4024395)'
,'POINT (113.91840450773888 22.3125477)','POINT (-64.63883251023499 18.42105685)','POINT (-61.29117303493048 -51.83696705)');

-- importing the location table edited by python as a Dim_location 
truncate table dim_location;

LOAD DATA LOCAL INFILE 'C:/Users/Akram/Desktop/with_country_state (1).csv'
INTO TABLE dim_location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
 
-- linking each Model to the Maker then filling null values for the same Models withe the same Maker as Make column

 select *
from dimmodelfaa
;

SELECT f.*, n.Make
FROM dimmodelfaa f
LEFT JOIN (
    SELECT Model, Make
    FROM (
        SELECT Model, Make,
               ROW_NUMBER() OVER (
                   PARTITION BY Model
                   ORDER BY COUNT(*) DESC, Make ASC
               ) AS rn
        FROM nstb
        GROUP BY Model, Make
    ) t
    WHERE rn = 1
) n ON f.Model = n.Model;


UPDATE dimmodelfaa f
LEFT JOIN (
    SELECT Model, Make
    FROM (
        SELECT Model, Make,
               ROW_NUMBER() OVER (
                   PARTITION BY Model
                   ORDER BY cnt DESC, Make ASC
               ) AS rn
        FROM (
            SELECT Model, Make, COUNT(*) AS cnt
            FROM nstb
            GROUP BY Model, Make
        ) sub
    ) t
    WHERE rn = 1
) n ON f.Model = n.Model
SET f.Make = n.Make;

ALTER TABLE dimmodelfaa ADD COLUMN Make VARCHAR(50);

SELECT *,
       CASE 
           WHEN Model LIKE 'B7%' THEN 'BOEING'
           ELSE Make 
       END AS Make_after_update
FROM dimmodelfaa;

UPDATE dimmodelfaa
SET Make = 'NORTHROP'
WHERE Model LIKE 'GRUMMAN%';

SELECT DISTINCT Make
FROM dimmodelfaa;

-- Dropping unnecessary columns
SELECT *
FROM FAA;

Alter Table faa
DROP COLUMN TIME,
DROP COLUMN STATE,
DROP COLUMN DISTANCE,
DROP COLUMN AIRPORT_LONGITUDE,
DROP COLUMN AIRPORT_LATITUDE;


SELECT *
FROM NSTB;

Alter Table NSTB
DROP COLUMN Country,
DROP COLUMN Make,
DROP COLUMN Engine_Type,
DROP COLUMN Number_Of_Engines,
DROP COLUMN Longitude,
DROP COLUMN City,
DROP COLUMN Latitude;


-- Renaming backup tables (nstb2, faa2) to original_nstb and original_faa
RENAME TABLE 
    nstb2 TO original_nstb,
    faa2 TO original_faa;

-- Creating backup tables (clean_nstb, clean_faa) from the cleaned datasets (nstb, faa)
CREATE TABLE clean_nstb AS
SELECT *
FROM nstb;

CREATE TABLE clean_faa AS
SELECT *
FROM faa;

-- Renaming table dimmodelfaa to dim_model
RENAME TABLE dimmodelfaa TO dim_model;

-- Dropping helper tables used during data cleaning: all_unique_geometry and matched_models_with_event_id
 Drop TABLES all_unique_geometry,matched_models_with_event_id;
 
 SELECT DISTINCT  a.*, 
 b.TYPE_ENG,
 b.NUM_ENGS
 FROM dim_model a
  inner JOIN faa b 
    ON a.model_id= b.model_id
  ORDER BY 1 ASC;  


SELECT * FROM dim_model;

alter table dim_model add column TYPE_ENG varchar(20),
add column NUM_ENGS int;

UPDATE dim_model AS a
INNER JOIN faa AS b
    ON a.model_id = b.model_id
SET 
    a.TYPE_ENG = b.TYPE_ENG,
    a.NUM_ENGS = b.NUM_ENGS;
