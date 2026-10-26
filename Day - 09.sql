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

/*
Q4. Which couriers have the highest delivery completion rate?

The logistics manager wants to compare courier performance based on shipment outcomes.
- Group by courier.
- Calculate total shipments, delivered shipments, shipments currently in transit, and shipments marked delayed.
- Calculate the delivery completion rate as delivered shipments divided by total shipments.
- Display only couriers with at least 20 shipments.
- Sort by completion rate descending.
*/

SELECT
	courier,
    
    COUNT(shipment_id) AS total_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "Delivered" THEN 1
		END
    ) AS delivered_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "In Transit" THEN 1
		END
    ) AS in_transit_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "Delayed" THEN 1
		END
    ) AS delayed_shipments,
    
    ROUND(COUNT(
		CASE
			WHEN shipment_status = "Delivered" THEN 1
		END
    ) / NULLIF(COUNT(shipment_id),0),2) AS delivery_completion_rate
    
FROM shipments
GROUP BY courier
HAVING COUNT(shipment_id) >= 20
ORDER BY delivery_completion_rate DESC;

/*
Q5. Which product categories have the greatest return exposure?

The product team wants to compare returned items and refund amounts across categories.
- Calculate units sold, returned item records, total refund amount, and the percentage of sold units represented by returned items for each category.
- Include only non-cancelled orders in the sales denominator.
- Group by category.
- Sort by the return percentage descending.
*/


SELECT
    c.category_id,
    c.category_name,

    SUM(oi.quantity) AS units_sold,

    COUNT(r.order_item_id) AS returned_item_records,

    COALESCE(SUM(r.refund_amount), 0) AS total_refund_amount,

    ROUND(
        100.0 * COUNT(r.order_item_id)
        / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS return_percentage

FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN returns r
    ON oi.order_item_id = r.order_item_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.category_id,
    c.category_name

ORDER BY return_percentage DESC;