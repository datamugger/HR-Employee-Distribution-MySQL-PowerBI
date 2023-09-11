USE hr_data_analysis;

SHOW COLUMNS FROM hr;
SELECT * FROM hr LIMIT 10;

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