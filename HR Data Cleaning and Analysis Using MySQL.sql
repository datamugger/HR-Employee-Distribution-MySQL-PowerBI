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

-- ===============================================================================

-- 2. DATA ANALYSIS

-- ## Questions

-- 1. What is the gender breakdown of employees in the company?
-- 2. What is the race/ethnicity breakdown of employees in the company?
-- 3. What is the age distribution of employees in the company?
-- 4. How many employees work at headquarters versus remote locations?
-- 5. What is the average length of employment for employees who have been terminated?
-- 6. How does the gender distribution vary across departments and job titles?
-- 7. What is the distribution of job titles across the company?
-- 8. Which department has the highest turnover rate?
-- 9. What is the distribution of employees across locations by city and state?
-- 10. How has the company's employee count changed over time based on hire and term dates?

-- Solutions

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count 
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT
	MIN(age) AS youngest,
    MAX(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT FLOOR(age/10)*10 AS age_group, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY FLOOR(age/10)*10;

SELECT 
	CASE
	  WHEN age >= 18 AND age <= 24 THEN '18-24'
      WHEN age >= 25 AND age <= 34 THEN '25-34'
      WHEN age >= 35 AND age <= 44 THEN '35-44'
      WHEN age >= 45 AND age <= 54 THEN '45-54'
      WHEN age >= 55 AND age <= 64 THEN '55-64'
      ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;
      
-- Age-Group Distribution by Gender
SELECT 
	CASE
	  WHEN age >= 18 AND age <= 24 THEN '18-24'
      WHEN age >= 25 AND age <= 34 THEN '25-34'
      WHEN age >= 35 AND age <= 44 THEN '35-44'
      WHEN age >= 45 AND age <= 54 THEN '45-54'
      WHEN age >= 55 AND age <= 64 THEN '55-64'
      ELSE '65+'
	END AS age_group, gender,
    COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS count
FROM hr 
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location; 

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(AVG(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department,gender
ORDER BY department,gender;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate? 

-- "Turnover rate" typically refers to the rate at which employees leave a company or department and 
-- need to be replaced. It can be calculated as the number of employees who leave over a given time period
-- divided by the average number of employees in the company or department over that same time period.

SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <=curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER by termination_rate DESC;
    
-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT MIN(hire_date), MAX(hire_date) FROM hr;

-- This query groups the employees by the year of their hire date and calculates the total number of hires,
-- terminations, and net change (the difference between hires and terminations) for each year. The results 
-- are sorted by year in ascending order.

SELECT 
    YEAR(hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
    ROUND(((COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM 
    hr
WHERE age >= 18
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    YEAR(hire_date) ASC;

-- In this modified query, a subquery is used to first calculate the terminations alias, which is then used
-- in the calculation for the net_change and net_change_percent column in the outer query.

SELECT 
	year,
	hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100,2) AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS year,
    count(*) as hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age > 18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY year ASC;
    
-- 11. What is the tenure distribution for each department?

-- How long do employees work in each department before they leave or are made to leave?

SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365),2) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >=18
GROUP BY department;

-- ==========================================================================================
## Summary of Findings

-- There are more male employees.
-- White race is the most dominant while Native Hawaiian and American Indian are the least dominant.
-- The youngest employee is 20 years old and the oldest is 57 years old.
-- 5 age groups were created (18-24, 25-34, 35-44, 45-54, 55-64). A large number of employees were between 25-34 followed by 35-44 while the smallest group was 55-64.
-- A large number of employees work at the headquarters versus remotely.
-- The average length of employment for terminated employees is around 7 years.
-- The gender distribution across departments is fairly balanced but there are generally more male than female employees.
-- The Marketing department has the highest turnover rate followed by Training. The least turn over rate are in the Research and development, Support and Legal departments.
-- A large number of employees come from the state of Ohio.
-- The net change in employees has increased over the years.
-- The average tenure for each department is about 8 years with Legal and Auditing having the highest and Services, Sales and Marketing having the lowest.

## Limitations
-- Some records had negative ages and these were excluded during querying(967 records). Ages used were 18 years and above.
-- Some termdates were far into the future and were not included in the analysis(1599 records). The only term dates used were those less than or equal to the current date.
