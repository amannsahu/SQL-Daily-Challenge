/*
Q1. Compare completed, cancelled, and pending order performance

The business head wants a single summary of order outcomes and their revenue implications.
- Return one summary row containing total orders, delivered orders, cancelled orders, and orders in all other statuses.
- Calculate the order value associated with delivered orders, cancelled orders, and all other orders separately.
- Calculate the percentage of orders that were cancelled.
- Use conditional aggregation rather than writing separate queries for each status.
*/

SELECT
	order_status,
    
	COUNT(order_id) AS number_of_orders,
    
    SUM(order_total) AS order_amount_total,
    
    COUNT(
		CASE
			WHEN order_status = "Cancelled" THEN 1
		END
    ) / NULLIF(COUNT(*),0) AS percentage_of_cancelled_orders
    
FROM orders
GROUP BY order_status
ORDER BY order_amount_total DESC;

/*
Q2. Which acquisition channels have the strongest customer activation?

Marketing wants to compare the proportion of acquired customers who have placed at least one non-cancelled order.
- Group customers by acquisition_channel.
- Calculate total customers, active customers, customers with at least one qualifying order, and the percentage of customers who have ordered.
- Use conditional aggregation to distinguish customers who have ordered from those who have not.
- Sort by the percentage of customers who have ordered, descending.
*/

SELECT
	c.acquisition_channel,
    
    COUNT(c.customer_id) AS total_customers,
    
    COUNT(
		CASE
			WHEN c.is_active = 1 THEN 1
		END
    ) AS active_customers,
    
    COUNT(
		CASE
			WHEN o.customer_id THEN 1
		END
    ) AS ordered_customers,
    
    COUNT(
		CASE
			WHEN o.customer_id THEN 1
		END
    ) / NULLIF(COUNT(c.customer_id),0) AS percentage_of_customers
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
GROUP BY c.acquisition_channel
ORDER BY percentage_of_customers DESC;

/*
Q3. Compare successful and failed payment activity by payment method

The finance team wants to understand payment-method reliability and value.
- Group by payment_method.
- Calculate total payment attempts, successful attempts, failed attempts, successful payment amount, and average successful payment amount.
- Calculate the success rate as a percentage of payment attempts.
- Sort by success rate descending, while considering transaction volume when interpreting the results.
*/

SELECT
	payment_method,
    
    COUNT(payment_id) AS total_payments,
    
    COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) AS successful_payments,
    
    COUNT(
		CASE
			WHEN payment_status = "Failed" THEN 1
		END
    ) AS failed_payments,
    
    SUM(
		CASE
			WHEN payment_status = "Paid" THEN amount
		END
    ) AS successful_payment_amount,
    
    SUM(
		CASE
			WHEN payment_status = "Failed" THEN amount
		END
    ) AS failed_payment_amount,
    
    COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) / NULLIF(COUNT(payment_id),0) AS success_rate

FROM payments
GROUP BY payment_method
ORDER BY success_rate DESC;