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
    salaries.company_location, ROUND(avg(salaries.salary_in_usd)) as salary,
    rank() OVER(order by avg(salaries.salary_in_usd) DESC) as max_sal, 
    rank() OVER(order by avg(salaries.salary_in_usd)) as min_sal
from 
    salaries
where 
    salaries.experience_level = 'SE' and salaries.work_year = 2023
GROUP BY
    salaries.company_location
)

SELECT company_location, salary
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





/*
5. 
You're a Financial analyst Working for a leading HR Consultancy,
your Task is to Assess the annual salary growth rate for various job titles. 
By Calculating the percentage Increase IN salary FROM previous year to this year, 
you aim to provide valuable Insights Into salary trends WITHIN different job roles.
*/

with cte as 
(
    SELECT a.job_title, b.sal_2022, sal_2023
    from
    (
        SELECT job_title, ROUND(AVG(salary_IN_usd)) as sal_2023
        from salaries
        where work_year = 2023
        GROUP BY job_title
    ) a
    INNER JOIN
    (
        SELECT job_title, ROUND(AVG(salary_IN_usd)) as sal_2022
        from salaries
        where work_year = 2022
        GROUP BY job_title
    ) b
    on a.job_title = b.job_title
)

SELECT *, ROUND(((sal_2023 - sal_2022)/ sal_2022 ) * 100, 2) as percentage_change
from cte
ORDER BY percentage_change



/*
6. You've been hired by a global HR Consultancy to identify 
Countries experiencing significant salary growth for entry-level roles. 
Your task is to list the top three 
Countries with the highest salary growth rate FROM 2020 to 2023, 
helping multinational Corporations identify Emerging talent markets.
*/

with cte AS
(
    SELECT 
        company_location, work_year,
        ROUND(avg(salary_IN_usd), 2) as average
    from 
        salaries
    where 
        (work_year = 2021 or work_year = 2023)
        AND experience_level = 'EN'
    group by company_location, work_year
) 

SELECT 
    company_location,
    round((((sal_2023 - sal_2021) / sal_2021) * 100), 2) as salary_growth
from 
(
    SELECT
        company_location, 
        avg(case when work_year = 2021 then average end) as sal_2021,
        avg(case when work_year = 2023 then average end) as sal_2023
    from cte 
    GROUP BY company_location
)
where 
    round(((sal_2023 - sal_2021) / sal_2021) * 100, 2) is Not NULL
order by 2 DESC
limit 3


/* 
7. Picture yourself as a data architect responsible for database management. 
Companies in US and AU(Australia) decided to create a hybrid model for employees 
they decided that employees earning salaries exceeding $90000 USD, will be given work from home. 
You now need to update the remote work ratio for eligible employees,
ensuring efficient remote work management 
while implementing appropriate error handling mechanisms for invalid input parameters.
*/


create  table camp  as select * from   salaries;  
 

UPDATE camp 
SET remote_ratio = 100
WHERE (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;

SELECT * from camp
where company_location in ('AU', 'US') AND salary_in_usd > 90000