DROP DATABASE IF EXISTS hr_data_analysis;
CREATE DATABASE hr_data_analysis;

USE hr_data_analysis;

-- Use 'Table Data Import Wizard' feature to upload data into 'hr_data_analysis' database. Table will 
-- automatically get created during the process (name it as hr).

-- Checking if data is loaded or not.
SELECT * FROM hr;

-- ==================================================================================
-- 1. DATA CLEANING

-- Rename id column to emp_id 
ALTER TABLE hr
CHANGE COLUMN ﻿id emp_id VARCHAR(20); -- CHANGE: can change a column name or definition or both

-- Check data type of all columns
DESCRIBE hr; 

-- Check if sys variable 'sql_safe_updates' is OFF or not.
SHOW VARIABLES LIKE "%sql_safe_updates%"; 
SET sql_safe_updates = 0; -- If it is not OFF, to turn in OFF

-- Convert birthdate values to date

-- In this code, we first check if the value contains a forward slash '/' using the LIKE operator. If it does, 
-- we assume the format is '%m/%d/%Y' and convert the value using the STR_TO_DATE() and DATE_FORMAT() functions
-- to the '%Y-%m-%d' format. If it contains a dash '-', we assume the format is '%m-%d-%y' and convert the value 
-- to the '%Y-%m-%d' format. If the value does not match either format, we set the birthdate value to NULL.

-- Note that the DATE_FORMAT() function is used to convert the value to the '%Y-%m-%d' format, which is the 
-- standard MySQL date format. You can adjust the format string in the DATE_FORMAT() function to match your 
-- specific needs if you prefer a different date format.**

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT((STR_TO_DATE(birthdate,'%m/%d/%Y')),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT((STR_TO_DATE(birthdate,'%m-%d-%Y')),'%Y-%m-%d')
    ELSE NULL
END;

SELECT birthdate FROM hr LIMIT 5;

-- Change birthdate column datatype
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;  -- MODIFY: can change a column definition but not it's name

DESCRIBE hr;

-- Convert hire_date values to date
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT((STR_TO_DATE(hire_date,'%m/%d/%Y')),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT((STR_TO_DATE(hire_date,'%m-%d-%Y')),'%Y-%m-%d')
    ELSE NULL
END;

SELECT hire_date FROM hr LIMIT 5;

-- Change hire_date column datatype
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

DESCRIBE hr;

-- Convert termdate values to date and remove time
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate,'%Y-%m-%d %H:%i:%s UTC')) 
WHERE termdate IS NOT NULL AND termdate != ' ';       -- giving error

-- Because we're probably using SQL in strict mode.
SHOW VARIABLES LIKE '%sql_mode';  
-- it's value is 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
-- Run either of the below two Query to update the value 
-- SET SQL_MODE = ' '
-- OR
-- SET SQL_MODE = 'ALLOW_INVALID_DATES'; 

-- Changing sql_mode value
SET SQL_MODE = 'ALLOW_INVALID_DATES';              


-- run again the same query to convert termdate values
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate,'%Y-%m-%d %H:%i:%s UTC')) 
WHERE termdate IS NOT NULL AND termdate != ' ';  -- ran successfully now

SELECT termdate FROM hr LIMIT 5;

-- Change termdate column datatype
ALTER TABLE hr
MODIFY termdate DATE;

DESCRIBE hr;

-- Adding age column

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr 
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

SELECT * FROM hr LIMIT 10; 
  
-- checking the age values range
SELECT 
	MIN(age) as youngest, 
    MAX(age) as oldest 
FROM hr;                

-- check how many employees with ineligible values for age
SELECT COUNT(*) FROM hr WHERE age < 18; 

-- checking termdates in the future
SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();

-- -- checking number of employees currently working
SELECT COUNT(*) FROM hr WHERE termdate = '0000-00-00';
