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