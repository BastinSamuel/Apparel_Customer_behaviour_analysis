-- Database: Customer_databas

-- DROP DATABASE IF EXISTS "Customer_databas";

CREATE DATABASE "Customer_databas"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


Alter table customers
drop column promo_code_used;
select * from customers;

--Total revenue by gender
select sum(purchase_amount_usd), gender from customers group by gender;

--Customers who used discounts but spent more than average
select customer_id,purchase_amount_usd
from customers 
Where discount_applied = 'Yes' AND
purchase_amount_usd > (Select avg(purchase_amount_usd) from customers);

--Top 5 products with highest average review rating
SELECT
    item_purchased,
    AVG("review_rating") AS avg_rating
FROM customers
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;

---Average purchase amount by shipping type
select avg(purchase_amount_usd), shipping_type
from customers
group by shipping_type
order by avg(purchase_amount_usd);

--Do subscribed customers spend more?
select * from customers;

select avg(purchase_amount_usd),subscription_status
from customers
group by subscription_status;
--there is difference

--Products with the highest discount dependency
SELECT
    item_purchased,
    ROUND(
        (SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0)
        / COUNT(*), 2  ) AS discount_rate
FROM customers
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


--Customer segmentation by loyalty
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customers
)
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

--Top 3 most purchased products in each category
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;

--Are repeat buyers likely to subscribe?
SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


--Revenue by age group
SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;






