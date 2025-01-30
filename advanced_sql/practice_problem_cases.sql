--short way without extra values

SELECT 
    MAX(salary_year_avg) AS max_salary,
    MIN(salary_year_avg) AS min_salary
FROM 
    job_postings_fact;

--------------------------------------------------------------------------------
--union between separates querys

SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    'Max Salary' AS salary_type
FROM job_postings_fact
WHERE salary_year_avg = (SELECT MAX(salary_year_avg) FROM job_postings_fact)

UNION ALL

SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    'Min Salary' AS salary_type
FROM job_postings_fact
WHERE salary_year_avg = (SELECT MIN(salary_year_avg) FROM job_postings_fact);
-------------------------------------------------------------------------------------
--using CTE best way

WITH extremes AS (
    SELECT 
        MAX(salary_year_avg) AS max_salary,
        MIN(salary_year_avg) AS min_salary
    FROM job_postings_fact
)
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg = max_salary THEN 'Max Salary'
        WHEN salary_year_avg = min_salary THEN 'Min Salary'
    END AS salary_type
FROM 
    job_postings_fact, extremes
WHERE 
    salary_year_avg = extremes.max_salary
    OR salary_year_avg = extremes.min_salary;

------------------------------------------------------------------------

WITH stats AS (
    -- Subconsulta para calcular los valores de referencia
    SELECT 
        MIN(salary_year_avg) AS min_salary,
        MAX(salary_year_avg) AS max_salary,
        AVG(salary_year_avg) AS avg_salary
    FROM 
        job_postings_fact
)
SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg >= (SELECT max_salary FROM stats) * 0.8 THEN 'High Salary'
        WHEN salary_year_avg >= (SELECT avg_salary FROM stats) THEN 'Standard Salary'
        ELSE 'Low Salary'
    END AS salary_bucket
FROM 
    job_postings_fact
WHERE 
    LOWER(job_title_short) LIKE '%data analyst%'
ORDER BY 
    salary_year_avg DESC;
---------------------------------------------------------------------------------------

SELECT 
    salary_bucket, 
    COUNT(*) AS job_count
FROM 
    job_postings_fact
GROUP BY 
    salary_bucket
ORDER BY 
    job_count DESC;

