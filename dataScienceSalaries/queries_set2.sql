/*
1. You're a Compensation analyst employed by a multinational corporation.
Your Assignment is to Pinpoint Countries who give work fully remotely, 
for the title 'managers’ Paying salaries Exceeding $90,000 USD
*/

select company_location
from 
    salaries
where 
    remote_ratio = 100 and 
    job_title like '%Manager%' and 
    salary_in_usd > 90000


/*
2. AS a remote work advocate Working for a progressive HR tech startup 
who place their freshers’ clients IN large tech firms. 
you're tasked WITH Identifying top 5 Country 
Having largest count of large(company size) number of companies.
*/

SELECT 
    company_location, 
    count(company_size) as count
FROM   
    salaries 
where 
    company_size = 'L' and
    experience_level = 'EN'
GROUP BY 
    company_location
order by count DESC
limit 5


/*
3. Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, 
Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
*/
SELECT * from salaries

SELECT round(((count(remote_ratio)::NUMERIC / (SELECT count(*) from salaries where salary_in_usd > 100000)) * 100), 2) as remote_count 
FROM    
    salaries 
where 
    remote_ratio = 100 and 
    salary_in_usd > 100000

/*
4. Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, 
helping your agency guide candidates towards lucrative countries.
*/

with avg_per_country AS
(
SELECT  
   company_location, job_title, round(avg(salary_in_usd)) as salary
FROM   
    salaries 
where 
    experience_level = 'EN'
GROUP BY
    company_location, job_title
),

avg AS
(
SELECT  
   job_title, round(avg(salary_in_usd)) as salary
FROM   
    salaries 
where 
    experience_level = 'EN'
GROUP BY
    job_title
)


SELECT
    c.company_location, c.job_title, c.salary as salary_per_country, a.salary 
FROM    
    avg_per_country c
JOIN
    avg a
ON
    a.job_title = c.job_title
where 
    c.salary > a.salary
order by 1



SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average
order by 1


/*
5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which
Country pays the maximum average salary. 
This helps you to place your candidates IN those countries.
*/

WITH cte as 
(
    SELECT 
        company_location, job_title, round(avg(salary_IN_usd)) as max_avg,
        rank() over(partition by job_title ORDER BY avg(salary_IN_usd) DESC) rn 
    FROM
        salaries
    GROUP BY 
        company_locatiON, job_title
    order by 2
)

SELECT 
    company_locatiON, job_title, max_avg
FROM
    cte 
where 
    rn = 1;



/*
6. AS a data-driven Business consultant, you've been hired by a multinational corporation 
to analyze salary trends across different company Locations.
Your goal is to Pinpoint Locations 
WHERE the average salary Has consistently Increased over the Past few years 
(Countries WHERE data is available for 3 years Only(this and pst two years) 
providing Insights into Locations experiencing Sustained salary growth.
*/


 /* 
 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. 
 Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, 
 highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.
 */


with cte_2021 as 
(
    SELECT
        a.experience_level, 2021_
    FROM
        (
            SELECT experience_level, count(experience_level) as 2021_remote
            FROM
                salaries
            where 
                remote_ratio = 100, 
                work_year = 2021
            GROUP BY 
                experience_level
        ) a
    JOIN
        (
            SELECT experience_level, count(experience_level) as total_remote
            FROM
                salaries
            WHERE 
                work_year = 2021
            GROUP BY 
                experience_level
        ) b
    ON 
        a.experience_level = b.experience_level

)