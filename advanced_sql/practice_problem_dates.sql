SELECT 
    job_schedule_type,
    job_posted_date,
    AVG(salary_year_avg) AS avg_salary_year,
    AVG(salary_hour_avg) AS avg_salary_hour
FROM  
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type,
    job_posted_date;

---------------------------------------
-- Problema 2
SELECT 
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month,
    COUNT(job_id) AS job_count
FROM 
    job_postings_fact
WHERE 
    EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY 
    month
ORDER BY 
    month;
-----------------------------------------------------------
-- Problema 3
SELECT 
    cd.name AS company_name,
    COUNT(job_id) AS job_count
FROM 
    job_postings_fact jpdf
JOIN 
    company_dim cd ON jpdf.company_id = cd.company_id
WHERE 
    job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_posted_date) = 2
    AND EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY 
    cd.name
ORDER BY 
    job_count DESC;


SELECT *
FROM company_dim
LIMIT 10;