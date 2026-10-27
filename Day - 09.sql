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

/*
Q6. Which customer loyalty tiers contribute most to revenue?

Management wants to compare revenue contributions across loyalty tiers.
- Group by loyalty_tier.
- Calculate total customers, customers with qualifying orders, delivered order count, delivered order value, and cancelled order count.
- Calculate delivered revenue as a percentage of total delivered revenue across all loyalty tiers.
- Exclude cancelled orders from the delivered-revenue calculation.
- Sort by delivered order value descending.
*/

SELECT
	c.loyalty_tier,
    
    COUNT(c.customer_id) AS total_customers,
    
    COUNT(o.customer_id) AS customers_with_qualifying_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Delivered" THEN 1
		END
    ) AS delivered_orders,
    
    SUM(
		CASE
			WHEN o.order_status = "Delivered" THEN o.order_total
		END
    ) AS delivered_revenue,
    
    COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) AS cancelled_orders,
    
    ROUND(SUM(
		CASE
			WHEN o.order_status = "Delivered" THEN o.order_total
		END
    ) / SUM(o.order_total) * 100,2) AS delivery_rate
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
GROUP BY c.loyalty_tier
ORDER BY delivered_revenue DESC;

/*
Q7. Identify products with high sales but limited remaining stock

The inventory team wants to identify products that are selling well but may need replenishment.
- Calculate units sold per product using non-cancelled orders.
- Display current stock, units sold, and total line revenue.
- Use conditional aggregation to count qualifying units sold during 2025 and during 2026 separately.
- Include active products with fewer than 20 units currently in stock and at least 30 qualifying units sold overall.
- Sort by total units sold descending.
*/

SELECT
	p.product_id,
    p.product_name,
    p.stock_quantity AS current_stock,
    
    SUM(oi.quantity) AS units_sold,
    
    SUM(oi.line_total) AS total_line_revenue,
    
    SUM(
		CASE
			WHEN o.order_date >= '2025-01-01'
				AND o.order_date < '2026-01-01'
			THEN oi.quantity
			ELSE 0
		END
    ) AS unit_sold_2025,
    
    SUM(
		CASE
			WHEN o.order_date >= '2026-01-01'
				AND o.order_date < '2027-01-01'
			THEN oi.quantity
			ELSE 0
		END
    ) AS unit_sold_2026
    
FROM orders o

JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products p
	ON oi.product_id = p.product_id
    
WHERE o.order_status <> "Cancelled"
	AND p.is_active = 1

GROUP BY
	p.product_id,
    p.product_name,
    p.stock_quantity
    
HAVING p.stock_quantity < 20
    AND SUM(oi.quantity) >= 30
    
ORDER BY units_sold DESC;

/*
Q8. Which months have the strongest delivered-order performance?

The sales team wants to understand monthly performance and cancellation trends.
- Group orders by year and month.
- Calculate total orders, delivered orders, cancelled orders, delivered order value, and cancelled order value.
- Calculate the monthly cancellation rate.
- Sort chronologically from earliest to latest month.
*/

SELECT
    MONTH(order_date) AS order_month,
    
    COUNT(order_id) AS total_orders,
    
    COUNT(
		CASE
			WHEN order_status = "Delivered" THEN 1
		END
    ) AS delivered_orders,
    
    COUNT(
		CASE
			WHEN order_status = "Cancelled" THEN 1
		END
    ) AS cancelled_orders,
    
    SUM(
		CASE
			WHEN order_status = "Delivered" THEN order_total
		END
    ) AS delivered_order_value,
    
    SUM(
		CASE
			WHEN order_status = "Cancelled" THEN order_total
		END
    ) AS cancelled_order_value,
    
    ROUND(SUM(
		CASE
			WHEN order_status = "Cancelled" THEN order_total
		END
    ) / NULLIF(SUM(order_total),0) * 100,2) AS monthly_cancellation_rate
    
FROM orders
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date) ASC;

/*
Q9. Which customers are frequent buyers but have a high cancellation share?

The customer success team wants to identify customers who place orders frequently but also cancel a substantial proportion of them.
- Calculate total orders, cancelled orders, non-cancelled orders, and total non-cancelled order value for each customer.
- Calculate the percentage of the customer's orders that were cancelled.
- Include customers with at least five orders and a cancellation rate above 30%.
- Display customer ID, full name, loyalty tier, and all calculated metrics.
- Sort by cancellation rate descending, then total order count descending.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    c.loyalty_tier,
    
	COUNT(o.order_id) AS total_orders,
    
    COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) AS cancelled_orders,
    
    COUNT(
		CASE
			WHEN o.order_status <> "Cancelled" THEN 1
		END
    ) AS non_cancelled_orders,
    
    SUM(
		CASE
			WHEN o.order_status <> "Cancelled" THEN o.order_total
            ELSE 0
		END
    ) AS non_cancelled_order_value,
    
    ROUND(COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) / NULLIF(COUNT(o.order_id),0) * 100,2) AS cancellation_rate
    
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name),
    c.loyalty_tier
    
HAVING COUNT(o.order_id) >= 5
	AND ROUND(COUNT(
		CASE
			WHEN o.order_status = "Cancelled" THEN 1
		END
    ) / NULLIF(COUNT(o.order_id),0) * 100,2) > 30
    
ORDER BY cancellation_rate DESC, total_orders DESC;

/*
Q10. Build a multi-KPI product performance report

The merchandising director wants one product-level report combining sales performance and demand signals.

For each product, calculate:
- Total units sold in non-cancelled orders.
- Total item-level revenue.
- Units sold through the Website channel.
- Units sold through the Mobile App channel.
- Units sold at a discount greater than 0%.
- Units sold without a discount.
- Current stock quantity and active status.
Include products with at least 20 units sold or item-level revenue above ₹20,000. Sort by item-level revenue descending.
*/

SELECT
	p.product_id,
    p.product_name,
    
    SUM(oi.quantity) AS total_units_sold,
    
    SUM(oi.line_total) AS item_revenue,
    
    SUM(
		CASE
			WHEN o.sales_channel = "Website" THEN oi.quantity
            ELSE 0
		END
    ) AS unit_sold_through_website,
    
    SUM(
		CASE
			WHEN o.sales_channel = "Mobile App" THEN oi.quantity
            ELSE 0
		END
    ) AS unit_sold_through_mobile_app,
    
    SUM(
		CASE
			WHEN oi.discount_percent > 0 THEN oi.quantity
            ELSE 0
		END
    ) AS discounted_unit_sold,
    
    SUM(
		CASE
			WHEN oi.discount_percent = 0 THEN oi.quantity
            ELSE 0
		END
    ) AS non_discounted_unit_sold,
    
    p.stock_quantity AS current_stock,
    p.is_active AS active_status
    
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products p
	ON oi.product_id = p.product_id
    
WHERE o.order_status <> "Cancelled"
    
GROUP BY
	p.product_id,
    p.product_name,
    p.stock_quantity,
    p.is_active
    
HAVING SUM(oi.quantity) >= 20
	OR SUM(oi.line_total) > 20000
    
ORDER BY SUM(oi.line_total) DESC;