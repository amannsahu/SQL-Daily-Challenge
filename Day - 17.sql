/*
Q1. Customer order distribution by status

The business wants to understand how individual customers distribute their orders across different statuses.

For each customer, calculate:
- Completed orders.
- Cancelled orders.
- Pending orders.
- Processing orders.
- Total orders.

Return only customers who have placed at least 3 orders.
*/

SELECT
	c.customer_id,
    
    COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) AS completed_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) AS cancelled_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Shipped" THEN 1
		END
    ) AS pending_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Processing" THEN 1
		END
    ) AS processing_orders,
    
    COUNT(o.customer_id) AS total_orders
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
    
GROUP BY c.customer_id
HAVING COUNT(o.customer_id) >= 3;

/*
Q2. Payment success rate by payment method

The finance team wants to compare payment gateway performance.

For each payment method, calculate:
- Total transactions.
- Successful transactions.
- Failed transactions.
- Pending transactions.
- Success rate percentage.
- Failure rate percentage.

Return only payment methods with at least 10 transactions.
*/

SELECT
	payment_method,
    
    COUNT(payment_id) AS total_transactions,
    
    COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) AS successful_transactions,
    
    COUNT(
		CASE
			WHEN payment_status = "Failed" THEN 1
		END
    ) AS failed_transactions,
    
    COUNT(
		CASE
			WHEN payment_status = "Pending" THEN 1
		END
    ) AS pending_transactions,
    
    ROUND(COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) * 100 / COUNT(payment_id),2) AS success_rate,
    
    ROUND(COUNT(
		CASE
			WHEN payment_status = "Failed" THEN 1
		END
    ) * 100 / COUNT(payment_id),2) AS failure_rate
    
FROM payments

GROUP BY payment_method
HAVING COUNT(payment_id) >= 10;

/*
Q3. Revenue contribution by product category and order status

The management team wants to compare category revenue across different order statuses.

For each product category, calculate:
- Revenue from completed orders.
- Revenue from shipped orders.
- Revenue from cancelled orders.
- Total revenue from all orders.

Return only categories where completed revenue exceeds 50,000.
*/

SELECT
	c.category_name,
    
    SUM(
		CASE
			WHEN o.order_status = "Delivered" THEN oi.line_total
            ELSE 0
		END
    ) AS completed_revenue,
    
    SUM(
		CASE
			WHEN o.order_status = "Shipped" THEN oi.line_total
            ELSE 0
		END
    ) AS shipped_revenue,
    
    SUM(
		CASE
			WHEN o.order_status = "Cancelled" THEN oi.line_total
            ELSE 0
		END
    ) AS cancelled_revenue,
    
    SUM(oi.line_total) AS total_revenue
    
FROM categories c
JOIN products p
	ON p.category_id = c.category_id
JOIN order_items oi
	ON oi.product_id = p.product_id
JOIN orders o
	ON o.order_id = oi.order_id
    
GROUP BY c.category_name
HAVING SUM(
		CASE
			WHEN o.order_status = "Delivered" THEN oi.line_total
            ELSE 0
		END
    ) > 50000;