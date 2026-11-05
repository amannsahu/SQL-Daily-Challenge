/*
Q1. Identify the top 5 customers generating the highest revenue

The sales team wants to identify its most valuable customers to prioritize retention campaigns.

Write a query to find the top 5 customers based on their total spending on delivered orders.

Requirements:
- Consider only orders with status Delivered.
- Calculate total revenue and total number of delivered orders per customer.
- Include customers with at least 3 delivered orders.
- Sort customers by total revenue in descending order.
- If two customers have the same revenue, prioritize the customer with more orders.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    
    SUM(o.order_total) AS total_revenue,
    
    COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) AS delivered_orders
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
    
WHERE o.order_status = "Delivered"

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name)
    
HAVING
	COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) >= 3
    
ORDER BY
	total_revenue DESC,
    delivered_orders DESC
LIMIT 5;

/*
Q2. Find product categories with high revenue but low customer engagement

The product strategy team wants to identify categories that generate significant revenue but receive relatively few customer reviews.

For each product category, calculate:
- Total revenue from delivered orders.
- Total units sold.
- Total number of reviews received by products in that category.

Requirements:
- Consider only delivered orders.
- Include categories generating more than ₹50,000 in revenue.
- Include only categories with fewer than 30 reviews.
- Sort by revenue in descending order.
*/

SELECT
    cs.category_name,
    cs.total_revenue,
    cs.total_units_sold,
    COALESCE(cr.total_reviews, 0) AS total_reviews

FROM
(
    SELECT
        c.category_id,
        c.category_name,
        SUM(oi.line_total) AS total_revenue,
        SUM(oi.quantity) AS total_units_sold

    FROM categories c
    JOIN products p
        ON p.category_id = c.category_id
    JOIN order_items oi
        ON oi.product_id = p.product_id
    JOIN orders o
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY
        c.category_id,
        c.category_name

    HAVING SUM(oi.line_total) > 50000
) cs

LEFT JOIN
(
    SELECT
        p.category_id,
        COUNT(DISTINCT r.review_id) AS total_reviews

    FROM products p
    JOIN order_items oi
        ON oi.product_id = p.product_id
    JOIN orders o
        ON o.order_id = oi.order_id
    JOIN reviews r
        ON r.order_id = o.order_id

    WHERE o.order_status = 'Delivered'

    GROUP BY p.category_id
) cr
    ON cr.category_id = cs.category_id

WHERE COALESCE(cr.total_reviews, 0) < 30

ORDER BY cs.total_revenue DESC;

/*
Q1. Find customer segments with the highest cancellation rates

The business strategy team wants to identify customer segments that experience unusually high order cancellations.

For each customer segment, calculate:
- Total customers.
- Total orders.
- Delivered orders.
- Cancelled orders.
- Cancellation rate.
- Delivered order rate.

Requirements:
- Include only segments with at least 20 customers.
- Return segments with a cancellation rate above 20%.
- Sort by cancellation rate in descending order.
*/

SELECT
	c.loyalty_tier,
    
    COUNT(o.customer_id) AS total_customers,
    
    COUNT(o.order_id) AS total_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) AS delivered_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) AS cancelled_orders,
    
    ROUND(COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) * 100 / COUNT(o.order_id),2) AS cancellation_rate,
    
    ROUND(COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) * 100 / COUNT(o.order_id),2) AS delivered_rate
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
    
GROUP BY
	c.loyalty_tier
    
HAVING
	COUNT(o.customer_id) >= 20
    AND COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) * 100 / COUNT(o.order_id) > 20
    
ORDER BY cancellation_rate DESC;