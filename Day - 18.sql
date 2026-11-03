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