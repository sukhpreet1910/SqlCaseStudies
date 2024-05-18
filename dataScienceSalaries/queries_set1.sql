select * from salaries

/*
1. As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data.
Your Task is to know how many people were
employed IN different types of companies AS per their size IN 2021.
*/
 
SELECT company_size, COUNT(company_size) AS count_of_employees 
FROM salaries 
WHERE work_year = 2021 
GROUP BY company_size;

/*2.
Imagine you are a talent Acquisition specialist Working for an International recruitment agency. 
Your Task is to identify the top 3 job titles that 
command the highest average salary Among part-time Positions IN the year 2023.
*/


SELECT job_title, ROUND(AVG(salary_in_usd)) AS average
FROM salaries  
WHERE employment_type = 'PT'  
GROUP BY job_title 
ORDER BY AVG(salary_IN_usd) DESC 
LIMIT 3; 


/*
3.As a database analyst you have been assigned the task to 
Select Countries where average mid-level salary is 
higher than overall mid-level salary for the year 2023.
*/


SELECT 
    employee_residence
from 
    salaries
where 
    work_year = 2023 and experience_level = 'MI'
GROUP BY 
    employee_residence
having avg(salary) > 
(
    SELECT 
        ROUND(avg(salary)) as salary
    from 
        salaries
    where 
        experience_level = 'MI'
)





/*4.
As a database analyst you have been assigned the task to 
Identify the company locations with the highest and lowest average salary for 
senior-level (SE) employees in 2023.
*/

with cte as 
(
SELECT 
    salaries.company_location,  
    rank() OVER(order by salary DESC) as max_sal, 
    rank() OVER(order by salary) as min_sal
from 
    salaries
where 
    salaries.experience_level = 'SE' and salaries.work_year = 2023
)

SELECT company_location
from 
    cte 
where 
    max_sal = 1 or min_sal = 1

-- Create a function to get senior salary stats
CREATE OR REPLACE FUNCTION GetSeniorSalaryStats()
RETURNS TABLE (
    highest_location TEXT,
    highest_avg_salary NUMERIC,
    lowest_location TEXT,
    lowest_avg_salary NUMERIC
) AS $$
BEGIN
    -- Query to find the highest average salary for senior-level employees in 2023
    RETURN QUERY
    SELECT
        highest.company_location AS highest_location,
        highest.highest_avg_salary,
        lowest.company_location AS lowest_location,
        lowest.lowest_avg_salary
    FROM
        (SELECT company_location, AVG(salary_in_usd) AS highest_avg_salary
         FROM salaries
         WHERE work_year = 2023 AND experience_level = 'SE'
         GROUP BY company_location
         ORDER BY highest_avg_salary DESC
         LIMIT 1) AS highest,
        (SELECT company_location, AVG(salary_in_usd) AS lowest_avg_salary
         FROM salaries
         WHERE work_year = 2023 AND experience_level = 'SE'
         GROUP BY company_location
         ORDER BY lowest_avg_salary ASC
         LIMIT 1) AS lowest;
END;
$$ LANGUAGE plpgsql;

-- Call the function to get the results
SELECT * FROM GetSeniorSalaryStats();