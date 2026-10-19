USE ecommerce_orders;

/*
Q1. Discover the business's market coverage
Management wants to know which unique cities and states appear in the order records.
Return unique combinations of shipping_city and shipping_state, sorted by state and then city. Limit the output to 30 combinations.
*/

SELECT
	DISTINCT shipping_city, shipping_state
FROM orders
ORDER BY shipping_state, shipping_city
LIMIT 30;

/*
Q2. Find products from selected brands
The merchandising team wants to review active products whose brand names contain the text tech or home, regardless of letter case.
Return the product name, brand, category ID, unit price, and stock quantity. Sort by price descending and display up to 20 products.
*/

SELECT
	product_name,
    brand AS Brand_Name,
    category_id,
    unit_price,
    stock_quantity
FROM products
WHERE (brand LIKE '%tech%' OR brand LIKE '%home%')
	AND is_active = 1
ORDER BY unit_price DESC
LIMIT 20;

/*
Q3. Identify orders that may need delivery follow-up
Operations wants to inspect orders that have not been delivered or cancelled and have an order value of at least ₹5,000.
Return the order ID, order date, status, shipping state, and total value. Show the most recent orders first and limit the results to 25.
*/

SELECT
	order_id,
    order_date,
    order_status,
    shipping_state,
    order_total AS Total_Value
FROM orders
WHERE order_status NOT IN ('Delivered', 'Cancelled')
	AND order_total >= 5000
ORDER BY order_date DESC
LIMIT 25;

/*
Q4. Find customers from business-relevant email domains
The CRM team wants to identify customers whose email addresses use either a Gmail or Yahoo domain.
Return customer ID, email, city, acquisition channel, and signup date. Sort from newest to oldest and limit the output to 30.
*/

SELECT
	customer_id,
    email AS Customer_Email,
    city AS Customer_City,
    acquisition_channel,
    signup_date
FROM customers
WHERE email LIKE '%gmail.com%' 
	OR email LIKE '%yahoo.com%'
ORDER BY signup_date DESC
LIMIT 30;

/*
Q5. Find products with a potential stock-pricing issue
The inventory team wants to find active products with fewer than 20 units in stock and a selling price greater than ₹2,000. Display the most expensive products first.
Return product ID, product name, brand, unit price, stock quantity, and unit cost. Limit the results to 15.
*/

SELECT
	product_id,
    product_name,
    brand,
    unit_price,
    stock_quantity,
    unit_cost
FROM products
WHERE is_active = 1
	AND stock_quantity < 20
    AND unit_price > 2000
ORDER BY unit_price DESC
LIMIT 15;