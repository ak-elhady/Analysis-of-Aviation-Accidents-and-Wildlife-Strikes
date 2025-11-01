/* 
==========================================================

Description:
This project analyzes aviation safety incidents using two datasets:

1. NSTB (National Transportation Safety Board) dataset – 
   contains detailed records of aviation accidents and incidents 
   including aircraft type, phase of flight, weather conditions, and causes.

2. FAA (Federal Aviation Administration) Bird Strike dataset – 
   contains reports of wildlife strikes involving aircraft, 
   including species, phase of flight, altitude, and damage level.

Objective:
To identify patterns, contributing factors, and insights 
related to aircraft accidents and bird strikes in order 
to improve aviation safety and risk management.
==========================================================
*/

 /* 
----------------------------------------------------------
Section: NSTB Measures and KPIs
----------------------------------------------------------
In this section, we will display and analyze the main 
measures and KPIs derived from the NSTB dataset 
related to aviation accidents and incidents.
----------------------------------------------------------
*/
-- Total Accidents & Incidents with Percentages
SELECT 
    COUNT(*) AS `Total Accidents and Incidents`,
    COUNT(CASE WHEN Investigation_Type = 'Accident' THEN 1 END) AS `Accidents Count`,
    ROUND(
        (COUNT(CASE WHEN Investigation_Type = 'Accident' THEN 1 END) * 100.0 / COUNT(*)),
        2
    ) AS `Accident Percentage (%)`,
    COUNT(CASE WHEN Investigation_Type = 'Incident' THEN 1 END) AS `Incidents Count`,
    ROUND(
        (COUNT(CASE WHEN Investigation_Type = 'Incident' THEN 1 END) * 100.0 / COUNT(*)),
        2
    ) AS `Incidents Percentage (%)`
FROM 
    NSTB;

    
 -- Total People and Injury Percentages Overview
SELECT
    -- Total Counts
    SUM(Total_Fatal_Injuries)   AS `Total Fatalities`,
    SUM(Total_Serious_Injuries) AS `Total Serious Injuries`,
    SUM(Total_Minor_Injuries)   AS `Total Minor Injuries`,
    SUM(Total_Uninjured)        AS `Total Uninjured`,
    
    -- Total People & Total Injured
    (SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries) + SUM(Total_Uninjured)) AS `Total People`,
    (SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries)) AS `Total Injured`,

    -- Percentages
    ROUND(((SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries)) * 100.0 /
           (SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries) + SUM(Total_Uninjured))), 2) AS `Injured Percentage (%)`,

    ROUND((SUM(Total_Uninjured) * 100.0 /
           (SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries) + SUM(Total_Uninjured))), 2) AS `Uninjured Percentage (%)`,

    ROUND((SUM(Total_Fatal_Injuries) * 100.0 /
           (SUM(Total_Fatal_Injuries) + SUM(Total_Serious_Injuries) + SUM(Total_Minor_Injuries) + SUM(Total_Uninjured))), 2) AS `Fatalities Percentage (%)`
FROM 
    NSTB;
    
/* 
----------------------------------------------------------
Section: FAA Measures and KPIs
----------------------------------------------------------
In this section, we will display the main measures and key 
performance indicators (KPIs) derived from the FAA Bird Strike dataset.
----------------------------------------------------------
*/

-- Total Bird Strikes
SELECT 
    COUNT(*) AS `Total Bird Strikes`
FROM 
  FAA;

-- Total Striked Parts
SELECT 
    COUNT(*) AS `Total Striked Parts`
FROM 
    Strike_Details_Bridge AS b
JOIN 
    aircraft_parts AS f
    ON b.Part_ID = f.Part_ID
WHERE 
    f.Part_Name LIKE '%STR%';
    
    
-- Total Damaged Parts with Damage Percentage
SELECT
    COUNT(CASE WHEN f.Part_Name LIKE '%DAM%' THEN 1 END) AS `Total Damaged Parts`,
    ROUND(
        (COUNT(CASE WHEN f.Part_Name LIKE '%DAM%' THEN 1 END) * 100.0 /
         NULLIF(COUNT(CASE WHEN f.Part_Name LIKE '%STR%' THEN 1 END), 0)),
        2
    ) AS `Damage Percentage (%)`
FROM 
    Strike_Details_Bridge AS b
JOIN 
    aircraft_parts AS f
    ON b.Part_ID = f.Part_ID;

-- Total Ingestion  with Ingetion Percentage (%)`

SELECT
    COUNT(CASE WHEN f.Part_Name LIKE '%ING%' THEN 1 END) AS `Total Ingestion`,
    ROUND(
        (COUNT(CASE WHEN f.Part_Name LIKE '%ING%' THEN 1 END) * 100.0 /
         NULLIF(COUNT(CASE WHEN f.Part_Name LIKE '%STR%' THEN 1 END), 0)),
        2
    ) AS `Ingetion Percentage (%)`
FROM 
    Strike_Details_Bridge AS b
JOIN 
    aircraft_parts AS f
    ON b.Part_ID = f.Part_ID;
    
  /* 
----------------------------------------------------------
Section: Insights and Patterns Analysis
----------------------------------------------------------
In this section, we will analyze key insights and patterns 
from the NSTB and FAA datasets. 

----------------------------------------------------------
*/
  
/*
According to the FAA, bird strikes are recognized as a contributing factor 
in several aviation accidents and incidents (FAA, Wildlife Strike Database). 
In this analysis, we will examine the relationship between bird strikes 
(FAA dataset) and aviation incidents (NSTB dataset) to identify patterns and risk areas.
*/

-- Most Bird Strikes Occur During Migration Season.
-- Let's see if the location and time of strikes correlate with NSTB incidents and accidents.


-- Geographical Analysis
-- Shows total accidents/incidents (NSTB) and bird strikes (FAA) per country, ordered by accidents.

SELECT 
    c.country,
    COUNT( n.Event_Id) AS `Total Accidents & Incidents`,
    COUNT( f.INDEX_NR) AS `Total Bird Strikes`
FROM 
    dim_country c
LEFT JOIN 
    dim_location l
    ON c.country_id = l.country_id
LEFT JOIN 
    nstb n
    ON l.location_id = n.location_id
LEFT JOIN 
    dim_airport_faa ap
    ON l.location_id = ap.Location_ID
LEFT JOIN 
    faa f
    ON ap.airport_id = f.AIRPORT_ID
GROUP BY 
    c.country
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
-- Shows total accidents/incidents (NSTB) and bird strikes (FAA) in United states per state, ordered by accidents.    
    SELECT 
    l.state,
    COUNT(n.Event_Id) AS `Total Accidents & Incidents`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`
FROM 
    dim_country c
LEFT JOIN 
    dim_location l
    ON c.country_id = l.country_id
LEFT JOIN 
    nstb n
    ON l.location_id = n.location_id
LEFT JOIN 
    dim_airport_faa ap
    ON l.location_id = ap.Location_ID
LEFT JOIN 
    faa f
    ON ap.airport_id = f.AIRPORT_ID
WHERE 
    c.country = 'United States'
GROUP BY 
    l.state
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
-- Temporal Analysis
--  Total Accidents & Incidents and Bird Strikes per common Year
  SELECT 
    d.year,
    COUNT(DISTINCT n.Event_Id) AS `Total Accidents & Incidents`,
    COUNT(DISTINCT f.INDEX_NR) AS `Total Bird Strikes`
FROM 
    dim_date d
LEFT JOIN nstb n
    ON n.date_id = d.Date_id
LEFT JOIN faa f
    ON f.date_id = d.Date_id
GROUP BY 
    d.year
HAVING 
    COUNT(DISTINCT n.Event_Id) > 0 AND COUNT(DISTINCT f.INDEX_NR) > 0
ORDER BY 
    d.year;
    
 
 -- Total Accidents & Incidents and Bird Strikes per Season (ordered by NSTB)
SELECT
    d.season,
    COUNT(DISTINCT n.Event_Id) AS `Total Accidents & Incidents`,
    COUNT(DISTINCT f.INDEX_NR) AS `Total Bird Strikes`
FROM 
    dim_date d
LEFT JOIN nstb n
    ON n.date_id = d.Date_id
LEFT JOIN faa f
    ON f.date_id = d.Date_id
GROUP BY 
    d.season
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
-- Insights focused on NSTB accidents and incidents.

-- Total Accidents and Incidents by Broad Phase of Flight with Percentage
SELECT 
    Broad_Phase_Of_Flight,
    COUNT(Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    NSTB
GROUP BY 
    Broad_Phase_Of_Flight
ORDER BY 
    `Total Accidents & Incidents` DESC;

-- Total Accidents and Incidents by Weather Condition with Percentage
SELECT 
    Weather_Condition,
    COUNT(Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    NSTB
GROUP BY 
    Weather_Condition
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
 -- Total Accidents and Incidents by Probable Cause with Percentage
SELECT 
    Probable_Cause,
    COUNT(Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    NSTB
GROUP BY 
    Probable_Cause
ORDER BY 
    `Total Accidents & Incidents` DESC;
    

  -- Total Accidents and Incidents by Aircraft Damage with Percentage
SELECT 
    Aircraft_Damage,
    COUNT(Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    NSTB
GROUP BY 
    Aircraft_Damage
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
 -- Total Accidents and Incidents by Place with Percentage
SELECT 
    Place,
    COUNT(Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    NSTB
GROUP BY 
    Place
ORDER BY 
    `Total Accidents & Incidents` DESC;

-- Top 20 Manufacturers by Total Accidents & Incidents
SELECT 
    m.manufacturer_name,
    COUNT(n.Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(n.Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    dim_manufacturer m
LEFT JOIN dim_model mo
    ON m.manufacturer_id = mo.manufacturer_id
LEFT JOIN nstb n
    ON mo.model_id = n.model_id
GROUP BY 
    m.manufacturer_name
ORDER BY 
    `Total Accidents & Incidents` DESC
LIMIT 20;

   
 -- Total Accidents & Incidents per Model with Manufacturer and Engine Info
SELECT 
    mo.Model,
    m.manufacturer_name,
    mo.TYPE_ENG AS `Engine Type`,
    mo.NUM_ENGS AS `Number of Engines`,
    COUNT(n.Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(n.Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    dim_model mo
LEFT JOIN dim_manufacturer m
    ON mo.manufacturer_id = m.manufacturer_id
LEFT JOIN nstb n
    ON mo.model_id = n.model_id
GROUP BY 
    mo.Model, m.manufacturer_name, mo.TYPE_ENG, mo.NUM_ENGS
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
    -- Total Accidents & Incidents by Engine Type with Percentage
SELECT 
    mo.TYPE_ENG AS `Engine Type`,
    COUNT(n.Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(n.Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    dim_model mo
LEFT JOIN nstb n
    ON mo.model_id = n.model_id
GROUP BY 
    mo.TYPE_ENG
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
-- Total Accidents & Incidents per Number of Engines with Percentage
SELECT 
    mo.NUM_ENGS AS `Number of Engines`,
    COUNT(n.Event_Id) AS `Total Accidents & Incidents`,
    ROUND(
        COUNT(n.Event_Id) * 100.0 / (SELECT COUNT(*) FROM NSTB),
        2
    ) AS `Percentage %`
FROM 
    dim_model mo
LEFT JOIN nstb n
    ON mo.model_id = n.model_id

GROUP BY 
    mo.NUM_ENGS
ORDER BY 
    `Total Accidents & Incidents` DESC;
    
    
-- Insights focused on FAA bird strikes.

-- Total Bird Strikes by Time of Day with Percentage
SELECT 
    f.TIME_OF_DAY,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.TIME_OF_DAY
ORDER BY 
    `Total Bird Strikes` DESC;
    
 -- Total Bird Strikes by Phase of Flight with Average Height, Speed, and Percentage
SELECT 
    f.PHASE_OF_FLIGHT,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(AVG(f.HEIGHT), 0) AS `Average Height`,
    ROUND(AVG(f.SPEED), 0) AS `Average Speed`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.PHASE_OF_FLIGHT
ORDER BY 
    `Total Bird Strikes` DESC;
    
    -- Total Bird Strikes by Damage Level with Percentage
SELECT 
    f.DAMAGE_LEVEL,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.DAMAGE_LEVEL
ORDER BY 
    `Total Bird Strikes` DESC;

-- Total Bird Strikes by Damage Level with Percentage
SELECT 
    f.DAMAGE_LEVEL,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.DAMAGE_LEVEL
ORDER BY 
    `Total Bird Strikes` DESC;
    
   -- Total Bird Observations by Number of Birds Seen with Percentage
SELECT 
    f.NUM_SEEN AS `Number of Birds Seen`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.NUM_SEEN
ORDER BY 
    `Total Bird Strikes` DESC;
    
-- Total Bird Strikes by Number of Birds Struck with Percentage
SELECT 
    f.NUM_STRUCK AS `Number of Birds Struck`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
GROUP BY 
    f.NUM_STRUCK
ORDER BY 
    `Total Bird Strikes` DESC;

-- Bird Strikes by Species Size with Percentage and Damage Rate
SELECT 
    s.SIZE,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        SUM(CASE WHEN f.DAMAGE_LEVEL IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(f.INDEX_NR),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_species_faa s
    ON f.SPECIES_ID = s.SPECIES_ID
GROUP BY 
    s.SIZE
ORDER BY 
    `Total Bird Strikes` DESC;

-- Bird Strikes by Species Size with Percentage and Damage Rate per Size
SELECT 
    s.SIZE,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_species_faa s
    ON f.SPECIES_ID = s.SPECIES_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    s.SIZE
ORDER BY 
    `Total Bird Strikes` DESC;

 -- Top 20 Bird Strikes by Species with Percentage and Damage Rate
SELECT 
    s.SPECIES, s.SIZE,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_species_faa s
    ON f.SPECIES_ID = s.SPECIES_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    s.SPECIES , s.SIZE
ORDER BY 
    `Total Bird Strikes`  DESC
LIMIT 20;

-- Top 20 Airports by Total Bird Strikes with Percentage
SELECT 
    ap.AIRPORT_NAME,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
LEFT JOIN dim_airport_faa ap
    ON f.AIRPORT_ID = ap.AIRPORT_ID
GROUP BY 
    ap.AIRPORT_NAME
ORDER BY 
    `Total Bird Strikes` DESC
LIMIT 20;

-- Top 20 Operators by Total Bird Strikes with Percentage
SELECT 
    o.operator,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`
FROM 
    faa f
LEFT JOIN dim_operator_faa o
    ON f.OPID = o.OPID
GROUP BY 
    o.operator
ORDER BY 
    `Total Bird Strikes` DESC
LIMIT 20;

-- Top 20 Manufacturers by Total Bird Strikes with Percentage and Damage Rate
SELECT 
    m.manufacturer_name,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_model mo
    ON f.MODEL_ID = mo.MODEL_ID
LEFT JOIN dim_manufacturer m
    ON mo.MANUFACTURER_ID = m.MANUFACTURER_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    m.manufacturer_name
ORDER BY 
    `Total Bird Strikes` DESC
LIMIT 20;


-- Top 20 Models by Total Bird Strikes with Manufacturer, Engine Info, Percentage and Damage Rate
SELECT 
    mo.Model,
    m.manufacturer_name AS `Manufacturer`,
    mo.TYPE_ENG AS `Engine Type`,
    mo.NUM_ENGS AS `Number of Engines`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_model mo
    ON f.MODEL_ID = mo.MODEL_ID
LEFT JOIN dim_manufacturer m
    ON mo.MANUFACTURER_ID = m.MANUFACTURER_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    mo.Model, m.manufacturer_name, mo.TYPE_ENG, mo.NUM_ENGS
ORDER BY 
    `Total Bird Strikes` DESC
LIMIT 20;

-- Bird Strikes by Engine Type with Percentage and Damage Rate
SELECT 
    mo.TYPE_ENG AS `Engine Type`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_model mo
    ON f.MODEL_ID = mo.MODEL_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    mo.TYPE_ENG
ORDER BY 
    `Total Bird Strikes` DESC;

-- Bird Strikes by Number of Engines with Percentage and Damage Rate
SELECT 
    mo.NUM_ENGS AS `Number of Engines`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_model mo
    ON f.MODEL_ID = mo.MODEL_ID
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
GROUP BY 
    mo.NUM_ENGS
ORDER BY 
    `Total Bird Strikes` DESC;
    
    -- Bird Strikes by Engine Position with Percentage and Damage Rate
SELECT 
    ep.position_name AS `Position Name`,
    COUNT(f.INDEX_NR) AS `Total Bird Strikes`,
    ROUND(
        COUNT(f.INDEX_NR) * 100.0 / (SELECT COUNT(*) FROM faa),
        2
    ) AS `Percentage %`,
    ROUND(
        COUNT(CASE 
                  WHEN a.Part_Name LIKE '%DAM%' THEN 1 
              END) * 100.0 / NULLIF(COUNT(b.Part_ID),0),
        2
    ) AS `Damage Rate %`
FROM 
    faa f
LEFT JOIN dim_model mo
    ON f.MODEL_ID = mo.MODEL_ID
LEFT JOIN eng_pos_bridge epb
    ON mo.MODEL_ID = epb.model_id
LEFT JOIN eng_pos ep
    ON epb.pos_id = ep.pos_id
LEFT JOIN Strike_Details_Bridge b
    ON f.INDEX_NR = b.INDEX_NR  
LEFT JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
WHERE ep.position_name IS NOT NULL
GROUP BY 
    ep.position_name
ORDER BY 
    `Total Bird Strikes` DESC;
    


-- Total Striked parts with Percentage
SELECT 
    a.Part_Name,
    COUNT(b.Part_ID) AS `Total Striked parts`,
    ROUND(
        COUNT(b.Part_ID) * 100.0 / (SELECT COUNT(*) FROM Strike_Details_Bridge),
        2
    ) AS `Percentage %`
FROM 
    Strike_Details_Bridge b
JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
WHERE 
    a.Part_Name LIKE '%STR%'
GROUP BY 
    a.Part_Name
ORDER BY 
    `Total Striked parts` DESC;

-- Total Damage Parts with Percentage
SELECT 
    a.Part_Name,
    COUNT(b.Part_ID) AS `Total Damage Parts`,
    ROUND(
        COUNT(b.Part_ID) * 100.0 / (SELECT COUNT(*) FROM Strike_Details_Bridge),
        2
    ) AS `Percentage %`
FROM 
    Strike_Details_Bridge b
JOIN aircraft_parts a
    ON b.Part_ID = a.Part_ID
WHERE 
    a.Part_Name LIKE '%DAM%'
GROUP BY 
    a.Part_Name
ORDER BY 
    `Total Damage Parts` DESC;





   

    



