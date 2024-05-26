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

DO $$ 
DECLARE
    count_remote_high_salary INT;
    total_high_salary INT;
    percentage NUMERIC;
BEGIN
    -- Calculate the count of remote employees with salary > 100,000
    SELECT COUNT(*) INTO count_remote_high_salary 
    FROM salaries 
    WHERE salary_in_usd > 100000 AND remote_ratio = 100;

    -- Calculate the total count of employees with salary > 100,000
    SELECT COUNT(*) INTO total_high_salary 
    FROM salaries 
    WHERE salary_in_usd > 100000;

    -- Calculate the percentage
    percentage := ROUND((count_remote_high_salary::NUMERIC / total_high_salary) * 100, 2);

    -- Output the result
    RAISE NOTICE 'Percentage of people working remotely and having salary > 100,000 USD: %', percentage;
END $$;