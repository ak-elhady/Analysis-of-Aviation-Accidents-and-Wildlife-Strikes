-- إنشاء قاعدة البيانات الجديدة
CREATE DATABASE IF NOT EXISTS final_project2;

-- إنشاء الجداول ونسخ البيانات من القديمة للجديدة
CREATE TABLE final_project2.aircraft_parts        LIKE final_project.aircraft_parts;
INSERT INTO final_project2.aircraft_parts        SELECT * FROM final_project.aircraft_parts;

CREATE TABLE final_project2.clean_faa            LIKE final_project.clean_faa;
INSERT INTO final_project2.clean_faa            SELECT * FROM final_project.clean_faa;

CREATE TABLE final_project2.clean_nstb           LIKE final_project.clean_nstb;
INSERT INTO final_project2.clean_nstb           SELECT * FROM final_project.clean_nstb;

CREATE TABLE final_project2.dim_airport_faa      LIKE final_project.dim_airport_faa;
INSERT INTO final_project2.dim_airport_faa      SELECT * FROM final_project.dim_airport_faa;

CREATE TABLE final_project2.dim_country          LIKE final_project.dim_country;
INSERT INTO final_project2.dim_country          SELECT * FROM final_project.dim_country;

CREATE TABLE final_project2.dim_date             LIKE final_project.dim_date;
INSERT INTO final_project2.dim_date             SELECT * FROM final_project.dim_date;

CREATE TABLE final_project2.dim_location         LIKE final_project.dim_location;
INSERT INTO final_project2.dim_location         SELECT * FROM final_project.dim_location;

CREATE TABLE final_project2.dim_manufacturer     LIKE final_project.dim_manufacturer;
INSERT INTO final_project2.dim_manufacturer     SELECT * FROM final_project.dim_manufacturer;

CREATE TABLE final_project2.dim_model            LIKE final_project.dim_model;
INSERT INTO final_project2.dim_model            SELECT * FROM final_project.dim_model;

CREATE TABLE final_project2.dim_operator_faa     LIKE final_project.dim_operator_faa;
INSERT INTO final_project2.dim_operator_faa     SELECT * FROM final_project.dim_operator_faa;

CREATE TABLE final_project2.dim_species_faa      LIKE final_project.dim_species_faa;
INSERT INTO final_project2.dim_species_faa      SELECT * FROM final_project.dim_species_faa;

CREATE TABLE final_project2.eng_pos              LIKE final_project.eng_pos;
INSERT INTO final_project2.eng_pos              SELECT * FROM final_project.eng_pos;

CREATE TABLE final_project2.eng_pos_bridge       LIKE final_project.eng_pos_bridge;
INSERT INTO final_project2.eng_pos_bridge       SELECT * FROM final_project.eng_pos_bridge;

CREATE TABLE final_project2.faa                  LIKE final_project.faa;
INSERT INTO final_project2.faa                  SELECT * FROM final_project.faa;

CREATE TABLE final_project2.nstb                 LIKE final_project.nstb;
INSERT INTO final_project2.nstb                 SELECT * FROM final_project.nstb;

CREATE TABLE final_project2.original_faa         LIKE final_project.original_faa;
INSERT INTO final_project2.original_faa         SELECT * FROM final_project.original_faa;

CREATE TABLE final_project2.original_nstb        LIKE final_project.original_nstb;
INSERT INTO final_project2.original_nstb        SELECT * FROM final_project.original_nstb;

CREATE TABLE final_project2.strike_details_bridge LIKE final_project.strike_details_bridge;
INSERT INTO final_project2.strike_details_bridge SELECT * FROM final_project.strike_details_bridge;
