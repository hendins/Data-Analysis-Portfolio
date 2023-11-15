/*

Data Manipulation in PostgreSQL

*/




--- SELECT all columns FROM the international_debt table

SELECT *
FROM international_debt
LIMIT 10;




--- Find the number of distinct countries

SELECT 
    COUNT(DISTINCT country_name) AS total_distinct_countries
FROM international_debt;




-- Extract unique debt indicators

SELECT 
    DISTINCT indicator_code AS distinct_debt_indicators
FROM international_debt
ORDER BY distinct_debt_indicators;




-- Find the total amount of debt

SELECT 
    ROUND(SUM(debt) / 1000000, 2) AS total_debt
FROM international_debt;



--- Find the country with the highest debt 

SELECT 
    country_name, 
    SUM(debt) AS total_debt
FROM international_debt
GROUP BY country_name
ORDER BY total_debt DESC
LIMIT 1;




--- Determine the average amount of debt owed across the categories

SELECT 
    indicator_code AS debt_indicator,
    indicator_name,
    ROUND(AVG(debt), 2) AS average_debt
FROM international_debt
GROUP BY debt_indicator, indicator_name
ORDER BY average_debt DESC
LIMIT 10;




--- Find the country with the highest amount of principal repayments

SELECT 
    country_name,
    indicator_name
FROM international_debt
WHERE debt = (SELECT MAX(debt) FROM international_debt WHERE indicator_code = 'DT.AMT.DLXF.CD');




--- Find the debt indicator that appears most frequently

SELECT 
    indicator_code,
    COUNT(indicator_code) AS indicator_count
FROM international_debt
GROUP BY indicator_code
ORDER BY indicator_count DESC, indicator_code DESC
LIMIT 20;




-- Get the maximum amount of debt for each country

SELECT 
    country_name,
    MAX(debt) AS maximum_debt
FROM international_debt
GROUP BY country_name
ORDER BY maximum_debt DESC
LIMIT 10;