DROP TABLE IF EXISTS products;
CREATE TABLE products (
	sku_id SERIAL PRIMARY KEY,
	category VARCHAR(120),
	name VARCHAR(150),
	mrp NUMERIC(8,2),
	discountPercent NUMERIC(5,2),
	availableQuantity INTEGER,
	discountedSellingPrice NUMERIC(8,2),
	weightInGms INTEGER,
	outOfStock BOOLEAN,
	quantity INTEGER
);

-- DATA EXPLORATION

--1. Count of rows
SELECT COUNT(*) FROM products;

--2. sample data

SELECT * FROM products LIMIT 10;

--3. search for null values
SELECT * FROM products
WHERE name is NULL
OR
mrp is NULL
OR
discountPercent is NULL
OR
availableQuantity is NULL
OR
discountedSellingPrice is NULL
OR
weightInGms is NULL
OR
outOfStock is NULL
OR
quantity is NULL
;

--4. different product categories
SELECT DISTINCT category
FROM products
ORDER BY category;

--5. products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM products
GROUP BY outOfStock;

--6. product names present multiple times
SELECT name, COUNT(sku_id) as "NUmber of SKUs"
FROM products
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING

--1. products where price = 0
SELECT * FROM products
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM products
WHERE mrp = 0;

--2. convert paise to dollars
UPDATE products
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

SELECT mrp, discountedSellingPrice FROM products;

-- Business questions

--1. Find the top 10 bast-value products based on the discount percentage
SELECT DISTINCT name, mrp, discountPercent
FROM products
ORDER BY discountPercent DESC
LIMIT 10;

--2. What are the products with high MRP but out of stock
SELECT DISTINCT name, mrp
FROM products
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

--3. Calculate Estimated Revenue for each category
SELECT
	category,
	SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM products
GROUP BY category
ORDER BY total_revenue;

--4. Find all products where MRP is greater that $500 and discount is less than 10%

SELECT DISTINCT name, mrp, discountPercent
FROM products 
WHERE mrp > 500 and discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

--5. Identify the top 5 categories offering the highest average discount poercentage
SELECT 
	category,
	ROUND(AVG(discountPercent),2) AS avg_disc_percent
FROM products 
GROUP BY category
ORDER BY avg_disc_percent DESC
LIMIT 5;

--6. Find the price per gram for products above 100g and sort by best value\
SELECT 
	DISTINCT name, 
	weightInGms, 
	discountedSellingPrice,
	ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM products
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--7. Group products into categories like low, medium, and bulk.
SELECT 
	DISTINCT name, 
	weightInGms,
	CASE WHEN weightInGms < 1000 THEN 'Low'
		WHEN weightInGms < 5000 THEN 'Medium'
		ELSE 'Bulk'
		END AS weight_category
FROM products;

-- This kind of segmentation is useful for packaging, delivery, planning and even bulk order strategies

--8. What is the Total inventory weight per category
-- which category contribues the most to the overall inventory weight

SELECT 
	category,
	SUM(weightInGms * availableQuantity) AS total_weight
FROM products
GROUP BY category
ORDER BY total_weight;

-- This is useful for warehouse planning or identify bulky product categories 

	




