/*
Q1. Which customer segments generate the most revenue?

The marketing director wants to compare revenue contribution across customer loyalty tiers.
- Join customers with their orders.
- Exclude cancelled orders.
- Group by loyalty_tier.
- Calculate distinct ordering customers, order count, total order value, and average order value.
- Sort by total order value in descending order.
*/

SELECT
	c.loyalty_tier,
    
    COUNT(DISTINCT o.customer_id) AS ordering_customers,
    
    COUNT(o.order_id) AS order_count,
    
    SUM(o.order_total) AS total_revenue,
    
    ROUND(AVG(o.order_total),2) AS average_revenue
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
    AND o.order_status <> "Cancelled"

GROUP BY c.loyalty_tier
ORDER BY total_revenue DESC;

/*
Q2. Find customers who have never placed an order

The CRM team wants to identify registered customers who have not converted into buyers.
- Display customer ID, full name, city, loyalty tier, acquisition channel, and signup date.
- Include customers with no matching order record.
- Sort by signup date from oldest to newest.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS full_name,
    c.city,
    c.loyalty_tier,
    c.acquisition_channel,
    c.signup_date

FROM customers c
LEFT JOIN orders o
	ON o.customer_id = c.customer_id
    
WHERE o.order_id IS NULL

ORDER BY c.signup_date ASC;

/*
Q3. Which products have never been purchased?

The merchandising team wants to identify products with no recorded sales.
- Display product ID, product name, brand, unit price, and stock quantity.
- Return products that have no matching record in order_items.
- Include only active products.
- Sort by stock quantity descending.
*/

SELECT
	p.product_id,
    p.product_name,
    p.brand,
    p.unit_price,
    p.stock_quantity
    
FROM products p
LEFT JOIN order_items oi
	ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL
	AND p.is_active = 1

ORDER BY p.stock_quantity DESC;

/*
Q4. Compare order value with item-level revenue

Finance wants to examine the relationship between recorded order totals and the sum of individual item values.
- Display order ID, customer ID, order date, order total, and summed item-level revenue.
- Exclude cancelled orders.
- Include only orders with at least one item.
- Group by order-level fields and sort by the difference between order total and item revenue, largest first.
*/

SELECT
	o.order_id,
    o.customer_id,
    o.order_date,
    
    SUM(o.order_total) AS total_order_revenue,
    
    SUM(oi.line_total) AS total_item_revenue,
    
    (SUM(o.order_total) - SUM(oi.line_total)) AS difference
    
FROM orders o
JOIN order_items oi
	ON oi.order_id = o.order_id

WHERE o.order_status <> "Cancelled"

GROUP BY
	o.order_id,
    o.customer_id,
    o.order_date
    
HAVING COUNT(oi.order_id) >= 1

ORDER BY difference DESC;

/*
Q5. Which customers have made repeat purchases?

The retention team wants to identify customers who have placed multiple non-cancelled orders.
- Display customer ID, full name, loyalty tier, number of qualifying orders, and total order value.
- Include only customers with at least two non-cancelled orders.
- Sort by total order value descending.
- Return the top 50 customers.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS full_name,
    c.loyalty_tier,
    
    COUNT(o.customer_id) AS number_of_orders,
    
    SUM(o.order_total) AS total_revenue
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id

WHERE o.order_status <> "Cancelled"

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name),
    c.loyalty_tier
    
HAVING COUNT(o.customer_id) >= 2
    
ORDER BY total_revenue DESC
LIMIT 50;