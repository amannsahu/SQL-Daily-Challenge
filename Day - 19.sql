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