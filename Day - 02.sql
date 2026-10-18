USE ecommerce_orders;

/*
Q1. Find high-value delivered orders
Finance wants to inspect delivered orders worth at least ₹10,000 that were placed during 2025.
Return order_id, customer_id, order_date, order_total, and shipping_state. Display the highest-value orders first.
Business objective: Review high-value completed transactions for revenue reporting.
*/

SELECT
	order_id,
    customer_id,
    order_date,
    order_total,
    shipping_state
FROM orders
WHERE 
	order_status = 'Delivered' 
	AND order_total >= 10000 
    AND YEAR(order_date) = 2025
ORDER BY 
	order_total DESC;

/*
Q2. Identify customers suitable for a loyalty campaign
Marketing wants to target active customers who belong to either the Gold or Platinum loyalty tier and registered before 2026.
Return customer_id, first_name, last_name, city, loyalty_tier, and signup_date, sorted by signup date from oldest to newest.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    city,
    loyalty_tier,
    signup_date
FROM customers
WHERE 
	is_active = 1 
    AND loyalty_tier IN ('Gold', 'Platinum') 
    AND signup_date < '2026-01-01'
ORDER BY 
	signup_date ASC;

/*
Q3. Investigate potentially problematic orders
The customer support team wants to review orders that are either cancelled or returned, with a total order value above ₹2,000.
Display the order ID, customer ID, order status, order date, and total value. Sort by total value descending and show up to 25 records.
*/

SELECT
	order_id,
    customer_id,
    order_status,
    order_date,
    order_total AS Total_Value
FROM orders
WHERE
	order_status IN ('Cancelled', 'Returned') 
    AND order_total > 2000
ORDER BY
	Total_Value DESC
LIMIT 25;

/*
Q4. Find customers with incomplete contact information
The CRM team wants to identify active customers whose phone number is missing, or whose email address is missing.
Display their ID, full name (using the available name columns), email, phone, city, and acquisition channel. Show the most recently registered customers first.
*/

SELECT
	customer_id,
    CONCAT(
		first_name,
        ' ',
        last_name
    ) AS Full_Name,
    email AS Customer_Email,
    phone AS Customer_Phone_Number,
    city AS Customer_City,
    acquisition_channel
FROM customers
WHERE
	is_active = 1
    AND (phone IS NULL OR email IS NULL)
ORDER BY signup_date DESC;

/*
Q5. Identify orders from priority markets
The regional sales team wants to investigate orders shipped to selected states—Maharashtra, Karnataka, and Telangana—with an order value between ₹3,000 and ₹15,000 inclusive.
Return the order ID, order date, shipping state, status, and total value. Sort by state alphabetically and then by total value descending.
*/

SELECT
	order_id,
    order_date,
    shipping_state,
    order_status,
    order_total AS Total_Value
FROM orders
WHERE shipping_state IN ('Maharashtra', 'Karnataka', 'Telangana')
	AND order_total BETWEEN 3000 AND 15000
ORDER BY 
	shipping_state ASC, 
    Total_Value DESC;