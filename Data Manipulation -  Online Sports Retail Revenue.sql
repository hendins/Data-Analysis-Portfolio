/*

Data Manipulation (Optimizing Online Sports Retail Revenue) in PostgreSQL

*/


--- Counting missing values

SELECT 
    COUNT(*) AS total_rows,
    COUNT(description) AS count_description,
    COUNT(listing_price) AS count_listing_price,
    COUNT(last_visited) AS count_last_visited
FROM info
JOIN finance ON info.product_id = finance.product_id
JOIN traffic ON info.product_id = traffic.product_id;





--- Nike vs Adidas pricing

FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE listing_price > 0
GROUP BY b.brand, f.listing_price
ORDER BY listing_price DESC;





--- Labeling price ranges

SELECT b.brand, COUNT(f.*), SUM(f.revenue) as total_revenue,
CASE WHEN f.listing_price < 42 THEN 'Budget'
    WHEN f.listing_price >= 42 AND f.listing_price < 74 THEN 'Average'
    WHEN f.listing_price >= 74 AND f.listing_price < 129 THEN 'Expensive'
    ELSE 'Elite' END AS price_category
FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE b.brand IS NOT NULL
GROUP BY b.brand, price_category
ORDER BY total_revenue DESC;





--- Average discount by brand

SELECT
    brands.brand,
    AVG(finance.discount) * 100 AS average_discount
FROM
    brands
JOIN
    finance ON brands.product_id = finance.product_id
WHERE
    brands.brand IS NOT NULL
GROUP BY
    brands.brand;
	
	
	
	
	
--- Correlation between revenue and reviews

SELECT
    CORR(reviews.reviews, finance.revenue) AS review_revenue_corr
FROM
    reviews
JOIN
    finance ON reviews.product_id = finance.product_id;
	
	
	
	
	
--- Ratings and reviews by product description length

SELECT
    TRUNC(LENGTH(info.description) / 100) * 100 AS description_length,
    ROUND(AVG(CAST(reviews.rating AS NUMERIC)), 2) AS average_rating
FROM
    info
JOIN
    reviews ON info.product_id = reviews.product_id
WHERE
    info.description IS NOT NULL
GROUP BY
    description_length
ORDER BY
    description_length;
	
	
	
	
	
--- Reviews by month and brand

SELECT
    brands.brand,
    EXTRACT(MONTH FROM traffic.last_visited) AS month,
    COUNT(reviews.product_id) AS num_reviews
FROM
    traffic
JOIN
    reviews ON traffic.product_id = reviews.product_id
JOIN
    brands ON traffic.product_id = brands.product_id
WHERE
    brands.brand IS NOT NULL
    AND EXTRACT(MONTH FROM traffic.last_visited) IS NOT NULL
GROUP BY
    brands.brand, EXTRACT(MONTH FROM traffic.last_visited)
ORDER BY
    brands.brand, EXTRACT(MONTH FROM traffic.last_visited);
	
	
	
	
	
--- Footwear product performance

WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f 
        ON i.product_id = f.product_id
    WHERE i.description ILIKE '%shoe%'
        OR i.description ILIKE '%trainer%'
        OR i.description ILIKE '%foot%'
        AND i.description IS NOT NULL
)

SELECT COUNT(*) AS num_footwear_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_footwear_revenue
FROM footwear;





--- Clothing product performance

WITH footwear AS (
    SELECT
        description,
        revenue
    FROM
        info
    JOIN
        finance ON info.product_id = finance.product_id
    WHERE
        description ILIKE '%shoe%'
        OR description ILIKE '%trainer%'
        OR description ILIKE '%foot%'
        AND description IS NOT NULL
)

-- Calculate the number of products in info and median revenue from finance
SELECT
    COUNT(DISTINCT info.product_id) AS num_clothing_products,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY finance.revenue) AS median_clothing_revenue
FROM
    info
JOIN
    finance ON info.product_id = finance.product_id
-- Filter the selection for products with a description not in footwear
WHERE
    info.description NOT IN (SELECT description FROM footwear);
	
	
	
	

