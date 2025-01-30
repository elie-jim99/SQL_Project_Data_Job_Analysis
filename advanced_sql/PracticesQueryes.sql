/*
Problema 1: Relación entre empresas y trabajos publicados
Escenario: Necesitas analizar qué empresas han publicado trabajos en enero y cuál es el promedio del salario anual de esas publicaciones.

Objetivo: Obtener una lista con los nombres de las empresas, la cantidad de trabajos publicados en enero y el salario promedio anual.
Detalles:
Utiliza la tabla january_jobs y haz un JOIN con company_dim.
Calcula el promedio del salario anual (salary_year_avg).
Agrupa por empresa.
*/
SELECT
    cd.name AS company_name,
    jj.job_title_short AS job_title,
    AVG(salary_year_avg) AS avg_january_salary
    --AVG(COALESCE(jj.salary_year_avg, 0)) AS avg_january_salary
FROM
    january_jobs AS jj
INNER JOIN company_dim AS cd ON jj.company_id = cd.company_id
GROUP BY
    cd.name,
    jj.job_title_short;

----------------------------------------------------------------------------
/*
Problema 2: Trabajos remotos y salarios
Escenario: Quieres identificar las posiciones remotas con los salarios más altos y más bajos de febrero.

Objetivo: Crear una tabla llamada remote_salary_extremes que contenga:
job_id, job_title_short, company_id, salary_year_avg.
Marca con un campo salary_type si es el salario más alto o el más bajo.
Detalles:
Trabaja con la tabla february_jobs.
Solo incluye trabajos remotos (job_work_from_home = TRUE).
*/

CREATE TABLE remote_salary_extremes AS
WITH extremes AS (
    SELECT 
        MAX(salary_year_avg) AS max_salary,
        MIN(salary_year_avg) AS min_salary
    FROM february_jobs
    WHERE (job_work_from_home = TRUE)
)
SELECT 
    job_id,
    job_title_short,
    company_id,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg = max_salary THEN 'Max Salary'
        WHEN salary_year_avg = min_salary THEN 'Min Salary'
    END AS salary_type
FROM 
    february_jobs, extremes
WHERE 
    salary_year_avg = extremes.max_salary
    OR salary_year_avg = extremes.min_salary;

SELECT *
FROM remote_salary_extremes; 
--------------------------------------------------------------------------

/*
Problema 3: Habilidades más buscadas
Escenario: Quieres analizar cuáles son las habilidades más comunes asociadas a los trabajos publicados en marzo.

Objetivo: Generar un reporte con:
El nombre de la habilidad (skills), el tipo (type), y el número total de veces que aparece en trabajos de marzo.
Detalles:
Usa la tabla march_jobs y haz un JOIN con skills_job_dim y luego con skills_dim.
Ordena los resultados por frecuencia descendente.
*/

SELECT
    sd.skills,
    sd.type,
    COUNT(*) AS total_jobs
FROM march_jobs AS mj
INNER JOIN skills_job_dim AS sjd ON mj.job_id = sjd.job_id
INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
GROUP BY
   sd.skills, sd.type
ORDER BY
    total_jobs DESC

-------------------------------------------------------------------------------------------------------

/*
Problema 4: Creación de una tabla para trabajos altamente remunerados
Escenario: Necesitas crear una tabla llamada high_salary_jobs para analizar trabajos con salarios por encima del percentil 90 de todos los trabajos en job_postings_fact.

Objetivo: La tabla debe contener:
job_id, job_title_short, job_location, salary_year_avg.
Detalles:
Calcula el percentil 90 de salary_year_avg.
Filtra solo los trabajos que superen este valor.
*/

-- Crear la tabla high_salary_jobs solo con trabajos por encima del percentil 90
CREATE TABLE high_salary_jobs AS
    WITH Percentil90 AS (
        SELECT
            PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY salary_year_avg) AS percentil_90
        FROM job_postings_fact
    )
    SELECT
        job_id,
        job_title_short,
        job_location,
        salary_year_avg
    FROM job_postings_fact
    WHERE salary_year_avg >= (SELECT percentil_90 FROM Percentil90)
    ORDER BY salary_year_avg  DESC;

---------------------------------------------------------------------------------------------

/*
Problema 5: Comparación de habilidades requeridas por mes
Escenario: Quieres analizar cómo varían las habilidades requeridas mes a mes.

Objetivo: Crear una consulta que devuelva, para cada mes:
El mes (January, February, March, etc.).
El número total de habilidades requeridas.
La habilidad más común para ese mes.
Detalles:
Combina las tablas mensuales (january_jobs, february_jobs, march_jobs, etc.) con skills_job_dim y skills_dim.
Usa un CTE para calcular la habilidad más común en cada mes.
*/

WITH MonthlySkills AS (
    SELECT
        EXTRACT(MONTH FROM jp.job_posted_date)::INT AS month, -- Extrae y asegura que el mes sea un número entero
        sd.skills AS skill_name,
        COUNT(*) AS skill_count
    FROM
        job_postings_fact jp
    JOIN
        skills_job_dim sjd ON jp.job_id = sjd.job_id
    JOIN
        skills_dim sd ON sjd.skill_id = sd.skill_id
    GROUP BY
        EXTRACT(MONTH FROM jp.job_posted_date), sd.skills
),
MostCommonSkill AS (
    SELECT
        month,
        skill_name,
        skill_count,
        RANK() OVER (PARTITION BY month ORDER BY skill_count DESC) AS rank -- Clasifica las habilidades por frecuencia
    FROM
        MonthlySkills
)
SELECT
    TO_CHAR(TO_DATE(month::TEXT, 'MM'), 'Month') AS month_name, -- Convierte el número del mes a texto (January, February)
    SUM(skill_count) AS total_skills, -- Total de habilidades requeridas por mes
    (SELECT skill_name
     FROM MostCommonSkill mcs
     WHERE mcs.month = ms.month AND mcs.rank = 1) AS most_common_skill -- Habilidad más común del mes
FROM
    MonthlySkills ms
GROUP BY
    month
ORDER BY
    month; -- Ordena por el número del mes




SELECT *
FROM job_postings_fact
LIMIT 10;

-------------------------------------------------------------------------------------------------

/*
Problema 6: Trabajos con beneficios de seguro médico
Escenario: Quieres crear un reporte sobre trabajos que ofrecen seguro médico.

Objetivo: Crear una tabla llamada health_insurance_jobs que contenga:
job_id, job_title_short, company_name, salary_year_avg, job_location.
Detalles:
Filtra los trabajos donde job_health_insurance = TRUE.
Haz un JOIN con company_dim para incluir el nombre de la empresa.
*/


-----------------------------------------------------------------------------------------------

/*
Problema 7: Análisis de salarios por tipo de horario
Escenario: Quieres analizar los salarios promedio por tipo de horario de trabajo.

Objetivo: Generar un reporte que incluya:
job_schedule_type, el número total de trabajos y el salario promedio anual.
Detalles:
Usa una combinación de funciones agregadas (COUNT, AVG).
Agrupa por job_schedule_type.
*/


-----------------------------------------------------------------------------------------------

/*
Problema 8: Trabajos en diferentes países
Escenario: Necesitas un desglose de los trabajos publicados por país.

Objetivo: Crear un reporte que incluya:
El país (job_country), el número total de trabajos, y el salario promedio anual.
Solo muestra países con al menos 5 trabajos publicados.
Detalles:
Usa una subconsulta para filtrar los países con menos de 5 trabajos.
*/


-------------------------------------------------------------------------------------------------------

/*
Problema 9: Proyección de crecimiento
Escenario: Estás proyectando el crecimiento del número de trabajos en 2023.

Objetivo: Crear una tabla monthly_job_growth que contenga:
El mes y el número total de trabajos publicados en ese mes.
La diferencia porcentual en relación al mes anterior.
Detalles:
Usa EXTRACT(MONTH FROM job_posted_date) para agrupar por mes.
Calcula el porcentaje de crecimiento entre meses consecutivos con una subconsulta o función de ventana.
*/


------------------------------------------------------------------------------------------------------

/*
Problema 10: Empresas y su diversidad de habilidades
Escenario: Quieres identificar qué empresas requieren una mayor variedad de habilidades.

Objetivo: Crear un reporte que muestre:
El nombre de la empresa, la cantidad total de habilidades únicas requeridas, y el número total de trabajos publicados.
Detalles:
Usa JOINs entre company_dim, job_postings_fact, y skills_job_dim.
Agrupa por empresa y cuenta las habilidades únicas.
*/

