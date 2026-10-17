/*
Q1. Identify high-value orders
The e-commerce business wants to identify its largest orders to understand which transactions contribute the most revenue.
Write a query to display the top 15 orders by order_total, showing order_id, customer_id, order_date, order_status, and order_total. Rename order_total as total_order_value.
Business objective: Identify high-value transactions for further investigation.
*/

SELECT
	order_id,
    customer_id,
    order_date,
    order_status,
    order_total AS total_order_value
FROM orders
ORDER BY 
	total_order_value DESC,
    order_id ASC
LIMIT 15;

/*
Q2. Find potentially expensive inventory
The inventory team wants to prioritize products that tie up a large amount of money in stock.
Display the 10 active products with the highest inventory value, calculated as unit_cost * stock_quantity. Show product_name, stock_quantity, unit_cost, and the calculated value as inventory_value.
Business objective: Help the team identify inventory that may need purchasing or stock-management attention.
*/

SELECT
	product_id,
	product_name,
    stock_quantity,
    unit_cost,
    unit_cost * stock_quantity AS inventory_value
FROM products
WHERE is_active = 1
ORDER BY inventory_value DESC
LIMIT 10;

/*
Q3. Compare customer acquisition channels
Marketing wants to understand which acquisition channels are represented among the newest customers.
Return the 20 most recently registered customers, displaying customer_id, signup_date, city, acquisition_channel, and loyalty_tier. Use meaningful aliases and sort from newest to oldest.
Business objective: Review recent customer acquisition activity and loyalty mix.
*/

SELECT
	customer_id AS Customer_Id,
    signup_date AS Registration_date,
    city AS Customer_city,
    acquisition_channel AS Signup_channel,
    loyalty_tier AS Customer_loyalty_tier
FROM customers
ORDER BY signup_date DESC
LIMIT 20;

/*
Q4. Find orders requiring business attention
The operations team wants a shortlist of recent orders that are either still processing or have been cancelled, with the newest orders appearing first.
Return up to 20 orders with order_id, order_date, order_status, order_total, and shipping_state. Use aliases to make the output report-friendly.
Business objective: Help operations review recent orders needing follow-up or cancellation analysis.
*/

SELECT
	order_id AS Order_Id,
    order_date AS Order_Date,
    order_status AS Order_Status,
    order_total AS Order_Amount_Total,
    shipping_state AS Order_Shipping_State
FROM orders
WHERE order_status IN ('Processing', 'Cancelled')
ORDER BY order_date DESC
LIMIT 20;

/*
Q5. Identify premium-priced products
The category management team wants to review its premium-priced products that are currently active.
Display active products priced above ₹5,000, showing the product name, brand, unit price, and stock quantity. Sort by price from highest to lowest and return the top 10.
Business objective: Support premium product assortment and pricing reviews.
*/

SELECT
	product_name AS Product_Name,
    brand AS Company_Name,
    unit_price AS Product_Unit_Price,
    stock_quantity AS Product_Stock_Quantity
FROM products
WHERE unit_price > 2500
ORDER BY Product_Unit_Price DESC
LIMIT 10;