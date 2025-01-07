# Creating Database 
CREATE DATABASE amazonsalesdata;

# Creating Table
CREATE TABLE amazon(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method Varchar(30) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9) NOT NULL,
    gross_income DECIMAL(10, 6) NOT NULL,
    rating DECIMAL(3, 1) NOT NULL
);

# Import data into table 

------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- Feature Engineering -------------------------------------------------------------------

----- Adding time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM amazon;

Alter table amazon ADD COLUMN time_of_day VARCHAR(30);

UPDATE amazon
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


----- Adding day_name column
SELECT dayname(date) FROM amazon;

ALTER TABLE amazon ADD COLUMN day_name VARCHAR(10);

UPDATE amazon
SET day_name= dayname(date);

----- Adding month_name column
SELECT monthname(date) FROM amazon;

ALTER TABLE amazon ADD COLUMN month_name VARCHAR(10);

UPDATE amazon
SET month_name= monthname(date);

------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- ANALYSIS ------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------- BUSINESS QUESTIONS -----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

-- What is the count of distinct cities?
SELECT COUNT(DISTINCT(city)) 
AS distinct_city_count
FROM amazon;

-- For each branch, what is the corresponding city?
SELECT DISTINCT branch, city
FROM amazon;

-- What is the count of distinct product lines?
SELECT COUNT(DISTINCT(product_line)) 
AS distinct_product_line_count
FROM amazon;

-- Which payment method occurs most frequently?
SELECT payment_method, count(*) AS total_count
FROM amazon
GROUP BY payment_method
ORDER BY total_count DESC;

-- Which product line has the highest sales?
SELECT product_line, SUM(total) AS total_sales
FROM amazon
GROUP BY product_line
ORDER BY total_sales DESC;

-- How much revenue is generated each month?
SELECT month_name, SUM(total) AS revenue
FROM amazon
GROUP BY month_name
ORDER BY revenue DESC;

-- In which month did the cost of goods sold reach its peak?
SELECT month_name, SUM(cogs) AS total_cogs
FROM amazon
GROUP BY month_name
ORDER BY total_cogs DESC;

-- Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_sales
FROM amazon
GROUP BY product_line
ORDER BY total_sales DESC;

-- In which city was the highest revenue recorded?
SELECT city, SUM(total) AS total_sales
FROM amazon
GROUP BY city
ORDER BY total_sales DESC;

-- Which product line incurred the highest Value Added Tax?
SELECT product_line, ROUND(SUM(vat),4) AS total_vat
FROM amazon
GROUP BY product_line
ORDER BY total_vat DESC;

-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
WITH AvgSales AS (
SELECT AVG(total) AS avg_sales
FROM amazon
)
SELECT  product_line, total,
CASE 
WHEN total > (SELECT avg_sales FROM AvgSales) THEN 'Good'
ELSE 'Bad'
END AS sales_status
FROM amazon;
    
-- Identify the branch that exceeded the average number of products sold.
SELECT branch, SUM(quantity) AS total_quantity						
FROM amazon
GROUP BY branch
HAVING SUM(quantity) > (select AVG(quantity) FROM amazon)
ORDER BY SUM(quantity) DESC;

# Average of products sold
SELECT AVG(TotalQuantity) AS AvgProductsSold
FROM (
    SELECT Branch, SUM(Quantity) AS TotalQuantity
    FROM amazon
    GROUP BY Branch
) AS BranchTotals; 


-- Which product line is most frequently associated with each gender?
SELECT product_line, gender, count(gender) AS gender_count
FROM amazon
GROUP BY product_line, gender
ORDER BY gender, gender_count DESC;

-- Calculate the average rating for each product line.
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM amazon
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Count the sales occurrences for each time of day on every weekday.
SELECT day_name, time_of_day, count(*) AS sales_count
FROM amazon
WHERE day_name != 'Sunday' AND day_name != 'Saturday'
GROUP BY day_name, time_of_day
ORDER BY sales_count DESC;

-- Identify the customer type contributing the highest revenue.
SELECT customer_type, SUM(total) AS total_revenue
FROM amazon
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Determine the city with the highest VAT percentage.
SELECT city, MAX(vat) AS max_vat
FROM amazon
GROUP BY city
ORDER BY max_vat DESC;

-- Identify the customer type with the highest VAT payments.
SELECT customer_type, SUM(vat) AS total_vat
FROM amazon
GROUP BY customer_type
ORDER BY total_vat DESC;

-- What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT(customer_type)) 
AS distinct_customer_count
FROM amazon;

-- What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT(payment_method)) AS distinct_payment_type_count
FROM amazon;

-- Which customer type occurs most frequently?
SELECT customer_type, count(*) AS customer_frequency
FROM amazon
GROUP BY customer_type
ORDER BY customer_frequency DESC;

-- Identify the customer type with the highest purchase frequency.
SELECT customer_type, count(*) AS purchase_frequency
FROM amazon
GROUP BY customer_type
ORDER BY purchase_frequency DESC;

-- Determine the predominant gender among customers.
SELECT gender, COUNT(*) AS gender_count
FROM amazon
GROUP BY gender
ORDER BY gender_count DESC;

-- Examine the distribution of genders within each branch.
SELECT gender, branch, COUNT(*) AS gender_count
FROM amazon
GROUP BY gender, branch
ORDER BY gender_count DESC;

-- Identify the time of day when customers provide the most ratings.
SELECT time_of_day, COUNT(rating) AS rating_count
FROM amazon
GROUP BY  time_of_day
ORDER BY rating_count DESC;

-- Determine the time of day with the highest customer ratings for each branch.
SELECT branch, time_of_day, COUNT(rating) AS rating_count
FROM amazon
GROUP BY  branch, time_of_day
ORDER BY rating_count DESC;

-- Identify the day of the week with the highest average ratings.
SELECT day_name, ROUND(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY day_name
ORDER BY average_rating DESC;

-- Determine the day of the week with the highest average ratings for each branch.
SELECT branch, day_name, ROUND(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY branch, day_name
ORDER BY average_rating DESC;



