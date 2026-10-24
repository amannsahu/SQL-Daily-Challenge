/*
Q1. Which customer acquisition channels generate the most revenue?

The marketing director wants to compare the commercial value of customers acquired through different channels.
- Group customers' orders by acquisition_channel.
- Calculate distinct ordering customers, total orders, total order value, and average order value.
- Exclude cancelled orders.
- Display only channels with at least 20 distinct ordering customers.
- Sort by total order value from highest to lowest.
*/

SELECT
	c.acquisition_channel,
    
    COUNT(DISTINCT o.customer_id) AS Ordering_Customers,
    
    SUM(o.order_total) AS total_orders,
    
    ROUND(AVG(o.order_total),2) AS Average_Order_Value
    
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
WHERE order_status <> "Cancelled"
GROUP BY c.acquisition_channel
HAVING COUNT(DISTINCT o.customer_id) >= 20
ORDER BY total_orders DESC;

/*
Q2. Which cities are the strongest sales markets?

The regional sales team wants to identify cities with consistently meaningful sales activity.
- Group orders by shipping_state and shipping_city.
- Calculate order count, total order value, and average order value.
- Exclude cancelled orders.
- Show only city–state combinations with at least 15 qualifying orders.
- Sort by total order value descending.
*/

SELECT
	shipping_city,
    shipping_state,
    
	COUNT(order_id) AS order_count,
    
    SUM(order_total) AS total_order_value,
    
    ROUND(AVG(order_total),2) AS average_order_value
    
FROM orders
WHERE order_status <> "Cancelled"
GROUP BY shipping_city, shipping_state
HAVING COUNT(order_id) >= 15
ORDER BY total_order_value DESC;

/*
Q3. Which products are major revenue contributors?

The merchandising team wants to find products that generate substantial item-level revenue.
- Group qualifying order items by product.
- Calculate total units sold, distinct orders containing the product, total line revenue, and average line-item value.
- Exclude items belonging to cancelled orders.
- Show products with at least 20 units sold and item-level revenue above ₹25,000.
- Sort by revenue descending.
*/

SELECT
	p.product_id,
    p.product_name,
    
	SUM(oi.quantity) AS total_units_sold,
    
    COUNT(DISTINCT oi.order_item_id) AS distinct_orders,
    
    SUM(oi.line_total) AS total_line_revenue,
    
    ROUND(AVG(oi.line_total),2) AS Average_line_item_value

FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products p
	ON oi.product_id = p.product_id
WHERE o.order_status <> "Cancelled"
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 20 AND SUM(oi.line_total) > 25000
ORDER BY total_line_revenue DESC;

/*
Q4. Which product categories have the highest average selling price?

The category manager wants to compare realized selling prices across categories.
- Group by category name.
- Calculate units sold, total line revenue, and weighted average selling price per unit.
- Exclude cancelled orders.
- Show categories with at least 50 units sold.
- Sort by weighted average selling price descending.
*/

SELECT
	c.category_name,
    
	SUM(oi.quantity) AS units_sold,
    
    SUM(oi.line_total) AS total_line_revenue,
    
    ROUND(AVG(p.unit_price) / NULLIF(SUM(oi.quantity),0),2) AS weighted_avgerage_selling_price
    
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
JOIN categories c
	ON p.category_id = c.category_id
    
GROUP BY c.category_name
HAVING SUM(oi.quantity) >= 50
ORDER BY weighted_avgerage_selling_price DESC;

/*
Q5. Which couriers handle the largest shipment volumes?

The logistics manager wants to compare courier workload and delivery outcomes.
- Group shipments by courier.
- Calculate total shipments, number of delivered shipments, and average shipping cost.
- Show couriers with at least 20 shipments.
- Sort by shipment count descending.
*/

SELECT
	courier,
    
    COUNT(shipment_id) AS total_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "Delivered" THEN 1
		END
    ) AS Number_of_Delivered_Shipments,
    
    ROUND(AVG(shipping_cost),2) AS Average_shipping_cost
    
FROM shipments
GROUP BY courier
HAVING COUNT(shipment_id) >= 20
ORDER BY total_shipments DESC;

/*
Q6. Which payment methods have the highest transaction values?

The finance team wants to compare payment methods based on successful transactions.
- Group by payment_method.
- Calculate successful payment count, total successful payment amount, and average successful payment amount.
- Show payment methods with at least 20 successful payment records.
- Sort by total successful payment amount descending.
*/

SELECT
	payment_method,
    
    COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) AS successful_payments,
    
    SUM(
		CASE
			WHEN payment_status = "Paid" THEN amount
			ELSE 0
		END
    ) AS total_successful_payment_amount,
    
    ROUND(AVG(
		CASE
			WHEN payment_status = "Paid" THEN amount
			ELSE 0
		END
    ),2) AS avg_successful_payment_amount
    
FROM payments
GROUP BY payment_method
HAVING
	COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) >= 20
ORDER BY total_successful_payment_amount DESC;

/*
Q7. Which customer loyalty tiers have the highest average order value?

The CRM team wants to compare order behavior among loyalty tiers.
- Group orders by loyalty_tier.
- Calculate distinct ordering customers, order count, total order value, and average order value.
- Exclude cancelled orders.
- Show tiers with at least 10 distinct ordering customers.
- Sort by average order value descending.
*/

SELECT
	c.loyalty_tier,
    
    COUNT(DISTINCT o.customer_id) AS distinct_customers,
    
    COUNT(o.order_id) AS order_count,
    
    SUM(o.order_total) AS total_order_value,
    
    ROUND(AVG(order_total),2) AS average_order_value
    
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
WHERE o.order_status <> "Cancelled"
GROUP BY c.loyalty_tier
HAVING COUNT(DISTINCT o.customer_id) >= 10
ORDER BY average_order_value DESC;

/*
Q8. Which brands have a substantial inventory investment?

The inventory team wants to identify brands with significant capital tied up in stock.
- Group active products by brand.
- Calculate product count, total stock units, and total inventory cost using unit_cost * stock_quantity.
- Show brands with at least three active products and inventory cost above ₹50,000.
- Sort by inventory cost descending.
*/

SELECT
	brand,
    
    COUNT(product_id) AS product_count,
    
    SUM(stock_quantity) AS total_stock_units,
    
    SUM(unit_cost * stock_quantity) AS total_inventory_cost
    
FROM products
GROUP BY brand
HAVING COUNT(product_id) >= 3 AND SUM(unit_cost * stock_quantity) > 50000
ORDER BY total_inventory_cost DESC;

/*
Q9. Which products receive consistently poor customer ratings?

The customer experience team wants to identify products with a meaningful volume of negative feedback.
- Group reviews by product.
- Calculate review count, average rating, and number of reviews rated 1 or 2.
- Show products with at least five reviews and an average rating below 3.5.
- Sort by average rating ascending, then review count descending.
*/

SELECT
	p.product_name,
    
    COUNT(r.review_id) AS review_count,
    
    ROUND(AVG(r.rating),2) AS average_rating,
    
    COUNT(
		CASE
			WHEN r.rating IN (1,2) THEN 1
		END
    ) AS low_review_count
    
FROM products p
JOIN reviews r
	ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING COUNT(r.review_id) >= 5 AND ROUND(AVG(r.rating),2) < 3.5
ORDER BY ROUND(AVG(r.rating),2) ASC, COUNT(r.review_id) DESC;

/*
Q10. Which customers have unusually high total spending?

The customer analytics team wants to identify high-value customers for a retention initiative.
- Group qualifying orders by customer.
- Calculate order count, total spending, and average order value.
- Exclude cancelled orders.
- Show customers with at least three qualifying orders and total spending above ₹20,000.
- Display the customer ID, full name, loyalty tier, order count, and spending metrics.
- Sort by total spending descending and return the top 50 customers.
*/

SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    c.loyalty_tier,
    
    COUNT(o.order_id) AS order_count,
    
    SUM(o.order_total) AS total_spending,
    
    ROUND(AVG(o.order_total),2) AS average_order_value

FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
WHERE o.order_status <> "Cancelled"
GROUP BY
	c.customer_id,
	CONCAT(c.first_name, ' ',c.last_name),
    c.loyalty_tier
    
HAVING COUNT(o.order_id) >= 3 AND SUM(o.order_total) > 20000
ORDER BY total_spending DESC
LIMIT 50;