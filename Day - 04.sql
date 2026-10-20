USE ecommerce_orders;

/*
Q1 - Identify high-value customers for a loyalty campaign
The marketing team wants to identify customers who could qualify for a premium loyalty program.
From customers, display customer_id, first_name, last_name, city, customer_segment, and lifetime_value.
- Include customers belonging to the Premium, Gold, or Platinum segments.
- Their lifetime_value must be between ₹25,000 and ₹100,000, inclusive.
- Their city must be either Mumbai, Bengaluru, or Hyderabad.
- Sort the results by lifetime_value in descending order.
*/

SELECT
	order_id,
    customer_id,
    order_date,
    shipping_state,
    order_status,
    order_total
FROM orders
WHERE shipping_state IN ("Maharashtra", "Karnataka", "Telangana")
	AND order_total BETWEEN 5000 AND 20000
    AND order_status <> "Cancelled"
ORDER BY order_total DESC
LIMIT 25;

/*
Q2. Build a customer retention campaign list
The CRM team wants to target active customers who belong to either the Gold or Platinum loyalty tier and registered before 1 January 2026.
From customers, display customer_id, first_name, last_name, city, loyalty_tier, acquisition_channel, and signup_date.
- Include only active customers.
- Include only Gold and Platinum customers.
- Sort by loyalty tier and then signup date, with the oldest signup dates first.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    city,
    loyalty_tier,
    acquisition_channel,
    signup_date
FROM customers
WHERE is_active = 1
	AND loyalty_tier IN ('Gold', 'Platinum')
    AND signup_date < '2026-01-01'
ORDER BY loyalty_tier, signup_date DESC;

/*
Q3. Find products that need inventory attention
The inventory team wants to identify active products that are either low in stock or have a high unit cost.
From products, display product_id, product_name, brand, unit_price, unit_cost, and stock_quantity.
- Include active products where stock is below 15 units or unit cost is above ₹3,000.
- Exclude products with a selling price below ₹500.
- Sort by stock quantity ascending, then unit cost descending.
- Return up to 30 records.
*/

SELECT
	product_id,
    product_name,
    brand,
    unit_price,
    unit_cost,
    stock_quantity
FROM products
WHERE is_active = 1
	AND (stock_quantity < 15 OR unit_cost > 3000)
    AND NOT unit_price < 500
ORDER BY stock_quantity ASC, unit_cost DESC
LIMIT 30;

/*
Q4. Investigate orders placed during a promotional period
The marketing analytics team wants to study orders placed during the October–December 2025 festive period.
From orders, display order_id, order_date, sales_channel, coupon_code, order_status, and order_total.
- Include orders dated from 1 October 2025 through 31 December 2025, inclusive.
- Include orders from either the Website or Mobile App sales channel.
- Include only orders with a total value above ₹2,000.
- Sort by order date ascending.
*/

SELECT
	order_id,
    order_date,
    sales_channel,
    coupon_code,
    order_status,
    order_total
FROM orders
WHERE order_date BETWEEN '2025-10-01' AND '2025-12-31'
	AND sales_channel IN ("Website", "Mobile App")
    AND order_total > 2000
ORDER BY order_date DESC;

/*
Q5. Find customers eligible for a high-value customer review
The business wants to review customers who are either Platinum members or Gold members with an active account, but only if they registered during 2024 or 2025.
From customers, display customer ID, full name using the available name columns, city, loyalty tier, account status, and signup date.
- Include customers registered between 1 January 2024 and 31 December 2025.
- Include all Platinum customers and active Gold customers.
- Sort by loyalty tier and signup date, newest first within each tier.
*/

SELECT
	customer_id,
    CONCAT(
		first_name,
        " ",
        last_name
    ) AS Customer_Full_Name,
    city,
    loyalty_tier,
    is_active AS Account_Status,
    signup_date
FROM customers
WHERE signup_date BETWEEN "2024-01-01" AND "2025-12-31"
	AND loyalty_tier IN ("Platinum", "Gold")
    AND is_active = 1
ORDER BY loyalty_tier ASC, signup_date ASC;