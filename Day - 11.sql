/*
Q1. Build a customer-level sales performance report

The sales director wants to understand the buying behavior of individual customers.
- Display customer ID, full name, city, loyalty tier, qualifying order count, total units purchased, and total item-level revenue.
- Exclude cancelled orders.
- Include customers with at least one qualifying order.
- Sort by item-level revenue descending and return the top 50 customers.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    c.city,
    c.loyalty_tier,
    
    COUNT(DISTINCT oi.order_id) AS order_count,
    
    SUM(oi.quantity) AS total_units_purchased,
    
    SUM(oi.line_total) AS total_item_revenue
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
JOIN order_items oi
	ON oi.order_id = o.order_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name),
    c.city,
    c.loyalty_tier
    
HAVING COUNT(oi.order_id) >= 1

ORDER BY total_item_revenue DESC
LIMIT 50;

/*
Q2. Which product categories generate the most revenue?

The category manager wants to compare commercial performance across product categories.
- Display category name, number of distinct products sold, total units sold, total item-level revenue, and average selling price per unit.
- Exclude cancelled orders.
- Include only categories with at least 50 units sold.
- Sort by item-level revenue descending.
*/

SELECT
	c.category_name,
    
    COUNT(DISTINCT oi.product_id) AS distinct_products_sold,
    
    SUM(oi.quantity) AS total_units_sold,
    
    SUM(oi.line_total) AS total_item_revenue,
    
    ROUND(SUM(oi.line_total) / SUM(oi.quantity),2) AS average_selling_price
    
FROM orders o
JOIN order_items oi
	ON oi.order_id = o.order_id
JOIN products p
	ON oi.product_id = p.product_id
JOIN categories c
	ON p.category_id = c.category_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY
	c.category_id,
	c.category_name

HAVING SUM(oi.quantity) >= 50

ORDER BY total_item_revenue DESC;

/*
Q3. Compare courier shipping costs with completed deliveries

The logistics manager wants to compare the cost profile of different couriers.
- Display courier name, total shipments, delivered shipments, total recorded shipping cost, and average shipping cost per shipment.
- Include only couriers with at least 20 shipments.
- Sort by total shipping cost descending.
*/

SELECT
	s.courier,
    
    COUNT(s.shipment_id) AS total_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "Delivered" THEN 1
		END
    ) AS delivered_shipments,
    
    SUM(s.shipping_cost) AS total_shipping_cost,
    
    ROUND(SUM(s.shipping_cost) / NULLIF(COUNT(s.shipment_id),0),2) AS average_shipping_cost
    
FROM shipments s
JOIN orders o
	ON s.order_id = o.order_id

GROUP BY s.courier

HAVING COUNT(s.shipment_id) >= 20

ORDER BY total_shipping_cost DESC;

/*
Q4. Which products have high sales but low average ratings?

The product team wants to find products that sell well but may have customer satisfaction issues.
- Display product name, total units sold, total item-level revenue, number of reviews, and average rating.
- Exclude cancelled orders from sales calculations.
- Include products with at least 20 units sold and at least five reviews.
- Return products with an average rating below 3.5.
- Sort by item-level revenue descending.
*/

SELECT
	p.product_name,
    
    SUM(oi.quantity) AS total_unit_sold,
    
    SUM(oi.line_total) AS total_item_revenue,
    
    COUNT(DISTINCT r.review_id) AS number_of_reviews,
    
    AVG(r.rating) AS average_rating
    
FROM orders o
JOIN order_items oi
	ON oi.order_id = o.order_id
JOIN products p
	ON p.product_id = oi.product_id
JOIN reviews r
	ON p.product_id = r.product_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY
	p.product_id,
    p.product_name
    
HAVING (SUM(oi.quantity) >= 20 
	AND COUNT(r.review_id) >= 5)
	AND AVG(r.rating) < 3.5
    
ORDER BY total_item_revenue DESC;

/*
Q5. Which customers have received refunds after making purchases?

Finance wants to understand refund exposure by customer.
- Display customer ID, full name, number of distinct returned order items, total refund amount, and total non-cancelled order value.
- Include customers with at least one recorded return.
- Sort by total refund amount descending.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    COUNT(DISTINCT r.order_item_id) AS distinct_order_items,
    SUM(r.refund_amount) AS total_refund_amount,
    SUM(
		CASE
			WHEN o.order_status <> "Cancelled" THEN o.order_total
			ELSE 0
		END
    ) AS non_cancelled_order_value
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
JOIN order_items oi
	ON oi.order_id = o.order_id
JOIN returns r
	ON r.order_item_id = oi.order_item_id

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name)

HAVING COUNT(DISTINCT r.order_item_id) >= 1

ORDER BY total_refund_amount DESC;

/*
Q6. Analyze payment outcomes by sales channel

The finance team wants to understand payment performance across sales channels.
- Display sales channel, number of distinct orders, total payment attempts, successful payment attempts, and total successful payment amount.
- Exclude cancelled orders from the order population.
- Group by sales channel.
- Sort by successful payment amount descending.
*/

SELECT
	o.sales_channel,
    
    COUNT(DISTINCT o.order_id) AS number_of_distinct_orders,
    
    COUNT(p.payment_id) AS total_payment_attempts,
    
    COUNT(
		CASE
			WHEN p.payment_status = "Paid" THEN 1
		END
    ) AS successful_payment_attempts,
    
    SUM(
		CASE
			WHEN p.payment_status = "Paid" THEN p.amount
            ELSE 0
		END
    ) AS successful_payment_amount
    
FROM orders o
JOIN payments p
	ON p.order_id = o.order_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY o.sales_channel

ORDER BY successful_payment_amount DESC;

/*
Q7. Which states have the largest recorded refund exposure?

The regional operations team wants to compare refund activity across shipping states.
- Display shipping state, distinct orders, distinct returned order items, and total refund amount.
- Include only orders that were not cancelled.
- Group by shipping state.
- Sort by refund amount descending.
*/

SELECT
	o.shipping_state,
    
    COUNT(DISTINCT oi.order_id) AS distinct_orders,
    
    COUNT(DISTINCT r.order_item_id) AS distinct_returned_order_items,
    
    SUM(r.refund_amount) AS total_refund_amount
    
FROM orders o
JOIN order_items oi
	ON oi.order_id = o.order_id
JOIN returns r
	ON r.order_item_id = oi.order_item_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY o.shipping_state

ORDER BY total_refund_amount DESC;

/*
Q8. Find customers who purchase from multiple product categories

The marketing team wants to identify customers with broad purchasing interests.
- Display customer ID, full name, loyalty tier, distinct categories purchased, distinct products purchased, and total units purchased.
- Exclude cancelled orders.
- Include customers who purchased from at least three distinct categories.
- Sort by distinct category count descending, then units purchased descending.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS full_name,
    c.loyalty_tier,
    
    COUNT(DISTINCT p.category_id) AS distinct_categories,
    
    COUNT(DISTINCT oi.product_id) AS distinct_products,
    
    SUM(oi.quantity) AS total_units
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
JOIN order_items oi
	ON oi.order_id = o.order_id
JOIN products p
	ON p.product_id = oi.product_id
    
WHERE o.order_status <> "Cancelled"

GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name),
    c.loyalty_tier
    
HAVING COUNT(DISTINCT p.category_id) >= 3

ORDER BY distinct_categories DESC, total_units DESC;

/*
Q9. Compare order value with payment records

Finance wants to identify orders where the recorded successful-payment amount differs from the recorded order total.
- Display order ID, customer ID, order total, successful-payment amount, and the difference between these two amounts.
- Exclude cancelled orders.
- Include orders with at least one payment record.
- Flag orders where the successful-payment amount is lower or higher than the order total.
- Sort by the absolute difference descending.
*/


SELECT
    o.order_id,
    o.customer_id,
    o.order_total,
    SUM(
        CASE
            WHEN p.payment_status = 'Paid' THEN p.amount
            ELSE 0
        END
    ) AS successful_payment_amount,
    SUM(
        CASE
            WHEN p.payment_status = 'Paid' THEN p.amount
            ELSE 0
        END
    ) - o.order_total AS payment_difference
FROM orders o
JOIN payments p
    ON p.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_total
HAVING
    SUM(
        CASE
            WHEN p.payment_status = 'Paid' THEN p.amount
            ELSE 0
        END
    ) <> o.order_total
ORDER BY ABS(payment_difference) DESC;

/*
Q10. Build an end-to-end product performance report

The merchandising director wants a unified product-level view for a business review.

For each product, calculate:
- Category name and product name.
- Total units sold and item-level revenue from non-cancelled orders.
- Number of distinct reviews and average rating.
- Number of distinct returned order items and total refund amount.
*/

SELECT
	c.category_name,
    p.product_name,
    
    SUM(oi.quantity) AS total_unit_sold,
    
    SUM(oi.line_total) AS item_level_revenue,
    
    COUNT(DISTINCT r.review_id) AS distinct_reviews,
    
    ROUND(AVG(r.rating),2) AS average_rating,
    
    COUNT(DISTINCT rt.order_item_id) AS distinct_returned_ordered_item,
    
    SUM(rt.refund_amount) AS total_refund_amount
    
FROM orders o;