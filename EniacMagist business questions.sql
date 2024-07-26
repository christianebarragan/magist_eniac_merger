-- magist_eniac_merger
-- magist eniac merger

-- mysql analysis
use magist; 

-- In relation to the products -- What categories of tech products does Magist have? -- audio, consoles_games, electronics, computer_accessories, pc_gamer, computers, telephony,
SELECT DISTINCT product_category_name FROM products;

-- How many products of these tech categories have been sold (within the time window of the database snapshot
SELECT 
    p.product_category_name,
    COUNT(oi.product_id) AS products_sold
FROM 
    products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    p.product_category_name IN ('audio', 'consoles_games', 'electronics', 'computer_accessories', 'pc_gamer', 'computers', 'telephony')
GROUP BY 
    p.product_category_name;

-- What percentage does that represent from the overall number of products sold?

SELECT COUNT(distinct product_id) As ProductsSold FROM order_items; -- 32951

-- SELECT -- (TechproductsSold * 100/ProductsSold) AS PercentageSales -- FROM order_items;

-- 2145 * 100/32951; -- 13.96 = 14%

-- What’s the average price of the products being sold?

SELECT AVG(Price) AS AveragePrice FROM order_items; -- 120.65

-- Are expensive tech products popular? *

SELECT CASE WHEN price>500 THEN 'Expensive' WHEN price> 100 THEN 'Mid-level' ELSE 'Cheap' END AS price_range, count(product_id) FROM order_items LEFT JOIN products USING (product_id) LEFT JOIN product_category_name_translation USING (product_category_name) WHERE product_category_name_english IN ('audio', "electronics", "computer_accessories") GROUP BY price_range; -- Expensive 2589 -- Mid-level 503 -- Cheap 39

-- In relation to sellers -- How many months of data are included in the magist database

SELECT shipping_limit_date FROM order_items GROUP BY MONTH(your_date);

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?

SELECT COUNT(DISTINCT seller_id) AS SellersCount FROM sellers; -- 3095 all sellers

SELECT COUNT(DISTINCT seller_id) AS TechSellerCount FROM sellers LEFT JOIN order_items USING (seller_id) LEFT JOIN sellers USING (seller_id) WHERE product_category_name IN ('audio', 'consoles_games', 'eletronicos', 'pc_gamer', 'telefonia', 'telefonia_fixa'); -- check for mistakes

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers? SELECT SUM(n) AS TotalAmountEarned FROM payment_value;
SELECT SUM(payment_value) AS TotalAmountEarned
FROM order_payments;

SELECT SUM(op.payment_value) AS TotalAmountEarnedByTechSellers
FROM order_payments op
JOIN orders o ON op.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IN ('audio', 'consoles_games', 'electronics', 'computer_accessories', 'pc_gamer', 'computers', 'telephony');

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
SELECT 
    AVG(monthly_income) AS AverageMonthlyIncome
FROM (
    SELECT 
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        SUM(payment_value) AS monthly_income
    FROM 
        order_payments
    GROUP BY 
        month
) AS monthly_data;

SELECT 
    AVG(monthly_income) AS AverageMonthlyIncomeByTechSellers
FROM (
    SELECT 
        DATE_FORMAT(op.payment_date, '%Y-%m') AS month,
        SUM(op.payment_value) AS monthly_income
    FROM 
        order_payments op
    JOIN 
        orders o ON op.order_id = o.order_id
    JOIN 
        order_items oi ON o.order_id = oi.order_id
    JOIN 
        products p ON oi.product_id = p.product_id
    WHERE 
        p.product_category_name IN ('audio', 'consoles_games', 'electronics', 'computer_accessories', 'pc_gamer', 'computers', 'telephony')
    GROUP BY 
        month
) AS tech_monthly_data;

-- In relation to delivery time -- What’s the average time between the order being placed and the product being delivered?

SELECT TIME_TO_SEC(TIMEDIFF(end,start)) AS timediff FROM Sessions GROUP BY DATE(start);

-- How many orders are delivered on time vs orders delivered with a delay? -- delayed 88471 -- on-time 8007

SELECT CASE WHEN DATEDIFF(order_estimated_delivery_date,order_delivered_customer_date)>0 THEN "delayed" ELSE "on-time" END AS delivery_status, count(order_id) FROM orders WHERE order_status = "delivered" GROUP BY delivery_status;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT order_id, customer_id, product_id, CASE WHEN DATEDIFF(order_delivered_customer_date,order_purchase_timestamp) > 0 THEN 'ON TIME' ELSE 'DELAY' END AS DELIVERY, customer_id, product_id FROM orders INNER JOIN order_items USING (order_id)# WHERE DELIVERY = 'DELAY';

